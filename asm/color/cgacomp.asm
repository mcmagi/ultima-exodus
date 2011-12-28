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
COMPOSITE_RGB_PALETTE   db      0,0,0,    0,108,108,   18,5,149,    0,189,253
                        db      170,76,0, 16,160,63,   185,162,173, 150,240,255
                        db      198,0,34, 167,205,255, 220,117,255, 185,195,255
                        db      206,45,0, 237,255,204, 255,178,166, 255,255,255

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