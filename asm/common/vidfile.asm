; VIDFILE.ASM
; Author: Michael C. Maggio
;
; Common video driver functions for loading/releasing graphic data files.

; ===== file handling functions here =====

LOAD_GRAPHIC_FILE:
    ; parameters:
    ;  ds:dx => name of graphic file
    ;  ds:bx => graphic file address
    ; returns:
    ;  ds:bx => graphic file address
    ;  carry flag clear on success, set on error
    
    push ax
    push bx
    push cx

    clc

    ; make sure it wasn't already loaded
    mov ax,[bx]
    and ax,ax
    jnz LOAD_GRAPHIC_DONE
    mov ax,[bx+0x02]
    and ax,ax
    jnz LOAD_GRAPHIC_DONE

    mov al,0x01
    xor cx,cx
    call LOAD_FILE

    ; check for success
    cmp ax,0xffff
    jnz LOAD_GRAPHIC_SUCCESS

    ; indicate error
    stc
    jmp LOAD_GRAPHIC_DONE

  LOAD_GRAPHIC_SUCCESS:
    ; save address
    mov [bx+0x02],ax
    clc

  LOAD_GRAPHIC_DONE:
    pop cx
    pop bx
    pop ax
    ret


FREE_GRAPHIC_FILE:
    ; parameters
    ;  ds:bx => graphic file address
    ; returns
    ;  carry flag clear on success, set on error

    push ax

    ; get segment to free
    mov ax,[bx+0x02]

    ; already freed - consider it successful
    and ax,ax
    jz FREE_GRAPHIC_SUCCESS

    ; free it
    call FREE_MEMORY

    ; check for success
    cmp ax,0xffff
    jnz FREE_GRAPHIC_SUCCESS

    ; indicate error
    stc
    jmp FREE_GRAPHIC_DONE

  FREE_GRAPHIC_SUCCESS:
    ; clear saved segment address
    mov word [bx+0x02],0x0000
    clc

  FREE_GRAPHIC_DONE:
    pop ax
    ret


include '../common/loadfile.asm'
