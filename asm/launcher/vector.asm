SAVE_VECTOR:
	; parameters:
    ;  al = vector #
    ;  ds:dx = location to store old vector

    push ax
    push bx
    push di
    push es

    ; get interrupt vector al in es:bx
    mov ah,0x35
    int 0x21                ; get interrupt vector

    mov di,dx

    ; save es:bx address at ds:di
    mov ax,es
    mov [di+0x00],bx
    mov [di+0x02],ax

    pop es
    pop di
    pop bx
    pop ax
    ret


REPLACE_VECTOR:
	; parameters:
    ;  al = vector #
    ;  es:bx = new vector

    push bx
    push ds

    ; set ds:dx = new vector
    push es
    pop ds
    mov dx,bx

    ; set interrupt vector al with ds:dx
    mov ah,0x25
    int 0x21                ; set interrupt vector

    pop ds
    pop bx
    ret


RESTORE_VECTOR:
	; parameters:
    ;  al = vector #
    ;  ds:dx = location of where old vector address is stored

    push bx
    push si
    push es

    mov si,dx

    ; set es:bx = vector address stored in ds:si
    push ax
    mov bx,[si+0x00]
    mov ax,[si+0x02]
    mov es,ax
    pop ax

    call REPLACE_VECTOR

    pop es
    pop si
    pop bx
    ret