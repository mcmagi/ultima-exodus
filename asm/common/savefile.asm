; SAVEFILE.ASM
; Author: Michael C. Maggio
;
; Utility functions for file output operations.

SAVE_FILE:
    ; parameters:
    ;  ds:dx = ptr to filename
    ;  es:di = ptr to data
    ;  cx = bytes to write
    ; returns:
    ;  ax = 00 on success, -1 on failure

    pushf
    push bx
    push cx
    push dx
    push ds

    push cx

    ; open file for writing
    mov ah,0x3c
    xor cx,cx
    int 0x21          ; OPEN
    jc SAVE_FAILURE

    ; save file handle
    mov bx,ax

    pop cx

    ; write data to file
    mov ah,0x40
    push es
    pop ds
    mov dx,di           ; set ds:dx = es:di
    int 0x21            ; WRITE
    jc SAVE_FAILURE

    ; is insufficient bytes on write a failure?

    ; close file
    mov ah,0x3e
    int 0x21          ; CLOSE
    jc SAVE_FAILURE

    mov ax,0x0000
    jmp SAVE_DONE

  SAVE_FAILURE:
    mov ax,0xffff

  SAVE_DONE:
    pop ds
    pop dx
    pop cx
    pop bx
    popf
    ret