; VIDJMP.ASM
; Author: Michael C. Maggio
;
; These are all the function jumps at the start of every video driver.
; Each jump is to be far-called by the main program.

; initializes the video mode
jmp INIT_DRIVER_FAR                 ; 0000

; frees all resources
jmp CLOSE_DRIVER_FAR                ; 0003

; game functions
jmp DRAW_GEM_BLOCK_FAR              ; 0006
jmp CYCLE_GEM_BLOCK_FAR             ; 0009
jmp SCROLL_TEXT_WINDOW_FAR          ; 000c
jmp DRAW_GAME_BORDER_FAR            ; 000f
jmp CLEAR_GAME_WINDOW_FAR           ; 0012
jmp DISPLAY_CHAR_FAR                ; 0015
jmp DISPLAY_MOON_CHAR_FAR           ; 0018
jmp DISPLAY_TILE_FAR                ; 001b
jmp CLEAR_SCREEN_FAR                ; 001e

; load
jmp LOAD_SHAPES_FILE_FAR            ; 0021
jmp LOAD_CHARSET_FILE_FAR           ; 0024
jmp LOAD_BLANK_FILE_FAR             ; 0027
jmp LOAD_EXOD_FILE_FAR              ; 002a
jmp LOAD_ANIMATE_FILE_FAR           ; 002d

; tile animation
jmp SCROLL_TILE_FAR                 ; 0030
jmp SWAP_TILE_ROWS_FAR              ; 0033
jmp SWAP_TILES_FAR                  ; 0036

; screen inversion
jmp INVERT_PARTY_MEMBER_BOX_FAR     ; 0039
jmp INVERT_GAME_SCREEN_FAR          ; 003c
jmp INVERT_PARTY_MEMBER_NUMBER_FAR  ; 003f
jmp INVERT_ENDGAME_SCREEN_FAR       ; 0042

; introduction
jmp DISPLAY_BLANK_INTRO_FAR         ; 0045
jmp DISPLAY_EXOD_LINE_FAR           ; 0048
jmp DRAW_MENU_BORDER_FAR            ; 004b
jmp CLEAR_DEMO_WINDOW_FAR           ; 004e
jmp DISPLAY_LORDBRIT_PIXEL_FAR      ; 0051
jmp DISPLAY_ANIMATION_FRAME_FAR     ; 0054

; dungeons
jmp DRAW_DUNGEON_WALL_LINE_FAR      ; 0057
jmp DRAW_DUNGEON_CHEST_LINE_FAR     ; 005a
jmp DRAW_DUNGEON_LADDER_PIXEL_FAR   ; 005d
