; EGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade EGA driver.  Despite the name, it does not use any EGA video
; modes instead uses VGA video mode 0x13.  Emulates EGA by limiting video output
; to 16 colors.  EGA data is packed with two pixels per byte and therefore must
; be unpacked to one pixel per byte before outputting to the video buffer at 
; segment address A000.


INTRO_FILE      db      "PICDRA-E",0
DEMO1_FILE      db      "PICOUT-E",0
DEMO2_FILE      db      "PICTWN-E",0
DEMO3_FILE      db      "PICCAS-E",0
DEMO4_FILE      db      "PICDNG-E",0
DEMO5_FILE      db      "PICSPA-E",0
DEMO6_FILE      db      "PICMIN-E",0
TILESET         db      "EGATILES",0
VIDEO_SEGMENT   dw      0xa000

; TODO:
; intro/demo files are loaded directly to video buffer in game code


SET_TEXT_DISPLAY_MODE:
	push ax

	call SET_VGA_VIDEO_MODE

	mov byte ptr [CURSOR_Y],0x00
	mov byte ptr [CURSOR_X],0x00

	call RESET_CURSOR_POSITION

	; ??
	mov byte ptr [0x0031],0x28

	; set display mode = 0 = text
	mov byte ptr [GRAPHIC_MODE],0x00

	call SET_TEXT_COLOR

	pop ax
	ret

SET_GRAPHIC_DISPLAY_MODE:
	push ax
	push bx

	call SET_VGA_VIDEO_MODE

	; set background to black
	mov ah,0x0b
	mov bh,0x00
	mov bl,0x00
	int 0x10

	; set palette to CMW
	mov ah,0x0b
	mov bh,0x01
	mov bl,0x01

	; set graphic mode = 1 = graphic
	mov byte ptr [GRAPHIC_MODE],0x01

	call SET_TEXT_COLOR

	mov bx,0x00fe
	mov bx,0xffff
  SET_GRAPHIC_DISPLAY_MODE_LOOP:
	; set something??? to 0xffff
	mov [bx+0x0272],ax
	mov [bx+0x0372],ax
	sub bx,0x02
	jns SET_GRAPHIC_DISPLAY_MODE_LOOP

	pop bx
	pop ax
	ret


DRAW_TILE:
	; parameters:
	;  ax = column number
	;  bx = row number
	;  cx = tile offset

	push ax
	push bx
	push ad
	push di
	push si
	push es

	; TODO

	pop es
	pop si
	pop di
	pop dx
	pop bx
	pop ax
	ret

DRAW_GAME_MAP:

ANIMATE_WATER:

ANIMATE_FORCEFIELD:

ROTATE_TILE:

WHITE_OUT_SCREEN:

BLACK_OUT_SCREEN:

WRITE_PIXEL:

CLEAR_PIXEL:

WRITE_COLORED_PIXEL:

INVERT_TILE:
	; ax = pixel col #
	; bx = pixel row #
	; cx = tile offset

	push dx
	push di
	push si
	push es

	; TODO