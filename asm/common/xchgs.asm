; XCHGS.ASM
; Author: Michael C. Maggio
;
; This file contains xchgs functions that operate on ds:si and es:di
; in the same manner as the movs instructions, but exchange the values at
; the source and destination instead.  These are functions, not macros, and
; therefore must be called.

; A function that simulates "rep xchgsb" instructions
REP_XCHGSB:
    ; parameters:
    ;  cx = number of times to repeat
    ;  ds:si => data 1
    ;  es:di => data 2
    ;  direction flag = direction to advance si/di (clear if forward)

    call XCHGSB
    loop REP_XCHGSB
    ret

; A function that simulates an "xchgsb" instruction
XCHGSB:
    ; parameters:
    ;  ds:si => data 1
    ;  es:di => data 2
    ;  direction flag = direction to advance si/di (clear if forward)

    push ax
    mov al,[di]
    movsb
    mov [si-01],al
    pop ax
    ret

; A function that simulates "rep xchgsw" instructions
REP_XCHGSW:
    ; parameters:
    ;  cx = number of times to repeat
    ;  ds:si => data 1
    ;  es:di => data 2
    ;  direction flag = direction to advance si/di (clear if forward)

    call XCHGSW
    loop REP_XCHGSW
    ret

; A function that simulates an "xchgsw" instruction
XCHGSW:
    ; parameters:
    ;  ds:si => data 1
    ;  es:di => data 2
    ;  direction flag = direction to advance si/di (clear if forward)

    push ax
    mov ax,[di]
    movsw
    mov [si-02],ax
    pop ax
    ret
