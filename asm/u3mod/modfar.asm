; MODFAR.ASM
; Author: Michael C. Maggio
;
; Mod plugin wrapper functions that manage receipt of the far call from the
; main program.  Sets the data segment (ds) register before calling the actual
; mod implementation, then does a far-return (retf).

; Sets ds to the local data segment
SET_SEGMENT:
    ; set ds = local data segment
    push cs
    pop ds
    ret

; far calls to mod functions
GET_POI_INDEX_FAR:
    push ds
    call SET_SEGMENT
    call GET_POI_INDEX
    pop ds
    retf

GET_POI_STR_FAR:
    push ds
    call SET_SEGMENT
    call GET_POI_STR
    pop ds
    retf

GET_WORLD_STR_FAR:
    push ds
    call SET_SEGMENT
    call GET_WORLD_STR
    pop ds
    retf

GET_WHIRLPOOL_STR_FAR:
    push ds
    call SET_SEGMENT
    call GET_WHIRLPOOL_STR
    pop ds
    retf

GET_PARTY_STR_FAR:
    push ds
    call SET_SEGMENT
    call GET_PARTY_STR
    pop ds
    retf

GET_ROSTER_STR_FAR:
    push ds
    call SET_SEGMENT
    call GET_ROSTER_STR
    pop ds
    retf

GET_MOONGATE_COORDS_FAR:
    push ds
    call SET_SEGMENT
    call GET_MOONGATE_COORDS
    pop ds
    retf

GET_START_FAR:
    push ds
    call SET_SEGMENT
    call GET_START
    pop ds
    retf

GET_NEW_MOON_TOWN_OFFSET_FAR:
    push ds
    call SET_SEGMENT
    call GET_NEW_MOON_TOWN_OFFSET
    pop ds
    retf

GET_SNAKE_TELEPORT_FAR:
    push ds
    call SET_SEGMENT
    call GET_SNAKE_TELEPORT
    pop ds
    retf

IS_EXOTIC_WEAPON_FAR:
    push ds
    call SET_SEGMENT
    call IS_EXOTIC_WEAPON
    pop ds
    retf

IS_EXOTIC_ARMOR_FAR:
    push ds
    call SET_SEGMENT
    call IS_EXOTIC_ARMOR
    pop ds
    retf

GET_CASTLE_DEATH_FAR:
    push ds
    call SET_SEGMENT
    call GET_CASTLE_DEATH
    pop ds
    retf

GET_PRAY_LOCATION_FAR:
    push ds
    call SET_SEGMENT
    call GET_PRAY_LOCATION
    pop ds
    retf
