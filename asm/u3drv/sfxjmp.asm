; SFXJMP.ASM
; Author: Michael C. Maggio
;
; These are all the function jumps at the start of every soundfx driver.
; Each jump is to be far-called by the main program.

; initializes the sfx driver
jmp INIT_DRIVER_FAR                 ; 0000

; frees all resources
jmp CLOSE_DRIVER_FAR                ; 0003

; sound effects
jmp INVALID_ACTION_FAR              ; 0006
jmp INVALID_COMMAND_FAR             ; 0009
jmp SPELL_FAR                       ; 000c
jmp FORCE_FIELD_FAR                 ; 000f
jmp ATTACK_FAR                      ; 0012
jmp TRAP_EVADED_FAR                 ; 0015
jmp MOONGATE_FAR                    ; 0018
jmp FIRE_FAR                        ; 001b
jmp DAMAGE_FAR                      ; 001e
jmp MOVEMENT_FAR                    ; 0021
jmp AOE_SPELL_FAR                   ; 0024
jmp WHIRLPOOL_FAR                   ; 0027
jmp DRAGON_BREATH_FAR               ; 002a
jmp INTRO_BEGIN_FAR                 ; 002d
jmp INTRO_END_FAR                   ; 0030