; ULTIMA3D.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade wrapper program used to load drivers and launch the game.
; This is a debug version that is used for experimentation/tracing/debugging.

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
I_DATA          db  0x0c dup 0
I_FLAG          db  0
CFGDATA         db  0x06 dup 0        ; index: 00 = midi driver, 01 = autosave, 02 = framelimiter, 03 = video driver
                                      ;        04 = moon phases, 05 = vga moongate type
PRM_BLOCK       db  0x16 dup 0
FCB             db  0x20 dup 0
VIDEO_DRV_ADDR  dd  0
MUSIC_DRV_ADDR  dd  0
ULTIMA_ADDR     dd  0


;===========CODE===========

START:
    ; resize memory block to 0xa00 bytes
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
    ; get graphic driver id from config
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
    ; set dx = offset of "u3ega.com"
    lea dx,[ULTIMA_COM]

    ; fill parameter block
    ;lea bx,[PRM_BLOCK]
    ;mov word [bx],0x0000
    ;mov word [bx+0x02],U3_PARAMS
    ;mov [bx+0x04],ds
    ;mov word [bx+0x06],FCB
    ;mov [bx+0x08],ds
    ;mov word [bx+0x0a],FCB
    ;mov [bx+0x0c],ds

    ; launch Ultima 3
    ;mov ax,0x4b00
    ;xor cx,cx               ; clear cx
    ;int 0x21                ; execute

    ; ==== alternate call to ULTIMA.COM for debugging ====
    lea dx,[ULTIMA_COM]
    call LOAD_DRIVER
    lea bp,[ULTIMA_ADDR]
    sub ax,0x0010
    mov word [ds:bp],0x0100
    mov [ds:bp+0x02],ax
    mov ds,ax
    mov es,ax
    ; must manually set stack after call
    call far [ds:bp]

    ; ==== direct calls to video driver for debugging ====
    ;lea bp,[VIDEO_DRV_ADDR]
    ;mov word [ds:bp],0x0000   ; init_driver
    ;call far [ds:bp]
    ;mov word [ds:bp],0x0024   ; load_charset_file
    ;call far [ds:bp]
    ;mov word [ds:bp],0x000f   ; draw_game_border
    ;call far [ds:bp]
    ;mov word [ds:bp],0x0030   ; scroll_tile
    ;call far [ds:bp]

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
    ;  ds:dx = offset to video driver name
    ; returns:
    ;  ax:0000 = segment:offset of loaded driver

    pushf
    push cx
    push dx
    push si
    push di

    ; load video driver
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


; This function is used to replace int 66 if there is no midpak driver.
WRAPPER:
    ; wrapper fcn (does nothing)
    iret


ULTIMA3_INT:
    push bx
    push bp

    ; set bx as offset to config data
    lea bx,[CFGDATA]

    ; fcn 00 = autosave check
    cmp ah,0x00
    jz AUTOSAVE

    ; fcn 01 = frame limiter check
    cmp ah,0x01
    jz FRAMELIMITER

    ; fcn 02 = video driver address
    cmp ah,0x02
    jz GET_VIDEO_DRV

    ; fcn 03 = music driver address
    cmp ah,0x03
    jz GET_MUSIC_DRV

    ; fcn 04 = moon phase check
    cmp ah,0x04
    jz MOONPHASE

    jmp RETURN

  AUTOSAVE:
    ; returns al=01 if autosave enabled
    mov al,[cs:bx+0x01]
    jmp RETURN

  FRAMELIMITER:
    ; returns al=01 if frame limiter enabled
    mov al,[cs:bx+0x02]
    jmp RETURN

  GET_VIDEO_DRV:
    ; returns dx:ax = video driver address
    mov bp,VIDEO_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+0x02]
    jmp RETURN

  GET_MUSIC_DRV:
    ; returns dx:ax = music driver address
    mov bp,MUSIC_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]
    jmp RETURN

  MOONPHASE:
    ; returns al=01 if moon phases enabled
    mov al,[cs:bx+0x04]
    jmp RETURN

  RETURN:
    pop bp
    pop bx
    iret


SET_VECTORS:
    pushf
    push ax
    push cx
    push si
    push di
    push ds
    push es

    cli                     ; clear interrupt flag
    cld                     ; clear direction flag

    push ds
    pop es                  ; copy ds into es
    xor ax,ax               ; clear ax
    mov ds,ax               ; clear ds

    ; set source/dest index
    mov si,0x0194           ; offset of int vect 65
    mov di,I_DATA           ; offset of backup int table

    ; move 4 words
    mov cx,0x0004
    rep
    movsw                   ; move a word from ds:si to es:di

    ; set default values for new vectors
    mov ax,cs
    add ax,0x0010
    mov word [0x0194],ULTIMA3_INT
    mov [0x0196],ax
    mov word [0x0198],WRAPPER
    mov [0x019a],ax

    sti                     ; set interrupt flag

    ; return
    pop es
    pop ds                  ; restore ds
    pop di
    pop si
    pop cx
    pop ax
    popf
    ret


RESET_VECTORS:
    pushf
    push ax
    push cx
    push si
    push di
    push es

    cli                     ; clear interrupt flag

    ; set es to interrupt vector table
    xor ax,ax               ; clear ax
    mov es,ax               ; clear es

    ; set source/dest index
    mov si,I_DATA           ; offset of backup int table
    mov di,0x0194           ; offset of int vect 64

    ; move 4 words
    mov cx,0x0004
    rep
    movsw                   ; move a word from ds:si to es:di

    sti                     ; set interrupt flag

    ; return
    pop es
    pop di
    pop si
    pop cx
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
