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
jmp WRITE_PIXEL_FAR					; 0018
jmp CLEAR_PIXEL_FAR					; 001b
jmp INVERT_TILE_FAR					; 001e