; ULTIMA3.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade wrapper program used to load drivers and launch the game.

jmp START

;===========DATA===========

U3CFG           db  "U3.CFG",0
ULTIMA_COM      db  "ULTIMA.COM",0
VIDEO_DRV_LIST  dw  CGA_DRV,CGA_COMP_DRV,EGA_DRV,VGA_DRV
CGA_DRV         db  "CGA.DRV",0
CGA_COMP_DRV    db  "CGACOMP.DRV",0
EGA_DRV         db  "EGA.DRV",0
VGA_DRV         db  "VGA.DRV",0
MUSIC_DRV_LIST  dw  NOMIDI_DRV,MIDPAK_DRV
NOMIDI_DRV      db  "NOMIDI.DRV",0
MIDPAK_DRV      db  "MIDPAK.DRV",0
U3_PARAMS       db  0x03,0x20,0xff,0xff,0x0d,0
FILE_ERROR      db  "Error reading "
FILE_ERROR_NAME db  "            ",0x0a,0x0d,"$"
MUSIC_ERROR     db  "Error initializing Music Driver",0x0a,0x0d,"$"
LAUNCH_ERROR    db  "Error launching Ultima III",0x0a,0x0d,"$"
FREE_ERROR      db  "Error releasing memory for driver",0x0a,0x0d,"$"
OLD_CLOCK_INT   dd  0
OLD_TIMER_INT   dd  0
OLD_CONFIG_INT  dd  0
OLD_MIDPAK_INT  dd  0
I_FLAG          db  0
CFGDATA         db  0x06 dup 0        ; index: 00 = midi driver, 01 = autosave, 02 = framelimiter, 03 = video driver
                                      ;        04 = moon phases, 05 = vga moongate type
PRM_BLOCK       db  0x16 dup 0
FCB             db  0x20 dup 0
VIDEO_DRV_ADDR  dd  0
MUSIC_DRV_ADDR  dd  0
CLOCK_COUNTER   dw  0x0001
CLOCK_SPEED     dw  0x0001
TIMER_COUNTER   dw  0


;===========CODE===========

START:
    ; resize memory block to 0xa00 (2560) bytes
    mov ah,0x4a
    mov bx,0x00a0
    int 0x21                  ; resize

    ; move stack to end of memory block
    mov ax,cs
    mov ss,ax
    mov sp,0x09fe

    ; set ds = cs + 0x10
    mov ax,cs
    add ax,0x0010
    mov ds,ax
    mov es,ax

    ; read u3.cfg into cfgdata location
    mov al,0x00
    lea bx,[CFGDATA]
    mov cx,0x0006
    lea dx,[U3CFG]
    call LOAD_FILE

    ; handle failure
    cmp ax,0xffff
    jnz LOAD_CFG_SUCCESS

    ; copy filename to error msg
    mov si,dx
    lea di,[FILE_ERROR_NAME]
    call STRCPY

    ; print error message
    mov dx,FILE_ERROR
    call ERROR

  LOAD_CFG_SUCCESS:
    ; set new interrupt vectors
    call SET_VECTORS

    ; set I_FLAG to 01 (indicates we have set new interrupts)
    mov byte [I_FLAG],0x01

    ; save offset to cfgdata in bx
    lea bx,[CFGDATA]

  MUSIC_MODE:
    ; get music driver id from config
    mov si,[bx]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[MUSIC_DRV_LIST+si]

    ; load music driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[MUSIC_DRV_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize music driver
    call far [ds:bp]

    cmp ax,0x0001
    jnz GRAPHIC_MODE        ; jump here on success

    ; print error & exit
    lea dx,[MUSIC_ERROR]
    call ERROR

  GRAPHIC_MODE:
    ; get graphic driver id from config
    mov si,[bx+0x03]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[VIDEO_DRV_LIST+si]

    ; load video driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[VIDEO_DRV_ADDR]
    mov [ds:bp+0x02],ax

  LAUNCH_PROGRAM:
    ; set dx = offset of "ultima.com"
    lea dx,[ULTIMA_COM]

    ; fill parameter block
    lea bx,[PRM_BLOCK]
    mov word [bx],0x0000
    mov word [bx+0x02],U3_PARAMS
    mov [bx+0x04],ds
    mov word [bx+0x06],FCB
    mov [bx+0x08],ds
    mov word [bx+0x0a],FCB
    mov [bx+0x0c],ds

    ; launch Ultima 3
    mov ax,0x4b00
    xor cx,cx               ; clear cx
    int 0x21                ; execute

    jnc RESET_REGISTERS     ; jump here on success

    ; print launch error & exit
    lea dx,[LAUNCH_ERROR]
    call MESSAGE

  RESET_REGISTERS:
    ; reset segment registers and stack
    mov ax,cs
    mov ss,ax
    add ax,0x0010
    mov ds,ax
    mov es,ax
    mov sp,0x09fe

  FREE_MUSIC_DRV:
    ; check if music driver was loaded
    lea bx,[MUSIC_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_VIDEO_DRV

    ; close music driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free music driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_VIDEO_DRV

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  FREE_VIDEO_DRV:
    ; check if video driver was loaded
    lea bx,[VIDEO_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz EXIT

    ; close video driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free video driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz EXIT

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  EXIT:
    ; set errorlevel for exit
    mov al,0x00

  ERROR_EXIT:
    ; I_FLAG will be set to 01 if interrupt vectors have been set
    cmp byte [I_FLAG],0x01
    jnz TERMINATE

    ; reset the interrupt vectors
    call RESET_VECTORS

  TERMINATE:
    ; exit with errorlevel al
    mov ah,0x4c
    int 0x21                ; exit


;===========FCNS===========

LOAD_DRIVER:
    ; parameters:
    ;  ds:dx = offset to driver name
    ; returns:
    ;  ax:0000 = segment:offset of loaded driver

    pushf
    push cx
    push dx
    push si
    push di

    ; load driver
    mov al,0x01
    xor cx,cx
    call LOAD_FILE

    ; handle failure
    cmp ax,0xffff
    jnz LOAD_DRIVER_SUCCESS

    ; copy filename to error msg
    mov si,dx
    mov di,FILE_ERROR_NAME
    call STRCPY

    ; print error message
    mov dx,FILE_ERROR
    call ERROR

  LOAD_DRIVER_SUCCESS:
    pop di
    pop si
    pop dx
    pop cx
    popf
    ret


; This function is used to replace the MIDPAK interrupt if there is no MIDPAK
; driver loaded.  (INT 0x66)
MIDPAK_INT:
    ; no-op fcn (does nothing)
    iret


; The configuration interrupt (INT 0x65)
CONFIG_INT:
    pushf
    push bx
    push bp

    ; set bx as offset to config data
    lea bx,[CFGDATA]

    ; fcn 00 = autosave check
    cmp ah,0x00
    jz CONFIG_INT_AUTOSAVE

    ; fcn 01 = frame limiter check
    cmp ah,0x01
    jz CONFIG_INT_FRAMELIMITER

    ; fcn 02 = video driver address
    cmp ah,0x02
    jz CONFIG_INT_VIDEO_DRV

    ; fcn 03 = music driver address
    cmp ah,0x03
    jz CONFIG_INT_MUSIC_DRV

    ; fcn 04 = moon phase check
    cmp ah,0x04
    jz CONFIG_INT_MOONPHASE

    ; fcn 05 = set timer
    cmp ah,0x05
    jz CONFIG_INT_SET_TIMER

    ; fcn 06 = get timer
    cmp ah,0x06
    jz CONFIG_INT_GET_TIMER

    jmp CONFIG_INT_RETURN

  CONFIG_INT_AUTOSAVE:
    ; returns al=01 if autosave enabled
    mov al,[cs:bx+0x01]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_FRAMELIMITER:
    ; returns al=01 if frame limiter enabled
    mov al,[cs:bx+0x02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_VIDEO_DRV:
    ; returns dx:ax = video driver address
    mov bp,VIDEO_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+0x02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_MUSIC_DRV:
    ; returns dx:ax = music driver address
    mov bp,MUSIC_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_MOONPHASE:
    ; returns al=01 if moon phases enabled
    mov al,[cs:bx+0x04]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_SET_TIMER:
    ; sets counter to cx
    mov [cs:TIMER_COUNTER],cx
    jmp CONFIG_INT_RETURN

  CONFIG_INT_GET_TIMER:
    ; returns cx=counter
    mov cx,[cs:TIMER_COUNTER]

  CONFIG_INT_RETURN:
    pop bp
    pop bx
    popf
    iret


; The clock interrupt (INT 0x08) is normally called 18.2 times every second.
; However, it may be adjusted by a call to SET_CLOCK_SPEED.  If so, use this
; replacement interrupt handler to ensure the old INT 0x08 is called at the
; appropriate frequency, thus ensuring the system clock updates properly while
; the custom timer interrupt (INT 0x1C) is called at the new frequency.
CLOCK_INT:
    push ax

    ; decrement counter
    dec word [cs:CLOCK_COUNTER]
    jz CLOCK_INT_UPDATE

    ; only call the custom timer int (0x1c)
    int 0x1c                    ; custom timer
    jmp CLOCK_INT_RETURN

  CLOCK_INT_UPDATE:
    ; when counter hits zero, call the old clock int (0x08),
    ; this will also call the custom timer int (0x1c)
    pushf                           ; pushf simulates INT call so iret works
    call far [cs:OLD_CLOCK_INT]

    ; also reset counter
    mov ax,[cs:CLOCK_SPEED]
    mov [cs:CLOCK_COUNTER],ax

  CLOCK_INT_RETURN:
    ; re-enable lower-level interrupts
    ; (not sure why this is needed yet)
    mov al,0x20
    out 0x20,al

    pop ax
    iret


; The timer interrupt (INT 0x1C) is normally called 18.2 times every second.
; However, it may be adjusted by a call to SET_CLOCK_SPEED.  If so, this int
; will be called at the new frequency.  It is used to decrement the counter
; variable at TIMER_COUNTER to 0.  Does not decrement past 0.  The counter can
; be set by calling INT 0x65 (AH=05) or obtained by INT 65 (AH=06).
TIMER_INT:
    ; do not decrement counter if it's at 0
    cmp word [cs:TIMER_COUNTER],0x0000
    jz TIMER_RETURN

    ; decrement counter
    dec word [cs:TIMER_COUNTER]

  TIMER_RETURN:
    ; chain with the previous interrupt
    jmp far [cs:OLD_TIMER_INT]


SET_VECTORS:
    pushf
    push ax
    push bx
    push dx
    push es

    cli                     ; clear interrupt flag
    cld                     ; clear direction flag

    ; set es = ds
    push ds
    pop es

    ; save old int 0x08 to ds:OLD_CLOCK_INT
    ; and replace it with cs:CLOCK_INT
    mov al,0x08
    lea dx,[OLD_CLOCK_INT]
    call SAVE_VECTOR
    lea bx,[CLOCK_INT]
    call REPLACE_VECTOR

    ; save old int 0x1c to ds:OLD_TIMER_INT
    ; and replace it with cs:TIMER_INT
    mov al,0x1c
    lea dx,[OLD_TIMER_INT]
    call SAVE_VECTOR
    lea bx,[TIMER_INT]
    call REPLACE_VECTOR

    ; save old int 0x65 to ds:OLD_CONFIG_INT
    ; and replace it with cs:CONFIG_INT
    mov al,0x65
    lea dx,[OLD_CONFIG_INT]
    call SAVE_VECTOR
    lea bx,[CONFIG_INT]
    call REPLACE_VECTOR

    ; save old int 0x66 to ds:OLD_MIDPAK_INT
    ; and replace it with cs:MIDPAK_INT
    mov al,0x66
    lea dx,[OLD_MIDPAK_INT]
    call SAVE_VECTOR
    lea bx,[CONFIG_INT]
    call REPLACE_VECTOR

    ; quadruple clock speed
    mov dx,0x0004
    call SET_CLOCK_SPEED

    sti                     ; set interrupt flag

    ; return
    pop es
    pop dx
    pop bx
    pop ax
    popf
    ret


RESET_VECTORS:
    pushf
    push ax
    push dx

    cli                     ; clear interrupt flag

    ; restore old int 0x1c at ds:OLD_CLOCK_INT
    mov al,0x08
    lea dx,[OLD_CLOCK_INT]
    call RESTORE_VECTOR

    ; restore old int 0x1c at ds:OLD_TIMER_INT
    mov al,0x1c
    lea dx,[OLD_TIMER_INT]
    call RESTORE_VECTOR

    ; restore old int 0x65 at ds:OLD_CONFIG_INT
    mov al,0x65
    lea dx,[OLD_CONFIG_INT]
    call RESTORE_VECTOR

    ; restore old int 0x66 at ds:OLD_MIDPAK_INT
    mov al,0x66
    lea dx,[OLD_MIDPAK_INT]
    call RESTORE_VECTOR

    ; restore clock speed
    mov dx,0x0001
    call SET_CLOCK_SPEED

    sti                     ; set interrupt flag

    ; return
    pop dx
    pop ax
    popf
    ret


SAVE_VECTOR:
    ; al = vector #
    ; ds:dx = location to store old vector

    push ax
    push bx
    push di
    push es

    ; get interrupt vector al in es:bx
    mov ah,0x35
    int 0x21                ; get interrupt vector

    mov di,dx

    ; save es:bx address at ds:di
    mov ax,es
    mov [di+0x00],bx
    mov [di+0x02],ax

    pop es
    pop di
    pop bx
    pop ax
    ret


REPLACE_VECTOR:
    ; al = vector #
    ; es:bx = new vector

    push bx
    push ds

    ; set ds:dx = new vector
    push es
    pop ds
    mov dx,bx

    ; set interrupt vector al with ds:dx
    mov ah,0x25
    int 0x21                ; set interrupt vector

    pop ds
    pop bx
    ret


RESTORE_VECTOR:
    ; al = vector #
    ; ds:dx = location of where old vector address is stored

    push bx
    push si
    push es

    mov si,dx

    ; set es:bx = vector address stored in ds:si
    push ax
    mov bx,[si+0x00]
    mov ax,[si+0x02]
    mov es,ax
    pop ax

    call REPLACE_VECTOR

    pop es
    pop si
    pop bx
    ret


; This function is used to change the frequency at which INT 0x08 is called.
; It should be used in tandem with the custom CLOCK_INT function to ensure the
; system time updates properly.
SET_CLOCK_SPEED:
    ; dx = clock accelleration factor (01 for normal, 02 for twice as fast, etc)

    pushf
    push ax
    push dx

    ; check bounds
    cmp dx,0x0000
    jz SET_CLOCK_SPEED_RETURN

    ; save new speed in CLOCK_SPEED
    mov [CLOCK_SPEED],dx

    ; set channel 0 to mode 3
    mov al,0x36
    out 0x43,al

    ; if dx == 1 (normal) just set output word to 0,
    ; otherwise we need to do some division
    cmp dx,0x0001
    jnz SET_CLOCK_SPEED_DIVIDE
    mov ax,0x0000
    jmp SET_CLOCK_SPEED_OUTPUT

  SET_CLOCK_SPEED_DIVIDE:
    ; ax = 64k / dx
    mov bx,dx
    mov dx,0x0001
    mov ax,0x0000
    div bx

  SET_CLOCK_SPEED_OUTPUT:
    ; write word to counter 0
    out 0x40,al
    mov al,ah
    out 0x40,al

  SET_CLOCK_SPEED_RETURN:
    pop dx
    pop ax
    popf
    ret


MESSAGE:
    ; parameters:
    ;  dx = address of message text

    pushf
    push ax

    ; print message
    mov ah,0x09
    int 0x21                ; print string

    pop ax
    popf
    ret


ERROR:
    call MESSAGE

    ; exit with errorlevel 1
    mov al,0x01
    jmp ERROR_EXIT


; include supporting files
include '../common/strcpy.asm'
include '../common/loadfile.asm'
