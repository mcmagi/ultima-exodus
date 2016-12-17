; SFXFAR.ASM
; Author: Michael C. Maggio
;
; Soundfx driver wrapper functions that manage receipt of the far call from the
; main program.  Sets the data segment (ds) register before calling the actual
; driver implementation, then does a far-return (retf).

; Sets ds to the local data segment
SET_SEGMENT:
    ; set ds = local data segment (cs - 0x10 paragraphs)
    ;  (Previously, when I was using a86, all data addresses were +0x100 bytes
    ;   greater than the code segment, so we needed to adjust ds. This is no
    ;   longer necessary with fasm. Now the two segment registers can be equal.)
    push cs
    pop ds
    ret


; ===== far functions here (jumped to from above) =====
INIT_DRIVER_FAR:
	push ds
	call SET_SEGMENT
	call INIT_DRIVER
	pop ds
	retf

CLOSE_DRIVER_FAR:
    push ds
    call SET_SEGMENT
    call CLOSE_DRIVER
    pop ds
    retf

INVALID_ACTION_FAR:
	push ds
	call SET_SEGMENT
	call INVALID_ACTION
	pop ds
	retf

INVALID_COMMAND_FAR:
	push ds
	call SET_SEGMENT
	call INVALID_COMMAND
	pop ds
	retf

SPELL_FAR:
	push ds
	call SET_SEGMENT
	call SPELL
	pop ds
	retf

FORCE_FIELD_FAR:
	push ds
	call SET_SEGMENT
	call FORCE_FIELD
	pop ds
	retf

ATTACK_FAR:
	push ds
	call SET_SEGMENT
	call ATTACK
	pop ds
	retf

TRAP_EVADED_FAR:
	push ds
	call SET_SEGMENT
	call TRAP_EVADED
	pop ds
	retf

MOONGATE_FAR:
	push ds
	call SET_SEGMENT
	call MOONGATE
	pop ds
	retf

FIRE_FAR:
	push ds
	call SET_SEGMENT
	call FIRE
	pop ds
	retf

DAMAGE_FAR:
	push ds
	call SET_SEGMENT
	call DAMAGE
	pop ds
	retf

MOVEMENT_FAR:
	push ds
	call SET_SEGMENT
	call MOVEMENT
	pop ds
	retf

AOE_SPELL_FAR:
	push ds
	call SET_SEGMENT
	call AOE_SPELL
	pop ds
	retf

WHIRLPOOL_FAR:
	push ds
	call SET_SEGMENT
	call WHIRLPOOL
	pop ds
	retf

DRAGON_BREATH_FAR:
	push ds
	call SET_SEGMENT
	call DRAGON_BREATH
	pop ds
	retf

TOGGLE_SPEAKER_FAR:
	push ds
	call SET_SEGMENT
	call TOGGLE_SPEAKER
	pop ds
	retf