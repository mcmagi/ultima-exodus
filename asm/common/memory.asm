; MEMORY.ASM
; Author: Michael C. Maggio
;
; Utility functions for allocating/freeing memory.

ALLOCATE_MEMORY:
    ; parameters:
    ;  ax = number of bytes requested
    ; returns:
    ;  ax = segment address of memory block or -1 on failure

    pushf
    push bx

    ; ax /= 16, rounding up (get number of paragraphs)
    shr ax,1
    adc ax,0x0000
    shr ax,1
    adc ax,0x0000
    shr ax,1
    adc ax,0x0000
    shr ax,1
    adc ax,0x0000

    ; allocate memory
    mov bx,ax
    mov ah,0x48
    int 0x21
    jnc ALLOCATE_DONE

    ; on error
    mov ax,0xffff

  ALLOCATE_DONE:
    pop bx
    popf
    ret


FREE_MEMORY:
    ; parameters:
    ;  ax = segment address of memory block
    ; returns:
    ;  ax = 0 on success, -1 on failure

    pushf
    push es

    ; free memory
    mov es,ax
    mov ah,0x49
    int 0x21
    jnc FREE_SUCCESS

    ; on error
    mov ax,0xffff
    jmp FREE_DONE

  FREE_SUCCESS:
    xor ax,ax

  FREE_DONE:
    pop es
    popf
    ret