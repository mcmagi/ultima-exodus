; SFX.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade PC Speaker soundfx driver.

; ===== start jumps into code here =====
include 'sfxjmp.asm'

SYSTEM_DATE_1		dw	0,0
SYSTEM_TIME_1		dw	0,0
SYSTEM_DATE_2		dw	0,0
SYSTEM_TIME_2		dw	0,0
OLD_CLOCK_SPEED		dw	0
INTERRUPT_COUNT		dd	0


; ===== sound driver functions here =====

INIT_DRIVER:
	push cx
	push dx

	; save system time
	mov ah,0x2c
	int 0x21
	mov [SYSTEM_TIME_2+0x02],dx		; second,100th second
	mov [SYSTEM_TIME_1+0x02],dx		; second,100th second
	mov [SYSTEM_TIME_2+0x00],cx		; hour,minute
	mov [SYSTEM_TIME_1+0x00],cx		; hour,minute

	; save system date
	mov ah,0x2c
	int 0x21
	mov [SYSTEM_DATE_2+0x02],dx		; month,day
	mov [SYSTEM_DATE_1+0x02],dx		; month,day
	mov [SYSTEM_DATE_2+0x00],cx		; year
	mov [SYSTEM_DATE_1+0x00],cx		; year

	pop dx
	pop cx
	ret


CLOSE_DRIVER:
    ; no resources to free
    ret


INVALID_ACTION:
	mov ax,0x3e80		; counter = 16000 (dec) -> 74 Hz (D2)
	;mov cx,0x7d70		; loop for 32112 (dec) instructions
	mov cx,0x0020
	jmp PLAY_NOTE
    push bx
    push cx

    ; store speaker status
    in al,0x61
    push ax

	mov al,0xb6			; 10,11,011,0 = counter 2, lsb->msb, mode 3, binary
	out 0x43,al
	mov ax,0x3d33
	out 0x42,al			; lsb
	mov al,ah
	out 0x42,al			; msb

	; clear bits 0-1 of al (to turn speaker off)
    and al,0xfc			; xxxxxx,0,0 = unchanged, disable speaker, disable timer 2

    ; loop 16 (dec) times (duration)
    mov cx,0x0010
  INVALID_ACTION_OUTER_LOOP:
    ; change status of speaker
    out 0x61,al

    ; invert bit 1 of al for next loop
    xor al,0x02			; xxxxxx,0/1,x = unchanged, toggle speaker, unchanged

    ; the next two loops do nothing but waste time

    ; loop once (um, why???)
    mov di,0x0001
  INVALID_ACTION_DELAY_LOOP:
    ; loop 1000 (dec) times (period b/w speaker toggle)
    mov bx,0x03e8
  INVALID_ACTION_INNER_DELAY_LOOP:
    dec bx
    jnz INVALID_ACTION_INNER_DELAY_LOOP

    dec di
    jnz INVALID_ACTION_DELAY_LOOP

    loop INVALID_ACTION_OUTER_LOOP

    ; restore original speaker status
    pop ax
    out 0x61,al

    pop cx
    pop bx
    ret


INVALID_COMMAND:
	mov ax,0x1630		; counter = 5680 (dec) -> 210 Hz (Ab3)
	;mov cx,0x8670		; loop for 34416 (dec) instructions
	mov cx,0x0023
	jmp PLAY_NOTE
    push bx
    push cx

    ; store speaker status
    in al,0x61
    push ax

    ; clear bits 0-1 of al (to turn speaker off)
    and al,0xfc

    ; loop 48 (dec) times
    mov cx,0x0030

  INVALID_COMMAND_OUTER_LOOP:
    ; change status of speaker
    out 0x61,al

    ; invert bit 1 of al for next loop
    xor al,0x02

    ; the next two loops do nothing but waste time

    ; loop once
    mov di,0x0001
  INVALID_COMMAND_DELAY_LOOP:
    ; loop 355 (dec) times
    mov bx,0x0163
  INVALID_COMMAND_INNER_DELAY_LOOP:
    dec bx
    jnz INVALID_COMMAND_INNER_DELAY_LOOP

    dec di
    jnz INVALID_COMMAND_DELAY_LOOP

    loop INVALID_COMMAND_OUTER_LOOP

    ; restore original speaker status
    pop ax
    out 0x61,al

    ; restore and return
    pop cx
    pop bx
    ret


PLAY_NOTE:
	; ax = frequency divider (1.193182 MHz / ax)
	; cx = duration
    push bx
    push cx

	mov bx,ax
	mov al,0xb6			; 10,11,011,0 = counter 2, lsb->msb, mode 3, binary
	out 0x43,al
	mov ax,bx
	out 0x42,al			; lsb
	mov al,ah
	out 0x42,al			; msb

    ; store speaker status
    in al,0x61
	push ax

	; turn speaker on
	or al,0x03 			; xxxxxx,1,1 = unchanged, enable speaker, enable timer 2
	out 0x61,al

	; loop while counter != 0
  PLAY_NOTE_DELAY:
	hlt					; wait for interrupt
	loop PLAY_NOTE_DELAY

    ; restore original speaker status
    pop ax
	and al,0xfc
    out 0x61,al

    pop cx
    pop bx
    ret


MOONGATE:
    ; input: bh = duration, bl = frequency

    push bx
    push cx
    push dx

    ; store speaker status
    in al,0x61
    push ax

    ; clear bits 0-1 of al (to turn speaker off)
    and al,0xfc

	call CONFIGURE_SFX_TIMER

    ; set ch = 2nd param
    mov ch,bl

    ; loop 26 (dec) times (from 1-26, ends on 27)
    mov cl,0x01

  MOONGATE_LOOP_1:
    ; set dl = 1st param
    mov dl,bh

    ; loop # of times specified in 2nd param, turning on/off speaker
  MOONGATE_LOOP_1_INNER_LOOP:
    ; set dh = decrementing 2nd param
    mov dh,ch

    ; WAIT

    ; loop # of times specified in 2nd param
    ; (but it gets smaller with each iteration of inner loop)
  MOONGATE_LOOP_1_DELAY_1:
	call WAIT_FOR_INTERRUPT
    dec dh
    jnz MOONGATE_LOOP_1_DELAY_1

    ; SPEAKER

    ; change status of speaker
    out 0x61,al

    ; invert bit 1 of al for next write
    xor al,02

    ; WAIT

    ; loop number of times of loop number
    ; (but it gets longer with each iteration of inner loop)
    mov dh,cl
  MOONGATE_LOOP_1_DELAY_2:
	call WAIT_FOR_INTERRUPT
    dec dh
    jnz MOONGATE_LOOP_1_DELAY_2

    ; TOGGLE SPEAKER QUICKLY

    ; change status of speaker
    out 0x61,al

    ; invert bit 1 of al for next loop
    xor al,0x02

    dec dl
    jnz MOONGATE_LOOP_1_INNER_LOOP

    ; ch--, cl++ (loop number)
    dec ch
    inc cl

	; while cl != 27
    cmp cl,0x1b
    jnz MOONGATE_LOOP_1

    ; loop 27 (dec) times (from 27-1, ends on 0)
	; does pretty much the same as above
  MOONGATE_LOOP_2:
    mov dl,bh
  MOONGATE_LOOP_2_INNER_LOOP:
    mov dh,ch
  MOONGATE_LOOP_2_DELAY_1:
	call WAIT_FOR_INTERRUPT
    dec dh
    jnz MOONGATE_LOOP_2_DELAY_1
    out 0x61,al
    xor al,0x02
    mov dh,cl
  MOONGATE_LOOP_2_DELAY_2:
	call WAIT_FOR_INTERRUPT
    dec dh
    jnz MOONGATE_LOOP_2_DELAY_2
    out 0x61,al
    xor al,0x02
    dec dl
    jnz MOONGATE_LOOP_2_INNER_LOOP

    ; cl--, ch++ (loop number)
    dec cl
    inc ch

    ; while cl != 0
    cmp cl,0x00
    jnz MOONGATE_LOOP_2

	call RESTORE_TIMER

    pop ax
    out 0x61,al
    pop dx
    pop cx
    pop bx
    ret


FORCE_FIELD:
	push bx
	push cx
	push dx
	in al,0x61
	push ax
	and al,0xfc
	mov bh,0x80

	call CONFIGURE_SFX_TIMER

  FORCE_FIELD_LOOP:
	; get random b/w 0-f
	mov dh,0x0f
	call GET_RANDOM_NUMBER

	adc dl,bl
  FORCE_FIELD_INNER_LOOP:
	mov cx,0x0003
  FORCE_FIELD_DELAY:
	call WAIT_FOR_INTERRUPT
	loop FORCE_FIELD_DELAY
	dec dl
	jnz FORCE_FIELD_INNER_LOOP
	out 0x61,al
	xor al,0x02
	dec bh
	jnz FORCE_FIELD_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop dx
	pop cx
	pop bx
    ret


ATTACK:
	push bx
	in al,0x61
	push ax
	and al,0xfc
	mov bl,0xfb

	call CONFIGURE_SFX_TIMER

  ATTACK_LOOP:
	out 0x61,al
	xor al,0x02
	mov bh,bl
  ATTACK_DELAY:
	call WAIT_FOR_INTERRUPT
	inc bh

	jnz ATTACK_DELAY
	dec bl
	jnz ATTACK_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop bx
    ret


TRAP_EVADED:
	push bx
	push cx
	in al,0x61
	push ax
	and al,0xfc
	mov bh,0xa0
	mov ch,0x00

	call CONFIGURE_SFX_TIMER

  TRAP_EVADED_LOOP:
	mov cl,bh
  TRAP_EVADED_DELAY:
	call WAIT_FOR_INTERRUPT
	dec cx
	jnz TRAP_EVADED_DELAY

	out 0x61,al
	xor al,0x02
	dec bh
	jnz TRAP_EVADED_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop cx
	pop bx
    ret


FIRE:
	push bx
	push dx
	in al,0x61
	push ax
	and al,0xfc
	mov dh,0xff
	mov bl,0xe0
	mov bh,0x40

	call CONFIGURE_SFX_TIMER

  FIRE_LOOP:
	call GET_RANDOM_NUMBER
	or dl,bl
  FIRE_DELAY:
	call WAIT_FOR_INTERRUPT
	dec dl
	jnz FIRE_DELAY
	out 0x61,al
	xor al,0x02
	dec bl
	cmp bl,bh
	jnz FIRE_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop dx
	pop bx
    ret


DAMAGE:
	push bx
	mov bh,0x00
	mov bl,0xff
	call STEP
	pop bx
    ret


MOVEMENT:
	push bx
	mov bh,0x00
	mov bl,0x08
	call STEP
	pop bx
    ret


STEP:
	; bh = ?, bl = duration
	mov di,bx
	push dx
	in al,0x61
	push ax
	and al,0xfc
	mov dh,0xff

	call CONFIGURE_SFX_TIMER

  STEP_LOOP:
	call GET_RANDOM_NUMBER
	or dl,bh
  STEP_DELAY:
	call WAIT_FOR_INTERRUPT
	dec dl
	jnz STEP_DELAY

	out 0x61,al
	xor al,0x02
	dec bl
	jnz STEP_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop dx
	mov bx,di
	ret


AOE_SPELL:
	push cx
	push dx
	in al,0x61
	push ax
	and al,0xfc
	and dl,0x0f
	shl dl,1
	add dl,0x08
	mov cl,dl

	call CONFIGURE_SFX_TIMER

  AOE_SPELL_LOOP:
	mov dh,0xff
	call GET_RANDOM_NUMBER

	mov ch,0x28
  AOE_SPELL_INNER_LOOP:
	mov dh,dl
  AOE_SPELL_DELAY:
	call WAIT_FOR_INTERRUPT
	dec dh
	jnz AOE_SPELL_DELAY

	out 0x61,al
	xor al,0x02
	dec ch
	jnz AOE_SPELL_INNER_LOOP
	dec cl
	jnz AOE_SPELL_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop dx
	pop cx
    ret


WHIRLPOOL:
	push bx
	push cx
	in al,0x61
	push ax

	call CONFIGURE_SFX_TIMER

	and al,0xfc
	mov bl,0x40
  WHIRLPOOL_LOOP:
	mov bh,0x1e
  WHIRLPOOL_INNER_LOOP:
	mov cl,bl
  WHIRLPOOL_DELAY:
	call WAIT_FOR_INTERRUPT
	dec cl
	jnz WHIRLPOOL_DELAY
	out 0x61,al
	xor al,0x02
	dec bh
	jnz WHIRLPOOL_INNER_LOOP
	inc bl
	cmp bl,0xc0
	jb WHIRLPOOL_LOOP

	call RESTORE_TIMER

	pop ax
	out 0x61,al
	pop cx
	pop bx
    ret


DRAGON_BREATH:
	push ax
	in al,0x61
	mov ah,al
	and al,0xfc

	call CONFIGURE_SFX_TIMER

	mov dh,0xff
	mov cx,0x0400

  DRAGON_BREATH_LOOP:
	call GET_RANDOM_NUMBER

  DRAGON_BREATH_DELAY:
	call WAIT_FOR_INTERRUPT
	dec dl
	jnz DRAGON_BREATH_DELAY

	; toggle pc speaker
	out 0x61,al
	xor al,0x02

	loop DRAGON_BREATH_LOOP

	call RESTORE_TIMER

	; return pc speaker to initial state
	mov al,ah
	out 0x61,al

	pop ax
	ret


TOGGLE_SPEAKER:
	push ax
	call WAIT_FOR_INTERRUPT
	in al,0x61
	xor al,0x02
	and al,0xfe
	out 0x61,al
	pop ax
	ret


; This function is copied from exodus.bin:0x514b, with the random seed
; (date/time) initialized locally rather than globally.
GET_RANDOM_NUMBER:
	; dh = random number pool size
	; returns dl (where 0 <= dl < dh)
	pushf
	push ax
	push cx
	push si
	push di
	push es

	; set es = ds
	push ds
	pop es

	; set direction flag
	std

	; set counter = 0f
	mov cx,0x000f

	;set si = end of system time & date
	; in exodus.bin this is es:2a93 + 0f = 2aa2, which is the last byte of the
	; second date/time stamp
	lea si,[SYSTEM_DATE_1]
	add si,cx

	; set di = si - 1
	mov di,si
	dec di

	; clear carry
	clc

	; loop (scrambles date/time data to simulate randomness)
  GET_RANDOM_NUMBER_LOOP_1:
	; al = [si--] + [si] + carry
	lodsb
	adc al,[si]

	; store in next byte
	stosb
	loop GET_RANDOM_NUMBER_LOOP_1

	mov cx,0x0010
	lea di,[SYSTEM_DATE_1]
	add di,cx

  GET_RANDOM_NUMBER_LOOP_2:
	dec di
	inc byte [di]
	loopz GET_RANDOM_NUMBER_LOOP_2

	; dl = *es:2a93
	mov dl,byte [SYSTEM_DATE_1]

  GET_RANDOM_NUMBER_LOOP_3:
	; if dl < dh, return
	cmp dl,dh
	jb GET_RANDOM_NUMBER_RETURN

	; otherwise dl -= dh
	sub dl,dh
	jmp GET_RANDOM_NUMBER_LOOP_3

  GET_RANDOM_NUMBER_RETURN:
	pop es
	pop di
	pop si
	pop cx
	pop ax
	popf
	ret


; Waits for the next timer interrupt and counts how many times we've been
; interrupted.
WAIT_FOR_INTERRUPT:
	; wait for next timer interrupt
	hlt
	; track how many times we're interrupted so we can update the clock
	inc dword [INTERRUPT_COUNT]
	ret


; Configures a int 0x08 timer callback at 0x1600 interrupts per each full
; iteration of the counter (~104 kHz), and disables the system clock.
CONFIGURE_SFX_TIMER:
	push ax
	push dx
	push es

	; reset interrupt count
	mov dword [INTERRUPT_COUNT],0x00000000

	; set es:di = ISR at cs:offset
	push cs
	pop es

	; save current clock speed to OLD_CLOCK_SPEED
	mov ah,0x01
	int 0x64					; fcn ah=0x01, get clock speed
	mov [OLD_CLOCK_SPEED],dx

	; disable the clock
	mov ah,0x04
	int 0x64					; fcn ah=0x04, disable clock int

	; increase clock speed
	mov ah,0x00
	mov dx,0x1600
	int 0x64					; fcn ah=0x00, set clock speed

	pop es
	pop dx
	pop ax
	ret


; Returns the int 0x08 callback to its previous state.  Also updates the system
; clock with the number of clock ticks missed (if any) while it was disabled.
RESTORE_TIMER:
	pushf
	push eax
	push ecx
	push edx

	; restore clock speed
	mov ah,0x00
	mov dx,[OLD_CLOCK_SPEED]
	int 0x64				; fcn ah=0x00, set clock speed

	; calculate eax = the # of clock ticks missed (32 bits, yay!)
	;  NOTE: result in eax, but we expect it to be small enough to fit in ax
	mov eax,[INTERRUPT_COUNT]
	mov edx,0x00000000
	mov ecx,0x00001600
	div ecx								; no of interrupts / clock multiplier

	; check if adjustment necessary
	and eax,eax
	jz RESTORE_TIMER_ENABLE_CLOCK

	; adjust the clock
	mov cx,ax
	mov ah,0x06
	int 0x64				; fcn ah=0x06, update clock

  RESTORE_TIMER_ENABLE_CLOCK:
	; re-enable the clock int 0x08
	mov ah,0x05
	int 0x64				; fcn ah=0x05, enable clock int

	pop edx
	pop ecx
	pop eax
	popf
	ret


; ===== far functions here (jumped to from above) =====
include 'sfxfar.asm'
