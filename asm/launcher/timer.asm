
OLD_CLOCK_INT			dd  0				; location of old int 0x08
OLD_TIMER_INT			dd  0				; location of old int 0x1c
OLD_TIMER_CONTROL_INT	dd  0				; location of old int 0x64
CLOCK_COUNTER			dw  0x0001
CLOCK_SPEED				dw  0x0001
TIMER_COUNTER			dw  0

; The clock interrupt (INT 0x08) is normally called 18.2 times every second.
; However, it may be adjusted by a call to INT 0x64 fcn 0x00 .  If so, use this
; replacement interrupt handler to ensure the old INT 0x08 is called at the
; appropriate frequency, thus ensuring the system clock updates properly while
; the custom timer interrupt (INT 0x1C) is called at the new frequency.
CLOCK_INT:
    push ax

    ; always call the custom timer int (0x1c)
    int 0x1c                    ; custom timer

    ; decrement counter
    dec word [cs:CLOCK_COUNTER]
    jnz CLOCK_INT_RETURN

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


; Alternate implementation of INT 0x08 that does not update the clock or
; invoke INT 0x1C.  Used for high-frequency interrupts where performance is
; important.  Activated by INT 0x64 fcn 04 and deactivated by INT 0x64 fcn 05.
; It's recommended that users of this implementation manually update the clock
; as needed.
NO_CLOCK_INT:
	push ax

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
; be set by calling INT 0x64 (AH=02) or obtained by INT 0x64 (AH=03).
TIMER_INT:
    ; do not decrement counter if it's at 0
    cmp word [cs:TIMER_COUNTER],0x0000
    je TIMER_INT_RETURN
    ; otherwise decrement counter
    dec word [cs:TIMER_COUNTER]

  TIMER_INT_RETURN:
    ; chain with the previous interrupt
    jmp far [cs:OLD_TIMER_INT]


; The timer control interrupt (INT 0x64) allows the application to configure
; timer.
TIMER_CONTROL_INT:
	; parameters:
	;  ah = function
	;  (additional params/returns by function)
	push bx

	; fcn 00 = set clock speed
	;	dx = multiplier
    cmp ah,0x00
    je TIMER_CONTROL_INT_SET_CLOCK_SPEED

	; fcn 01 = get clock speed
	;   returns: dx = multiplier
	cmp ah,0x01
	je TIMER_CONTROL_INT_GET_CLOCK_SPEED

    ; fcn 02 = set timer 0
	;	cx = counter value
    cmp ah,0x02
    je TIMER_CONTROL_INT_SET_TIMER

    ; fcn 03 = get timer 0
	;	returns: cx = counter value
    cmp ah,0x03
    je TIMER_CONTROL_INT_GET_TIMER

    ; fcn 04 = disable clock
    cmp ah,0x04
    je TIMER_CONTROL_INT_DISABLE_CLOCK

    ; fcn 05 = enable clock
    cmp ah,0x05
    je TIMER_CONTROL_INT_ENABLE_CLOCK

    ; fcn 06 = update clock
	;   cx = number of clock ticks
    cmp ah,0x06
    je TIMER_CONTROL_INT_UPDATE_CLOCK

    ; fcn 07 = get cpu speed
	;   returns: ax = number of loop iterations 
    cmp ah,0x07
    je TIMER_CONTROL_INT_GET_CPU_SPEED

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

  TIMER_CONTROL_INT_DISABLE_CLOCK:
    ; replace int 0x08 with cs:NO_CLOCK_INT
    lea bx,[cs:NO_CLOCK_INT]
	call REPLACE_INT_08_VECTOR
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_ENABLE_CLOCK:
    ; replace int 0x08 with cs:CLOCK_INT
    lea bx,[cs:CLOCK_INT]
	call REPLACE_INT_08_VECTOR
    jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_UPDATE_CLOCK:
	; passes cx = number of clock ticks
	call UPDATE_SYSTEM_CLOCK
	jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_GET_CPU_SPEED:
	; returns: ax = number of loop iterations 
	call GET_CPU_SPEED
	jmp TIMER_CONTROL_INT_RETURN

  TIMER_CONTROL_INT_RETURN:
	pop bx
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


REPLACE_INT_08_VECTOR:
	; parameters:
	;  cs:bx = new function
	push ax
	push es
	cli

	; set int 0x08 = es:bx
    mov al,0x08
	push cs
	pop es
    call REPLACE_VECTOR

	sti
	pop es
	pop ax
	ret


UPDATE_SYSTEM_CLOCK:
	; parameters:
	;  cx = number of clock ticks to update

	pushf
	push ax
	push bx
	push cx
	push dx

	; set bx = number of clock ticks
	mov bx,cx

	; read the clock into cx:dx
	mov ah,0x00
	int 0x1a		; fcn 0x00 = read the clock

	; add clock ticks to cx:dx
	add dx,bx
	adc cx,0x00

	; set the clock using cx:dx
	mov ah,0x01
	int 0x1a		; fcn 0x01 = set the clock

  UPDATE_SYSTEM_CLOCK_RETURN:
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret


GET_CPU_SPEED:
	; returns:
	;  ax = number of loop iterations 
	pushf
	push cx

	; set counter = 0x0002
    mov word [cs:TIMER_COUNTER],0x0010

	; iterate through loop until timer counter or cx hits 0
	mov cx,0xffff
  GET_CPU_SPEED_LOOP:
	cmp word [cs:TIMER_COUNTER],0x0000
	loopnz GET_CPU_SPEED

	; return ax = 0 - counter - 1 (number of iterations)
	mov ax,0x0000
	sub ax,cx
	dec ax

	pop cx
	popf
	ret


include 'vector.asm'