; VGACOLOR.ASM
; Author: Michael C. Maggio
;
; A test program used to output VGA color palettes in the VGA.PAL file.

jmp START

; data section

PALETTE_FILE            db  "VGA.PAL",0
VGA_VIDEO_SEGMENT       dw  0xa000
OLD_VIDEO_MODE          db  0x00

; code section

GET_VIDEO_MODE:
    push ax
    push bx

    mov ah,0x0f
    int 0x10

    ; save old video mode
    mov [OLD_VIDEO_MODE],al

    pop bx
    pop ax
    ret


RESET_VIDEO_MODE:
    push ax

    ; reset prior video mode
    mov ah,0x00
    mov al,[OLD_VIDEO_MODE]
    int 0x10

    pop ax
    ret


SET_VGA_VIDEO_MODE:
    push ax

    ; set vga video mode
    mov ah,0x00
    mov al,0x13
    int 0x10

    pop ax
    ret


SET_VGA_PALETTE:
    pushf
    push ax
    push cx
    push dx
    push si
    push es

    ; load palette file
    mov al,0x01
    xor cx,cx
    mov dx,PALETTE_FILE
    call LOAD_FILE

    ; es:si => palette
    mov es,ax
    xor si,si

    ; loop through each palette color
    mov cx,0x0100
    mov al,0x00

  SET_COLOR_LOOP:
    ; set palette
    call SET_COLOR
    add si,0x0003
    inc al
    loop SET_COLOR_LOOP

    ; free palette
    mov ax,es
    call FREE_MEMORY

    pop es
    pop si
    pop dx
    pop cx
    pop ax
    popf
    ret


SET_COLOR:
    ; al = palette index
    ; es:si => 3-byte rgb palette color
    pushf
    push ax
    push cx
    push dx
    push si

    ; write palette index to vga palette write port
    mov dx,0x03c8
    out dx,al

    ; write three RGB values (0-63) to VGA data port
    mov cx,0x0003
    mov dx,0x03c9
  SET_COLOR_RGB_LOOP:
    mov al,[es:si]
    out dx,al
    inc si
    loop SET_COLOR_RGB_LOOP

    pop si
    pop dx
    pop cx
    pop ax
    popf
    ret


VGA_TEST:
    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; set es:di = a000:0000
    mov es,[VGA_VIDEO_SEGMENT]
    xor di,di

    mov bh,0x00

  VGA_TEST_ROW_COLOR_LOOP:
    ; prepare to loop for 0x0c rows/color
    mov dl,0x0c

  VGA_TEST_ROW_LOOP:
    ; keep color change w/i row to 16 colors
    and bl,0x0f

  VGA_TEST_COL_COLOR_LOOP:
    ; only first nybble should change
    and bl,0x0f

    ; set al = actual color to write
    mov al,bh
    add al,bl

    ; write color into a row of block
    mov cx,0x0014
    rep stosb

    ; increment to next color w/i row
    inc bl

    ; stop after 16 colors
    cmp bl,0x10
    jb VGA_TEST_COL_COLOR_LOOP


    ; increment to next row
    dec dl
    jnz VGA_TEST_ROW_LOOP


    ; advance to next set of row colors
    add bh,0x10

    ; stop after all 256 colors (bh overflows)
    jnc VGA_TEST_ROW_COLOR_LOOP

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


WAIT_FOR_KEYPRESS:
    ; returns:
    ;  ax = pressed key

    pushf

    ; wait until a key is pressed
  WAIT_FOR_KEY_LOOP:
    mov ah,0x01
    int 0x16
    jnz WAIT_FOR_KEY_LOOP

    ; get actual key
    mov ah,0x00
    int 0x16
    
    popf
    ret


START:
    ; ds starts 100 bytes after cs in .COM files
    mov ax,cs
    add ax,0x0010
    mov ds,ax

    ; resize memory block to 0xa00 bytes (kinda large but whatevs)
    mov ah,0x4a
    mov bx,0x00a0
    int 0x21                  ; resize

    call GET_VIDEO_MODE

    call SET_VGA_VIDEO_MODE
    call SET_VGA_PALETTE

    ; show vga colors
    call VGA_TEST
    call WAIT_FOR_KEYPRESS

    call RESET_VIDEO_MODE

    ; exit to DOS
    mov ah,0x4c
    mov al,0x00
    int 0x21

include '../common/loadfile.asm'