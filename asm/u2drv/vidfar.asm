; VIDFAR.ASM
; Author: Michael C. Maggio
;
; Video driver wrapper functions that manage receipt of the far call from the
; main program.  Sets the data segment (ds) register before calling the actual
; driver implementation, then does a far-return (retf).

; Sets ds to the local data segment
SET_SEGMENT:
	; set es = original data segment of calling program
	;  This allows manipulation of calling program's data.
	push ds
	pop es

    ; set ds = local data segment (cs - 0x10 paragraphs)
    ;  (Previously, when I was using a86, all data addresses were +0x100 bytes
    ;   greater than the code segment, so we needed to adjust ds. This is no
    ;   longer necessary with fasm. Now the two segment registers can be equal.)
    push cs
    pop ds
    ret


INIT_DRIVER_FAR:
	push ds
	push es
	call SET_SEGMENT
	call INIT_DRIVER
	pop es
	pop ds
	retf

CLOSE_DRIVER_FAR:
	push ds
	push es
	call SET_SEGMENT
	call CLOSE_DRIVER
	pop es
	pop ds
	retf

SET_TEXT_DISPLAY_MODE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call SET_TEXT_DISPLAY_MODE
	pop es
	pop ds
	retf

SET_GRAPHIC_DISPLAY_MODE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call SET_GRAPHIC_DISPLAY_MODE
	pop es
	pop ds
	retf

DRAW_TILE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call DRAW_TILE
	pop es
	pop ds
	retf

ROTATE_TILE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call ROTATE_TILE
	pop es
	pop ds
	retf

INVERT_GAME_SCREEN_FAR:
	push ds
	push es
	call SET_SEGMENT
	call INVERT_GAME_SCREEN
	pop es
	pop ds
	retf

CLEAR_GAME_SCREEN_FAR:
	push ds
	push es
	call SET_SEGMENT
	call CLEAR_GAME_SCREEN
	pop es
	pop ds
	retf

WRITE_WHITE_PIXEL_FAR:
	push ds
	push es
	call SET_SEGMENT
	call WRITE_WHITE_PIXEL
	pop es
	pop ds
	retf

CLEAR_PIXEL_FAR:
	push ds
	push es
	call SET_SEGMENT
	call CLEAR_PIXEL
	pop es
	pop ds
	retf

INVERT_TILE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call INVERT_TILE
	pop es
	pop ds
	retf

VIEW_HELM_TILE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call VIEW_HELM_TILE
	pop es
	pop ds
	retf

DRAW_DUNGEON_MONSTER_FAR:
	push ds
	push es
	call SET_SEGMENT
	call DRAW_DUNGEON_MONSTER
	pop es
	pop ds
	retf

WRITE_STAR_PIXEL_FAR:
	push ds
	push es
	call SET_SEGMENT
	call WRITE_STAR_PIXEL
	pop es
	pop ds
	retf

DRAW_CROSSHAIRS_FAR:
	push ds
	push es
	call SET_SEGMENT
	call DRAW_CROSSHAIRS
	pop es
	pop ds
	retf

DISPLAY_GRAPHIC_IMAGE_FAR:
	push ds
	push es
	call SET_SEGMENT
	call DISPLAY_GRAPHIC_IMAGE
	pop es
	pop ds
	retf

DISPLAY_CHAR_FAR:
	push ds
	push es
	call SET_SEGMENT
	call DISPLAY_CHAR
	pop es
	pop ds
	retf

SCROLL_TEXT_WINDOW_FAR:
	push ds
	push es
	call SET_SEGMENT
	call SCROLL_TEXT_WINDOW
	pop es
	pop ds
	retf

SET_CURSOR_POSITION_FAR:
	push ds
	push es
	call SET_SEGMENT
	call SET_CURSOR_POSITION
	pop es
	pop ds
	retf
