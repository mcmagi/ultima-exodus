; SFXJMP.ASM
; Author: Michael C. Maggio
;
; These are all the function jumps at the start of every soundfx driver.
; Each jump is to be far-called by the main program.

jmp INIT_FAR
jmp INVALID_ACTION_FAR
jmp INVALID_COMMAND_FAR
jmp MOONGATE_FAR
jmp FORCE_FIELD_FAR
jmp ATTACK_FAR
jmp TRAP_EVADED_FAR
jmp FIRE_FAR
jmp DAMAGE_FAR
jmp MOVEMENT_FAR
jmp AOE_SPELL_FAR
jmp WHIRLPOOL_FAR
jmp DRAGON_BREATH_FAR
jmp TOGGLE_SPEAKER_FAR