; PALETTE.ASM
; Author: Michael C. Maggio
;
; Common functions for VGA palette management.

; Loads the palette file as the current VGA palette
LOAD_VGA_PALETTE:
    ; parameters:
    ;  dx = palette filename
    pushf
    push ax
    push cx
    push dx
    push si
    push es

    ; load palette file
    mov al,0x01
    xor cx,cx
    call LOAD_FILE

    ; es:si => palette
    mov es,ax
    xor si,si

    ; loop through each palette color
    mov cx,0x0100
    mov al,0x00

  LOAD_VGA_PALETTE_COLOR_LOOP:
    ; set palette color
    call SET_COLOR
    add si,0x0003
    inc al
    loop LOAD_VGA_PALETTE_COLOR_LOOP

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
    ; parameters:
    ;  al = palette index
    ;  es:si => 3 byte rgb palette color
    pushf
    push ax
    push cx
    push dx
    push si

    ; write palette index to vga palette write port
    mov dx,0x03c8
    out dx,al

    ; write three rgb values (0-63) to VGA data port
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
