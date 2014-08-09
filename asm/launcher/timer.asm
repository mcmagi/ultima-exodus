
OLD_CLOCK_INT			dd  0				; location of old int 0x08
OLD_TIMER_INT			dd  0				; location of old int 0x1c
OLD_TIMER_CONTROL_INT	dd  0				; location of old int 0x64
CLOCK_COUNTER			dw  0x0001
CLOCK_SPEED				dw  0x0001
TIMER_COUNTER			dw  0
TIMER_CALLBACK_ENABLED	db  0				; whether int 0x1c programmable callback is enabled
TIMER_CALLBACK_ADDR		dd  0				; location of int 0x1c programmable callback

; The clock interrupt (INT 0x08) is normally called 18.2 times every second.
; However, it may be adjusted by a call to SET_CLOCK_SPEED.  If so, use this
; replacement interrupt handler to ensure the old INT 0x08 is called at the
; appropriate frequency, thus ensuring the system clock updates properly while
; the custom timer interrupt (INT 0x1C) is called at the new frequency.
CLOCK_INT:
    push ax

    ; decrement counter
    dec word [cs:CLOCK_COUNTER]
    jz CLOCK_INT_UPDATE

    ; only call the custom timer int (0x1c)
    int 0x1c                    ; custom timer
    jmp CLOCK_INT_RETURN

  CLOCK_INT_UPDATE:
    ; when counter hits zero, call the old clock int (0x08),
    ; this will also call the custom timer int (0x1c)
    pushf                           ; pushf simulates INT call so iret works
    call far [cs:OLD_CLOCK_INT]

    ; also reset counter
    mov ax,[cs:CLOCK_SPEED]
    mov [cs:CLOCK_COUNTER],ax

  CLOCK_INT_RETURN:
    ; re-enable lower-level interrupts
    ; (not sure why this is needed yet)
    mov al,0x20
    out 0x20,al

    pop ax
    iret


; The timer interrupt (INT 0x1C) is normally called 18.2 times every second.
; However, it may be adjusted by a call to SET_CLOCK_SPEED.  If so, this int
; will be called at the new frequency.  It is used to decrement the counter
; variable at TIMER_COUNTER to 0.  Does not decrement past 0.  The counter can
; be set by calling INT 0x64 (AH=02) or obtained by INT 64 (AH=03).
TIMER_INT:
    ; do not decrement counter if it's at 0
    cmp word [cs:TIMER_COUNTER],0x0000
    jz TIMER_INT_CALLBACK
    ; otherwise decrement counter
    dec word [cs:TIMER_COUNTER]

  TIMER_INT_CALLBACK:
	; check if timer callback is enabled
	cmp byte [cs:TIMER_CALLBACK_ENABLED],0x00
	jz TIMER_INT_RETURN

	; if so, make a far call to it (expect iret return)
	pushf
	call far [cs:TIMER_CALLBACK_ADDR]

  TIMER_INT_RETURN:
    ; chain with the previous interrupt
    jmp far [cs:OLD_TIMER_INT]


; The timer control interrupt (INT 0x64) allows the application to configure
; timer.
TIMER_CONTROL_INT:
	; parameters:
	;  ah = function
	;  (additional params/returns by function)
	push ax
    push bx

	; fcn 00 = set clock speed
	;	dx = multiplier
    cmp ah,0x00
    jz TIMER_CONTROL_INT_SET_CLOCK_SPEED

	; fcn 01 = get clock speed
	;   returns: dx = multiplier
	cmp ah,0x01
	jz TIMER_CONTROL_INT_GET_CLOCK_SPEED

    ; fcn 02 = set timer 0
	;	cx = counter value
    cmp ah,0x02
    jz TIMER_CONTROL_INT_SET_TIMER

    ; fcn 03 = get timer 0
	;	returns: cx = counter value
    cmp ah,0x03
    jz TIMER_CONTROL_INT_GET_TIMER

    ; fcn 04 = set timer callback
	;	es:di = int 0x1c callback location
    cmp ah,0x04
    jz TIMER_CONTROL_INT_SET_CALLBACK

    ; fcn 05 = clear callback
    cmp ah,0x05
    jz TIMER_CONTROL_INT_CLEAR_CALLBACK

    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_SET_CLOCK_SPEED:
	; passes dx = multiplier
	call SET_CLOCK_SPEED
	jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_GET_CLOCK_SPEED:
	; returns dx = multiplier
	mov dx,[cs:CLOCK_SPEED]
	jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_SET_TIMER:
    ; sets counter to cx
    mov [cs:TIMER_COUNTER],cx
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_GET_TIMER:
    ; returns cx=counter
    mov cx,[cs:TIMER_COUNTER]
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_SET_CALLBACK:
	push es
	pop ax
	mov word [cs:TIMER_CALLBACK_ADDR+0x02],ax		; segment
	mov word [cs:TIMER_CALLBACK_ADDR+0x00],di		; offset
	mov byte [cs:TIMER_CALLBACK_ENABLED],0x01		; enables callbacks to the above addr
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_CLEAR_CALLBACK:
	mov byte [cs:TIMER_CALLBACK_ENABLED],0x00		; disables callbacks to the configured addr
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_RETURN:
    pop bx
	pop ax
    iret


SET_TIMER_VECTORS:
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

    ; save old int 0x08 to ds:OLD_CLOCK_INT
    ; and replace it with cs:CLOCK_INT
    mov al,0x08
    lea dx,[OLD_CLOCK_INT]
    call SAVE_VECTOR
    lea bx,[CLOCK_INT]
    call REPLACE_VECTOR

    ; save old int 0x1c to ds:OLD_TIMER_INT
    ; and replace it with cs:TIMER_INT
    mov al,0x1c
    lea dx,[OLD_TIMER_INT]
    call SAVE_VECTOR
    lea bx,[TIMER_INT]
    call REPLACE_VECTOR

    ; save old int 0x64 to ds:OLD_TIMER_CONTROL_INT
    ; and replace it with cs:TIMER_CONTROL_INT
    mov al,0x64
    lea dx,[OLD_TIMER_CONTROL_INT]
    call SAVE_VECTOR
    lea bx,[TIMER_CONTROL_INT]
    call REPLACE_VECTOR

    sti                     ; set interrupt flag

    ; return
    pop es
    pop dx
    pop bx
    pop ax
    popf
    ret
	

RESET_TIMER_VECTORS:
    pushf
    push ax
    push dx

    cli                     ; clear interrupt flag

    ; restore old int 0x08 at ds:OLD_CLOCK_INT
    mov al,0x08
    lea dx,[OLD_CLOCK_INT]
    call RESTORE_VECTOR

    ; restore old int 0x1c at ds:OLD_TIMER_INT
    mov al,0x1c
    lea dx,[OLD_TIMER_INT]
    call RESTORE_VECTOR

    ; restore old int 0x64 at ds:OLD_TIMER_CONTROL_INT
    mov al,0x64
    lea dx,[OLD_TIMER_CONTROL_INT]
    call RESTORE_VECTOR

    sti                     ; set interrupt flag

    ; return
    pop dx
    pop ax
    popf
    ret


; This function is used to change the frequency at which INT 0x08 is called.
; It should be used in tandem with the custom CLOCK_INT function to ensure the
; system time updates properly.
SET_CLOCK_SPEED:
	; parameters:
    ;  dx = clock accelleration factor (01 for normal, 02 for twice as fast, etc)

    pushf
    push ax
	push bx
    push dx

    ; check bounds
    cmp dx,0x0000
    jz SET_CLOCK_SPEED_RETURN

    ; save new speed in CLOCK_SPEED
    mov [cs:CLOCK_SPEED],dx

    ; set channel 0 to mode 3
    mov al,0x36			; 00,11,011,0 = counter 0, lsb->msb, mode 3, binary
    out 0x43,al			; PIT control port

    ; if dx == 1 (normal) just set output word to 0,
    ; otherwise we need to do some division
    cmp dx,0x0001
    jnz SET_CLOCK_SPEED_DIVIDE
    mov ax,0x0000
    jmp SET_CLOCK_SPEED_OUTPUT

  SET_CLOCK_SPEED_DIVIDE:
    ; ax = 64k / dx
    mov bx,dx
    mov dx,0x0001
    mov ax,0x0000
    div bx

  SET_CLOCK_SPEED_OUTPUT:
    ; write word to counter 0
    out 0x40,al			; lsb
    mov al,ah
    out 0x40,al			; msb

  SET_CLOCK_SPEED_RETURN:
    pop dx
	pop bx
    pop ax
    popf
    ret


include 'vector.asm'