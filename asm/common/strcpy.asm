; STRCPY.ASM
; Author: Michael C. Maggio
;
; Utility functions for string copy operations.

STRCPY:
    ; parameters
    ;  ds:si = source address
    ;  ds:di = destination address

    pushf
    push cx

    mov cx,0xffff
    call STRNCPY

    pop cx
    popf
    ret


STRNCPY:
    ; parameters
    ;  ds:si = source address
    ;  ds:di = destination address
    ;  cx = max length to copy

    pushf
    push cx
    push si
    push di
    push es

    ; set es = ds
    push ds
    pop es

    ; clear direction flag
    cld

  STRNCPY_LOOP:
    lodsb
    and al,al
    stosb
    loopnz STRNCPY_LOOP

    pop es
    pop di
    pop si
    pop cx
    popf
    ret