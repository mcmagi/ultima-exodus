; ULTIMA3.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade wrapper program used to load drivers and launch the game.

jmp START

;===========DATA===========

CFG_FILE        db  "U3.CFG",0
ULTIMA_COM      db  "ULTIMA.COM",0
VIDEO_DRV_LIST  dw  CGA_DRV,CGA_COMP_DRV,EGA_DRV,VGA_DRV
CGA_DRV         db  "CGA.DRV",0
CGA_COMP_DRV    db  "CGACOMP.DRV",0
EGA_DRV         db  "EGA.DRV",0
VGA_DRV         db  "VGA.DRV",0
MUSIC_DRV_LIST  dw  NOMIDI_DRV,MIDPAK_DRV
NOMIDI_DRV      db  "NOMIDI.DRV",0
MIDPAK_DRV      db  "MIDPAK.DRV",0
SFX_DRV_LIST    dw  SFX_DRV,SFXTIMED_DRV
SFX_DRV         db  "SFX.DRV",0
SFXTIMED_DRV    db  "SFXTIMED.DRV",0
MOD_DEFAULT     db  "SOSARIA",0
MOD_SUFFIX      db  ".MOD",0
MOD_FILENAME    db  0x0d dup 0
U3_PARAMS       db  0x03,0x20,0xff,0xff,0x0d,0
FILE_ERROR      db  "Error reading "
FILE_ERROR_NAME db  "            ",0x0a,0x0d,"$"
MOD_ERROR       db  "Error initializing mod",0x0a,0x0d,"$"
MUSIC_ERROR     db  "Error initializing Music Driver",0x0a,0x0d,"$"
LAUNCH_ERROR    db  "Error launching Ultima III",0x0a,0x0d,"$"
FREE_ERROR      db  "Error releasing memory for driver",0x0a,0x0d,"$"
OLD_CONFIG_INT  dd  0
OLD_MIDPAK_INT  dd  0
I_FLAG          db  0
CFGDATA         db  0x07 dup 0        ; index: 00 = midi driver, 01 = autosave, 02 = framelimiter, 03 = video driver
                                      ;        04 = moon phases, 05 = gameplay fixes, 06 = sfx driver
PRM_BLOCK       db  0x16 dup 0
FCB             db  0x20 dup 0
VIDEO_DRV_ADDR  dd  0
MUSIC_DRV_ADDR  dd  0
SFX_DRV_ADDR	dd  0
MOD_ADDR    	dd  0


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
    mov cx,0x0007
    lea dx,[CFG_FILE]
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

  MOD_MODE:
    push ds

    ; read cmd line param length at cs-0010:0080
    mov ax,cs
    mov ds,ax
    lea si,[0x0080]
    lodsb

    ; if none provided, use default mod name
    and al,al
    jz MOD_COPY_DEFAULT

    ; otherwise, skip first space
    cbw
    mov cx,ax
    inc si
    dec cx

    ; ensure cx is capped at 8 characters
    cmp cx,0x08
    jbe MOD_COPY_CMDLINE
    mov cx,0x08

  MOD_COPY_CMDLINE:
    ; get mod name from command line
    lea di,[MOD_FILENAME]
    call STRNCPY
    pop ds
    jmp MOD_COPY_SUFFIX

  MOD_COPY_DEFAULT:
    ; use default mod name
    pop ds
    lea si,[MOD_DEFAULT]
    lea di,[MOD_FILENAME]
    call STRCPY

  MOD_COPY_SUFFIX:
    ; append .mod suffix
    lea si,[MOD_SUFFIX]
    add di,cx
    call STRCPY

    ; load mod
    lea dx,[MOD_FILENAME]
    call LOAD_DRIVER
    lea bp,[MOD_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize mod
    call far [ds:bp]
    jns SFX_MODE

    ; print error & exit
    lea dx,[MOD_ERROR]
    call ERROR

  SFX_MODE:
    ; get sfx driver id from config
    mov si,[bx+0x06]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[SFX_DRV_LIST+si]

    ; load sfx driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[SFX_DRV_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize sfx driver
    call far [ds:bp]

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

  FREE_SFX_DRV:
    ; check if sfx driver was loaded
    lea bx,[SFX_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_MUSIC_DRV

    ; close sfx driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free sfx driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_MUSIC_DRV

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

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

  FREE_MOD:
    ; check if mod was loaded
    lea bx,[MOD_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz EXIT

    ; close mod's resources
    mov word [bx],0x0003
    call far [bx]

    ; free mod (ax = segment address)
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
    lea di,[FILE_ERROR_NAME]
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

    ; fcn 05 = mod address
    cmp ah,0x05
    jz CONFIG_INT_MOD

    ; fcn 06 = unused
    cmp ah,0x06
    jz CONFIG_INT_RETURN

	; fcn 07 = gameplay fixes check
	cmp ah,0x07
	jz CONFIG_INT_FIXES

	; fcn 08 = sfx driver address
	cmp ah,0x08
	jz CONFIG_INT_SFX_DRV

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

  CONFIG_INT_MOD:
    ; returns dx:ax = mod address
    mov bp,MOD_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_FIXES:
    ; returns al=01 if gameplay fixes enabled
    mov al,[cs:bx+0x05]
	jmp CONFIG_INT_RETURN

  CONFIG_INT_SFX_DRV:
    ; returns dx:ax = sfx driver address
    mov bp,SFX_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]

  CONFIG_INT_RETURN:
    pop bp
    pop bx
    popf
    iret


SET_VECTORS:
    push ax
    push dx

	call SET_CUSTOM_VECTORS
	call SET_TIMER_VECTORS

    ; multiply clock speed by 16 (18.2 * 16 = 291.2 Hz)
	mov ah,0x00
    mov dx,0x0010
	int 0x64

    ; set I_FLAG to 01 (indicates we have set new interrupts)
    mov byte [I_FLAG],0x01

    ; return
    pop dx
    pop ax
    ret


SET_CUSTOM_VECTORS:
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

    ; I_FLAG will be set to 01 if interrupt vectors have been set
    cmp byte [I_FLAG],0x01
	jnz RESET_VECTORS_RETURN

    ; restore clock speed
	mov ah,0x00
	mov dx,0x0000
	int 0x64

	call RESET_TIMER_VECTORS
	call RESET_CUSTOM_VECTORS

  RESET_VECTORS_RETURN:
    ; return
    pop dx
    pop ax
	popf
    ret


RESET_CUSTOM_VECTORS:
    pushf
    push ax
    push dx

    cli                     ; clear interrupt flag

    ; restore old int 0x65 at ds:OLD_CONFIG_INT
    mov al,0x65
    lea dx,[OLD_CONFIG_INT]
    call RESTORE_VECTOR

    ; restore old int 0x66 at ds:OLD_MIDPAK_INT
    mov al,0x66
    lea dx,[OLD_MIDPAK_INT]
    call RESTORE_VECTOR

    sti                     ; set interrupt flag

    ; return
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
include 'timer.asm'
include '../common/strcpy.asm'
include '../common/loadfile.asm'
