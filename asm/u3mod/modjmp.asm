; MODJMP.ASM
; Author: Michael C. Maggio
;
; These are all the function jumps at the start of every module plugin.
; Each jump is to be far-called by the main program.

jmp GET_POI_INDEX_FAR                   ; 0000
jmp GET_POI_STR_FAR                     ; 0003
jmp GET_WORLD_STR_FAR                   ; 0006
jmp GET_WHIRLPOOL_STR_FAR               ; 0009
jmp GET_PARTY_STR_FAR                   ; 000c
jmp GET_ROSTER_STR_FAR                  ; 000f
jmp GET_MOONGATE_COORDS_FAR             ; 0012
jmp GET_START_FAR                       ; 0015
jmp GET_NEW_MOON_TOWN_OFFSET_FAR        ; 0018
jmp GET_SNAKE_TELEPORT_FAR              ; 001b
jmp IS_EXOTIC_WEAPON_FAR                ; 001e
jmp IS_EXOTIC_ARMOR_FAR                 ; 0021
jmp GET_CASTLE_DEATH_FAR                ; 0024
jmp GET_PRAY_LOCATION_FAR               ; 0027