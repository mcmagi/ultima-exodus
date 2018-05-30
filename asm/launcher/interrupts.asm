; CORE.ASM
; Author: Michael C. Maggio
;
; Interrupt service routines used by the Ultima Upgrade launchers.


; This function is used to replace the MIDPAK interrupt if there is no MIDPAK
; driver loaded.  (INT 0x66)
MIDPAK_INT:
    ; no-op fcn (does nothing)
    iret


; The configuration interrupt (INT 0x65)
CONFIG_INT:
    pushf
    push bx
    push bp

    ; set bx as offset to config data
    lea bx,[CFGDATA]

    ; fcn 00 = autosave check
    cmp ah,0x00
    jz CONFIG_INT_AUTOSAVE

    ; fcn 01 = frame limiter check
    cmp ah,0x01
    jz CONFIG_INT_FRAMELIMITER

    ; fcn 02 = video driver address
    cmp ah,0x02
    jz CONFIG_INT_VIDEO_DRV

    ; fcn 03 = music driver address
    cmp ah,0x03
    jz CONFIG_INT_MUSIC_DRV

    ; fcn 04 = moon phase check
    cmp ah,0x04
    jz CONFIG_INT_MOONPHASE

    ; fcn 05 = mod address
    cmp ah,0x05
    jz CONFIG_INT_MOD

    ; fcn 06 = tileset id
    cmp ah,0x06
    jz CONFIG_INT_TILESET

	; fcn 07 = gameplay fixes check
	cmp ah,0x07
	jz CONFIG_INT_FIXES

	; fcn 08 = sfx driver address
	cmp ah,0x08
	jz CONFIG_INT_SFX_DRV

    jmp CONFIG_INT_RETURN

  CONFIG_INT_AUTOSAVE:
    ; returns al=01 if autosave enabled
    mov al,[cs:bx+0x01]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_FRAMELIMITER:
    ; returns al=01 if frame limiter enabled
    mov al,[cs:bx+0x02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_VIDEO_DRV:
    ; returns dx:ax = video driver address
    mov bp,VIDEO_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+0x02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_MUSIC_DRV:
    ; returns dx:ax = music driver address
    mov bp,MUSIC_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_MOONPHASE:
    ; returns al=01 if moon phases enabled
    mov al,[cs:bx+0x04]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_MOD:
    ; returns dx:ax = mod address
    mov bp,MOD_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]
    jmp CONFIG_INT_RETURN

  CONFIG_INT_TILESET:
    ; returns al=tileset id
    mov al,[cs:bx+0x08]
	jmp CONFIG_INT_RETURN

  CONFIG_INT_FIXES:
    ; returns al=01 if gameplay fixes enabled
    mov al,[cs:bx+0x05]
	jmp CONFIG_INT_RETURN

  CONFIG_INT_SFX_DRV:
    ; returns dx:ax = sfx driver address
    mov bp,SFX_DRV_ADDR
    mov ax,[cs:bp]
    mov dx,[cs:bp+02]

  CONFIG_INT_RETURN:
    pop bp
    pop bx
    popf
    iret


SET_VECTORS:
    push ax
    push dx

	call SET_CUSTOM_VECTORS
	call SET_TIMER_VECTORS

    ; multiply clock speed by 16 (18.2 * 16 = 291.2 Hz)
	mov ah,0x00
    mov dx,0x0010
	int 0x64

    ; set I_FLAG to 01 (indicates we have set new interrupts)
    mov byte [I_FLAG],0x01

    ; return
    pop dx
    pop ax
    ret


SET_CUSTOM_VECTORS:
    pushf
    push ax
    push bx
    push dx
    push es

    cli                     ; clear interrupt flag
    cld                     ; clear direction flag

    ; set es = ds
    push ds
    pop es

    ; save old int 0x65 to ds:OLD_CONFIG_INT
    ; and replace it with cs:CONFIG_INT
    mov al,0x65
    lea dx,[OLD_CONFIG_INT]
    call SAVE_VECTOR
    lea bx,[CONFIG_INT]
    call REPLACE_VECTOR

    ; save old int 0x66 to ds:OLD_MIDPAK_INT
    ; and replace it with cs:MIDPAK_INT
    mov al,0x66
    lea dx,[OLD_MIDPAK_INT]
    call SAVE_VECTOR
    lea bx,[CONFIG_INT]
    call REPLACE_VECTOR

    sti                     ; set interrupt flag

    ; return
    pop es
    pop dx
    pop bx
    pop ax
    popf
    ret


RESET_VECTORS:
    pushf
    push ax
    push dx

    ; I_FLAG will be set to 01 if interrupt vectors have been set
    cmp byte [I_FLAG],0x01
	jnz RESET_VECTORS_RETURN

    ; restore clock speed
	mov ah,0x00
	mov dx,0x0000
	int 0x64

	call RESET_TIMER_VECTORS
	call RESET_CUSTOM_VECTORS

  RESET_VECTORS_RETURN:
    ; return
    pop dx
    pop ax
	popf
    ret


RESET_CUSTOM_VECTORS:
    pushf
    push ax
    push dx

    cli                     ; clear interrupt flag

    ; restore old int 0x65 at ds:OLD_CONFIG_INT
    mov al,0x65
    lea dx,[OLD_CONFIG_INT]
    call RESTORE_VECTOR

    ; restore old int 0x66 at ds:OLD_MIDPAK_INT
    mov al,0x66
    lea dx,[OLD_MIDPAK_INT]
    call RESTORE_VECTOR

    sti                     ; set interrupt flag

    ; return
    pop dx
    pop ax
    popf
    ret


; include supporting files
include 'timer.asm'