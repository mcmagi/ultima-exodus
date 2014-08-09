; SFXTEST.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade test program used to test sound effects.

jmp START

;===========DATA===========

;SFX_DRV			db	"SFX.DRV",0
SFX_DRV			db	"SFXTIMED.DRV",0
SFX_DRV_ADDR	dd	0
FREE_ERROR      db  "Error releasing memory for driver",0x0a,0x0d,"$"
FILE_ERROR      db  "Error reading "
FILE_ERROR_NAME db  "            ",0x0a,0x0d,"$"
COMMAND			db	0
I_FLAG          db  0

;===========CODE===========

START:
    ; resize memory block to 0xa00 (2560) bytes
    mov ah,0x4a
    mov bx,0x00a0
    int 0x21                  ; resize

    ; move stack to end of memory block
    mov ax,cs
    mov ss,ax
    mov sp,0x09fe

    ; set ds = cs + 0x10
    mov ax,cs
    add ax,0x0010
    mov ds,ax
    mov es,ax

    ; set new interrupt vectors
    call SET_VECTORS

    ; load sfx driver and store segment address in memory
	lea dx,[SFX_DRV]
    call LOAD_DRIVER
    lea bp,[SFX_DRV_ADDR]
    mov [ds:bp+0x02],ax

	; get requested function
	call GET_ARGS
	mov al,[COMMAND]

	; call init
    call far [ds:bp]

	; convert to driver offset
	mov dl,0x03
	mul dl
	add ax,0x0003

	; invoke requested function
	mov bx,0x04e0
	mov dl,0x7f
    mov [ds:bp],ax
    call far [ds:bp]

    ; check if sfx driver was loaded
    lea bx,[SFX_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz EXIT

    ; free video driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz EXIT

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  EXIT:
    ; set errorlevel for exit
    mov al,0x00
	jmp TERMINATE

  ERROR_EXIT:
  TERMINATE:
    ; reset the interrupt vectors
    call RESET_VECTORS

    ; exit with errorlevel al
    mov ah,0x4c
    int 0x21                ; exit


GET_ARGS:
	push ax
	push bx
	push dx

	mov bx,0x0082
	mov dl,0x00

  GET_ARGS_NEXT_BYTE:
	; read next byte
	mov al,byte [cs:bx]

	; check if asii number
	cmp al,0x30
	jb GET_ARGS_NOT_A_NUMBER
	cmp al,0x39
	ja GET_ARGS_NOT_A_NUMBER

	; convert to number, save to dh
	sub al,0x30
	mov dh,al

	; multiply any existing number in dl by 10 since we have another digit
	mov al,0x0a
	mul dl

	; add in new number, save in dl
	add al,dh
	mov dl,al
	jo GET_ARGS_OVERFLOW

	; advance pointer
	inc bx
	jmp GET_ARGS_NEXT_BYTE

  GET_ARGS_NOT_A_NUMBER:
	; if non-number hit, assume end of input
	mov [COMMAND],dl

  GET_ARGS_OVERFLOW:
	pop dx
	pop bx
	pop ax
	ret


LOAD_DRIVER:
    ; parameters:
    ;  ds:dx = offset to driver name
    ; returns:
    ;  ax:0000 = segment:offset of loaded driver

    pushf
    push cx
    push dx
    push si
    push di

    ; load driver
    mov al,0x01
    xor cx,cx
    call LOAD_FILE

    ; handle failure
    cmp ax,0xffff
    jnz LOAD_DRIVER_SUCCESS

    ; copy filename to error msg
    mov si,dx
    mov di,FILE_ERROR_NAME
    call STRCPY

    ; print error message
    mov dx,FILE_ERROR
    call ERROR

  LOAD_DRIVER_SUCCESS:
    pop di
    pop si
    pop dx
    pop cx
    popf
    ret


SET_VECTORS:
    push ax
    push dx

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

  RESET_VECTORS_RETURN:
    ; return
    pop dx
    pop ax
	popf
    ret


MESSAGE:
    ; parameters:
    ;  dx = address of message text

    pushf
    push ax

    ; print message
    mov ah,0x09
    int 0x21                ; print string

    pop ax
    popf
    ret


ERROR:
    call MESSAGE

    ; exit with errorlevel 1
    mov al,0x01
    jmp ERROR_EXIT


; include supporting files
include '../common/strcpy.asm'
include '../common/loadfile.asm'
include '../launcher/timer.asm'