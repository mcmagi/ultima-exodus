; CGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade CGA driver.  The functions in the included cgacore.asm output
; directly to the CGA video buffer at segment address B800.  Since data is
; written directly to the video buffer, the FLUSH_* functions have no
; implementation.

; ===== start jumps into code here =====
include 'vidjmp.asm'


; ===== data here =====

GRAPHIC_IMAGES	dw		INTRO_FILE,DEMO1_FILE,DEMO2_FILE,DEMO3_FILE,DEMO4_FILE,DEMO5_FILE,DEMO6_FILE
INTRO_FILE      db      "PICDRA",0
DEMO1_FILE      db      "PICOUT",0
DEMO2_FILE      db      "PICTWN",0
DEMO3_FILE      db      "PICCAS",0
DEMO4_FILE      db      "PICDNG",0
DEMO5_FILE      db      "PICSPA",0
DEMO6_FILE      db      "PICMIN",0
TILESET_FILE    db      "CGATILES",0
MONSTERS_FILE   db      "MONSTERS",0
THEME_PREFIX	db		"CGATHEME.",0
VIDEO_SEGMENT   dw      0xb800
DRIVER_INIT		db		0
TILESET_ADDR	dd		0
GRAPHIC_ADDR	dd		0
PIXEL_X_OFFSET	dw		0x0010
PIXEL_Y_OFFSET	dw		0x0010
MONSTERS_ADDR	dd		0
MONSTERS_DIST	db		0,0,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
MONSTERS_COLOR	db		0xff,0x11,0x88,0xcc,0x33,0,0,0
; 00 = default, 01 = title, 02 = header, 03 = subheader, 04 = low value, 05 = text value, 06 = number value, 07 = highlighted
TEXT_COLOR		db		0x0f,0x0f,0x0f,0x0f,0x02,0x0f,0x0f,0x70


; ===== video driver functions here =====

INIT_DRIVER:
	cmp [DRIVER_INIT],0x01
	jz INIT_DRIVER_DONE

	call LOAD_TILESET_FILE
	call LOAD_MONSTERS_FILE

  INIT_DRIVER_DONE:
	mov [DRIVER_INIT],0x01
	ret


CLOSE_DRIVER:
	push bx

	; free tileset
	lea bx,[TILESET_ADDR]
	call FREE_GRAPHIC_FILE

	; free monsters
	lea bx,[MONSTERS_ADDR]
	call FREE_GRAPHIC_FILE

	pop bx
	ret


SET_TEXT_DISPLAY_MODE:
	push ax

	; set display mode to 40x25 text
	mov ax,0x0001
	int 0x10

	pop ax
	ret


SET_GRAPHIC_DISPLAY_MODE:
	push ax
	push bx

	; set display mode 320x200 color (CGA)
	mov ah,0x00
	mov al,0x04
	int 0x10

	; set background to black
	mov ah,0x0b
	mov bh,0x00
	mov bl,0x00
	int 0x10

	; set palette to CMW
	mov ah,0x0b
	mov bh,0x01
	mov bl,0x01
	int 0x10

	pop bx
	pop ax
	ret


; This has no implementation in the CGA (4-color) driver
FLUSH_GAME_MAP:
FLUSH_BUFFER:
	ret


; include the core CGA driver functions
include 'cgacore.asm'


; Calculates the offset to the pixel coordinates in the video segment.
GET_VIDEO_OFFSET:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	; returns:
	;  di = video offset
	;  dh = bit offset

	push bx
	push cx
	push dx

	; adapt params to library function
	mov dl,bl
	mov bx,ax
	call GET_CGA_OFFSET

	pop dx
	mov dh,cl			; return param: dh = bit offset
	pop cx
	pop bx
	ret


; ===== supporting libraries =====

include '../common/video/cga.asm'
include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
