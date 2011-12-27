; VIDFAR.ASM
; Author: Michael C. Maggio
;
; Video driver wrapper functions that manage receipt of the far call from the
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


; Literally does as it says - just returns.
; Really only of practical use as I'm creating this thing.
DO_NOTHING:
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

DRAW_GEM_BLOCK_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_GEM_BLOCK
    pop ds
    retf

CYCLE_GEM_BLOCK_FAR:
    push ds
    call SET_SEGMENT
    call CYCLE_GEM_BLOCK
    pop ds
    retf

SCROLL_TEXT_WINDOW_FAR:
    push ds
    call SET_SEGMENT
    call SCROLL_TEXT_WINDOW
    pop ds
    retf

DRAW_GAME_BORDER_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_GAME_BORDER
    pop ds
    retf

CLEAR_GAME_WINDOW_FAR:
    push ds
    call SET_SEGMENT
    call CLEAR_GAME_WINDOW
    pop ds
    retf

DISPLAY_CHAR_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_CHAR
    pop ds
    retf

DISPLAY_MOON_CHAR_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_MOON_CHAR
    pop ds
    retf

DISPLAY_TILE_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_TILE
    pop ds
    retf

CLEAR_SCREEN_FAR:
    push ds
    call SET_SEGMENT
    call CLEAR_SCREEN
    pop ds
    retf

LOAD_SHAPES_FILE_FAR:
    push ds
    call SET_SEGMENT
    call LOAD_SHAPES_FILE
    pop ds
    retf

LOAD_CHARSET_FILE_FAR:
    push ds
    call SET_SEGMENT
    call LOAD_CHARSET_FILE
    pop ds
    retf

LOAD_BLANK_FILE_FAR:
    push ds
    call SET_SEGMENT
    call LOAD_BLANK_FILE
    pop ds
    retf

LOAD_EXOD_FILE_FAR:
    push ds
    call SET_SEGMENT
    call LOAD_EXOD_FILE
    pop ds
    retf

LOAD_ANIMATE_FILE_FAR:
    push ds
    call SET_SEGMENT
    call LOAD_ANIMATE_FILE
    pop ds
    retf

SCROLL_TILE_FAR:
    push ds
    call SET_SEGMENT
    call SCROLL_TILE
    pop ds
    retf

SWAP_TILE_ROWS_FAR:
    push ds
    call SET_SEGMENT
    call SWAP_TILE_ROWS
    pop ds
    retf

SWAP_TILES_FAR:
    push ds
    call SET_SEGMENT
    call SWAP_TILES
    pop ds
    retf

INVERT_PARTY_MEMBER_BOX_FAR:
    push ds
    call SET_SEGMENT
    call INVERT_PARTY_MEMBER_BOX
    pop ds
    retf

INVERT_GAME_SCREEN_FAR:
    push ds
    call SET_SEGMENT
    call INVERT_GAME_SCREEN
    pop ds
    retf

INVERT_PARTY_MEMBER_NUMBER_FAR:
    push ds
    call SET_SEGMENT
    call INVERT_PARTY_MEMBER_NUMBER
    pop ds
    retf

INVERT_ENDGAME_SCREEN_FAR:
    push ds
    call SET_SEGMENT
    call INVERT_ENDGAME_SCREEN
    pop ds
    retf

DISPLAY_BLANK_INTRO_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_BLANK_INTRO
    pop ds
    retf

DISPLAY_EXOD_LINE_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_EXOD_LINE
    pop ds
    retf

DRAW_MENU_BORDER_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_MENU_BORDER
    pop ds
    retf

CLEAR_DEMO_WINDOW_FAR:
    push ds
    call SET_SEGMENT
    call CLEAR_DEMO_WINDOW
    pop ds
    retf

DISPLAY_LORDBRIT_PIXEL_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_LORDBRIT_PIXEL
    pop ds
    retf

DISPLAY_ANIMATION_FRAME_FAR:
    push ds
    call SET_SEGMENT
    call DISPLAY_ANIMATION_FRAME
    pop ds
    retf

DRAW_DUNGEON_WALL_LINE_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_DUNGEON_WALL_LINE
    pop ds
    retf

DRAW_DUNGEON_CHEST_LINE_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_DUNGEON_CHEST_LINE
    pop ds
    retf

DRAW_DUNGEON_LADDER_PIXEL_FAR:
    push ds
    call SET_SEGMENT
    call DRAW_DUNGEON_LADDER_PIXEL
    pop ds
    retf
