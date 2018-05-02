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
jmp SET_TEXT_DISPLAY_MODE_FAR       ; 0006
jmp SET_GRAPHIC_DISPLAY_MODE_FAR    ; 0009
jmp DRAW_TILE_FAR                   ; 000c
jmp ROTATE_TILE_FAR					; 000f
jmp INVERT_GAME_SCREEN_FAR			; 0012
jmp CLEAR_GAME_SCREEN_FAR			; 0015
jmp WRITE_WHITE_PIXEL_FAR			; 0018
jmp CLEAR_PIXEL_FAR					; 001b
jmp INVERT_TILE_FAR					; 001e
jmp VIEW_HELM_TILE_FAR				; 0021
jmp DRAW_DUNGEON_MONSTER_FAR		; 0024
jmp WRITE_STAR_PIXEL_FAR			; 0027
jmp DRAW_CROSSHAIRS_FAR				; 002a
jmp DISPLAY_GRAPHIC_IMAGE_FAR		; 002d
jmp DISPLAY_CHAR_FAR				; 0030
jmp SCROLL_TEXT_WINDOW_FAR			; 0033
jmp SET_CURSOR_POSITION_FAR			; 0036