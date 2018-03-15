; STRCPY.ASM
; Author: Michael C. Maggio
;
; Utility functions for string copy operations.

STRCPY:
    ; parameters
    ;  ds:si = source address
    ;  es:di = destination address

    pushf
    push ax
    push cx
    push si
    push di
    push es

    ; clear direction flag
    cld

    mov cx,0xffff
  STRCPY_LOOP:
    lodsb
    and al,al
    stosb
    loopnz STRCPY_LOOP

    pop es
    pop di
    pop si
    pop cx
    pop ax
    popf
    ret


STRNCPY:
    ; parameters
    ;  ds:si = source address
    ;  es:di = destination address
    ;  cx = length to copy

    pushf
    push ax
    push cx
    push si
    push di
    push es

    ; clear direction flag
    cld

  STRNCPY_LOOP:
    lodsb
    and al,al
    stosb
    loopnz STRNCPY_LOOP

    and cx,cx
    jz STRNCPY_END

    ; initialize any remainder to 0
    mov al,0x00
    rep stosb

  STRNCPY_END:
    pop es
    pop di
    pop si
    pop cx
    pop ax
    popf
    ret

STRLEN:
    ; parameters
    ;  es:di = source address
    ; returns:
    ;  cx = length of string

    pushf
    push ax
    push di

    cld

    mov al,0x00
    mov cx,0xffff
    repnz scasb

    ; calc difference
    not cx
    dec cx

    pop di
    pop ax
    popf
    ret


INT2HEX:
    ; input:
    ;  ax = int
    ;  es:di = dest address
    ; output:
    ;  es:di -> str

    pushf
    push ax
    push bx
    push cx
    push di

    mov bx,ax

    cld

    ; loop through 4 nybbles
    mov cx,0x0004
  INT2HEX_LOOP:
    mov al,bl
    and al,0x0f
    cmp al,0x09
    ja INT2HEX_ALPHA

  INT2HEX_NUMERIC:
    ; values b/w 0 and 9 add +30 to get ascii number
    add al,0x30
    jmp INT2HEX_WRITE

  INT2HEX_ALPHA:
    ; values b/w 0xa (10) and 0xf (15) add +61 to get hex letter
    add al,0x61

  INT2HEX_WRITE:
    stosb
    shr bx,4
    loopnz INT2HEX_LOOP

    pop di
    pop cx
    pop bx
    pop ax
    popf
    ret