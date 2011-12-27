; VGA.ASM
; Author: Michael C. Maggio
;
; Used to save the standard VGA color palette to the VGA.PAL file.

jmp START

; *************** DATA ***************

RGB		    db	0,0,0,0
PALFILE		db	"VGA.PAL",0x00
FILE_ERROR	db	"Error writing to VGA.PAL",0x0a,0x0d,"$",0x00
MODE        db	0

; *************** CODE ***************

START:
    ; ds starts 100 bytes after cs in .COM files
    mov ax,cs
    add ax,0x0010
    mov ds,ax

    ; save old video mode
    mov ah,0x0f
    int 0x10
    mov [MODE],al

    ; open the file
    call OPEN_FILE

    ; set to graphics mode 13
    mov ah,0x00
    mov al,0x13
    int 0x10

    ; loop 256 times
    mov cx,0x0100

COLOR_LOOP:
    ; al = 100 - cl (to get pal #)
    mov al,0x00
    sub al,cl

    ; get the palette (stored in RGB)
    call GET_PAL

    ; save the palette to disk
    call SAVE_PAL

    ; loop back!
    loop COLOR_LOOP

    ; close the palette file
    call CLOSE_FILE

EXIT:
    ; set to graphics mode 00
    mov ah,0x00
    mov al,[MODE]
    int 0x10

    mov ah,0x4c
    mov al,0x00
    int 0x21


GET_PAL:
    ; al = requested palette index

    pushf
    push ax
    push bx
    push dx

    ; set dx to pal request port
    mov dx,0x3c7

    ; write index to port
    out dx,al

    ; set dx to pal data port
    mov dx,0x3c9

    ; get red value
    in al,dx
    mov [RGB],al

    ; ditto for green
    in al,dx
    mov [RGB+1],al

    ; ditto for blue
    in al,dx
    mov [RGB+2],al

    pop dx
    pop bx
    pop ax
    popf
    ret


OPEN_FILE:
    ; store
    pushf
    push ax
    push cx
    push dx

    ; open palette file for writing
    mov ah,0x3c
    mov cx,0x0000
    mov dx,PALFILE
    int 0x21		    ; OPEN
    jc LOAD_FAILURE	; go here on error

    ; save file handle in bx
    mov bx,ax

    ; restore & return
    pop dx
    pop cx
    pop ax
    popf
    ret


SAVE_PAL:
    pushf
    push ax
    push cx
    push dx

    ; write pal to palette file
    mov ah,0x40
    mov cx,0x03
    mov dx,RGB
    int 0x21		; WRITE
    jc LOAD_FAILURE	; go here on error

    ; restore & return
    pop dx
    pop cx
    pop ax
    popf
    ret


CLOSE_FILE:
    ; store
    pushf
    push ax

    ; close file
    mov ah,0x3e
    int 0x21		; CLOSE
    jc LOAD_FAILURE	; go here on success

    ; restore & return
    pop ax
    popf
    ret


LOAD_FAILURE:
    ; print error string
    mov dx,FILE_ERROR
    mov ah,0x09
    int 0x21		; print string

    ; exit with error code 1
    mov ah,0x4c
    mov al,0x01
    int 0x21
