; STRCPY.ASM
; Author: Michael C. Maggio
;
; Utility functions for string copy operations.

STRCPY:
    ; parameters
    ;  ds:si = source address
    ;  es:di = destination address
    ; returns:
    ;  cx = number of bytes copied

    pushf

    mov cx,0xffff
    call STRNCPY

    popf
    ret


STRNCPY:
    ; parameters
    ;  ds:si = source address
    ;  es:di = destination address
    ;  cx = max length to copy
    ; returns:
    ;  cx = number of byes copied

    pushf
    push dx
    push si
    push di
    push es

    ; set dx = max number of bytes to copy
    mov dx,cx

    ; clear direction flag
    cld

  STRNCPY_LOOP:
    lodsb
    and al,al
    stosb
    loopnz STRNCPY_LOOP

    ; set cx = max counter - counter = number of bytes copied
    xchg cx,dx
    sub cx,dx

    pop es
    pop di
    pop si
    pop dx
    popf
    ret