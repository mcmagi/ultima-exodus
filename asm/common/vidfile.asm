; VIDFILE.ASM
; Author: Michael C. Maggio
;
; Common video driver functions for loading/releasing graphic data files.

; ===== data area here =====

THEME_ID		db		0x04 dup 0
THEME_FILENAME	db		0x20 dup 0

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


LOAD_GRAPHIC_FILE_THEME:
	; parameters:
	;  ax => theme prefix
	;  bx => file address
	;  dx => graphic file name

	pushf
	push dx
	push si

	; si = original filename
	mov si,dx

	; load theme id into memory
	call GET_THEME_ID

	; if 0, jump to load default
	cmp byte [THEME_ID],0x00
	jz LOAD_THEME_FILE_LOAD_DEFAULT

	; dx = theme filename
	call BUILD_THEME_FILENAME

	; load theme file
	call LOAD_GRAPHIC_FILE

	; if no errors, return
	jnc LOAD_THEME_FILE_DONE

	; can't load theme file, fallback to default
	mov dx,si

LOAD_THEME_FILE_LOAD_DEFAULT:
	; load original file
	call LOAD_GRAPHIC_FILE

LOAD_THEME_FILE_DONE:
	pop si
	pop dx
	popf
	ret


GET_THEME_ID:
	; returns:
	;  THEME_ID = theme id

	pushf
	push ax
	push dx
	push di
	push es

	; get theme id (al,dl,dh)
	mov ah,0x06
	int 0x65

	; es:di => theme id memory location
	push ds
	pop es
	lea di,[THEME_ID]

	; store theme id in memory
	stosb
	mov al,dl
	stosb
	mov al,dh
	stosb

	; null-terminate
	mov al,0x00
	stosb

	pop es
	pop di
	pop dx
	pop ax
	popf
	ret
	

BUILD_THEME_FILENAME:
	; parameters:
	;  ax = THEME_PREFIX
	;  THEME_ID = theme id
	;  dx => graphic filename
	; returns:
	;  dx => theme filename

	pushf
	push ax
	push cx
	push si
	push di
	push es

	; set es=ds
	push ds
	pop es

	; cx = length of theme prefix
	mov di,ax
	call STRLEN

	; copy theme dir prefix to theme filename
	mov si,ax
	lea di,[THEME_FILENAME]
	rep movsb

	push di
	lea di,[THEME_ID]
	call STRLEN
	pop di

	; append theme id to theme prefix
	lea si,[THEME_ID]
	rep movsb

	; append path separator
	mov al,0x5c ; '\'
	stosb

	; cx = length of graphic filename
	push di
	mov di,dx
	call STRLEN
	pop di

	; append filename to theme dir
	mov si,dx
	rep movsb

	; null-terminate
	mov al,0x00
	stosb

	; set dx = theme filename
	lea dx,[THEME_FILENAME]

	pop es
	pop di
	pop si
	pop cx
	pop ax
	popf
	ret


include '../common/loadfile.asm'
include '../common/strcpy.asm'
