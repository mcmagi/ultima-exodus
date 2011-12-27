; CGACOMP.ASM
; Author: Michael C. Maggio
;
; Generates a VGA Palette file for the CGA Composite palette.  VGA palette files
; have 6-bit RGB channels, however the data the palette is generated from is in
; 8-bit.  This program just serves as a quick & dirty utility to transform the
; data into the appropriate format.

jmp START

; data section

PALETTE_FILE            db      "CGACOMP.PAL",0x00
COMPOSITE_RGB_PALETTE   db      0x00,0x00,0x00, 0x00,0x9a,0xff, 0x00,0x42,0xff, 0x00,0x90,0xff
                        db      0xaa,0x4c,0x00, 0x84,0xfa,0xd2, 0xb9,0xa2,0xad, 0x96,0xf0,0xff
                        db      0xcd,0x1f,0x00, 0xa7,0xcd,0xff, 0xdc,0x75,0xff, 0xb9,0xc3,0xff
                        db      0xff,0x5c,0x00, 0xed,0xff,0xcc, 0xff,0xb2,0xa6, 0xff,0xff,0xff
ERROR_MESSAGE           db      "Error saving palette file",0x0a,0x0d,"$",0x00


; code section

START:
    ; ds starts 100 bytes after cs in .COM files
    mov ax,cs
    add ax,0x0010
    mov ds,ax

    ; resize memory block
    mov ah,0x4a
    mov bx,0x00a0
    int 0x21              ; RESIZE

    ; move stack to end of memory block
    mov ax,cs
    mov ss,ax
    mov sp,0x09fe

    ; allocate space for file
    mov ax,0x0300
    call ALLOCATE_MEMORY

    cmp ax,0xffff
    jz ERROR

    ; ds:si = 8-bit per channel palette
    lea si,[COMPOSITE_RGB_PALETTE]
    ; es:di = 6-bit per channel palette
    mov es,ax
    lea di,[0x0000]

    ; read 8-bit RGB value, convert to 6-bit, and store in palette
    mov cx,0x0030
  PALETTE_LOOP:
    lodsb
    shr al,1
    shr al,1
    stosb
    loop PALETTE_LOOP

    ; store 0's for remaining values in palette
    mov cx,0x02d0
    mov al,0x00
    rep stosb

    ; save file
    mov cx,0x0300
    lea dx,[PALETTE_FILE]
    xor di,di
    call SAVE_FILE

    ; exit
    mov ah,0x4c
    mov al,0x00
    int 0x21


MESSAGE:
    ; parameters:
    ;  dx = address of message text

    pushf
    push ax

    ; print message
    mov ah,0x09
    int 0x21                  ; print string

    pop ax
    popf
    ret


ERROR:
    lea dx,[ERROR_MESSAGE]
    call MESSAGE

    ; exit with non-zero status code
    mov ah,0x4c
    mov al,0x01
    int 0x21

include '../common/savefile.asm'
include '../common/memory.asm'