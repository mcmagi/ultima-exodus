; SFX.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade PC Speaker soundfx driver.

; ===== start jumps into code here =====
include 'sfxjmp.asm'

SYSTEM_DATE_1	dw	0,0
SYSTEM_TIME_1	dw	0,0
SYSTEM_DATE_2	dw	0,0
SYSTEM_TIME_2	dw	0,0


; ===== sound driver functions here =====

INIT:
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


INVALID_ACTION:
    push bx
    push cx

    ; store speaker status
    in al,0x61
    push ax

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
    dec dh
    jnz MOONGATE_LOOP_2_DELAY_1
    out 0x61,al
    xor al,0x02
    mov dh,cl
  MOONGATE_LOOP_2_DELAY_2:
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

  FORCE_FIELD_LOOP:
	; get random b/w 0-f
	mov dh,0x0f
	call GET_RANDOM_NUMBER

	adc dl,bl
  FORCE_FIELD_INNER_LOOP:
	mov cx,0x0003
  FORCE_FIELD_DELAY:
	loop FORCE_FIELD_DELAY
	dec dl
	jnz FORCE_FIELD_INNER_LOOP
	out 0x61,al
	xor al,0x02
	dec bh
	jnz FORCE_FIELD_LOOP

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
  ATTACK_LOOP:
	out 0x61,al
	xor al,0x02
	mov bh,bl
  ATTACK_DELAY:
	inc bh
	jnz ATTACK_DELAY
	dec bl
	jnz ATTACK_LOOP
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
  TRAP_EVADED_LOOP:
	mov cl,bh
  TRAP_EVADED_DELAY:
	dec cx
	jnz TRAP_EVADED_DELAY
	out 0x61,al
	xor al,0x02
	dec bh
	jnz TRAP_EVADED_LOOP
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
  FIRE_LOOP:
	call GET_RANDOM_NUMBER
	or dl,bl
  FIRE_DELAY:
	dec dl
	jnz FIRE_DELAY
	out 0x61,al
	xor al,0x02
	dec bl
	cmp bl,bh
	jnz FIRE_LOOP
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
  STEP_LOOP:
	call GET_RANDOM_NUMBER
	or dl,bh
  STEP_DELAY:
	dec dl
	jnz STEP_DELAY
	out 0x61,al
	xor al,0x02
	dec bl
	jnz STEP_LOOP
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

  AOE_SPELL_LOOP:
	mov dh,0xff
	call GET_RANDOM_NUMBER

	mov ch,0x28
  AOE_SPELL_INNER_LOOP:
	mov dh,dl
  AOE_SPELL_DELAY:
	dec dh
	jnz AOE_SPELL_DELAY

	out 0x61,al
	xor al,0x02
	dec ch
	jnz AOE_SPELL_INNER_LOOP
	dec cl
	jnz AOE_SPELL_LOOP
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
	and al,0xfc
	mov bl,0x40
  WHIRLPOOL_LOOP:
	mov bh,0x1e
  WHIRLPOOL_INNER_LOOP:
	mov cl,bl
  WHIRLPOOL_DELAY:
	dec cl
	jnz WHIRLPOOL_DELAY
	out 0x61,al
	xor al,0x02
	dec bh
	jnz WHIRLPOOL_INNER_LOOP
	inc bl
	cmp bl,0xc0
	jb WHIRLPOOL_LOOP
	pop ax
	out 0x61,al
	pop cx
	pop bx
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


; ===== far functions here (jumped to from above) =====
include 'sfxfar.asm'
