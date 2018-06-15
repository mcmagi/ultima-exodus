; CGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade Composite CGA driver. Employs a dual-buffer strategy to
; translate CGA data to CGA composite output. The functions in the included
; cgacore.asm output to a pre-allocated buffer at some segment address. The
; FLUSH_* functions then map the CGA data to the VGA video buffer at segment
; address A000. Uses VGA video mode 0x13. Loads CGACOMP.PAL to configure the
; VGApalette with CGA composite colors.

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
PALETTE_FILE    db      "CGACOMP.PAL",0
;VIDEO_SEGMENT   dw      0xb800
DRIVER_INIT		db		0
TILESET_ADDR	dd		0
GRAPHIC_ADDR	dd		0
PIXEL_X_OFFSET	dw		0x0010
PIXEL_Y_OFFSET	dw		0x0010
MONSTERS_ADDR	dd		0
MONSTERS_DIST	db		0,0,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
MONSTERS_COLOR	db		0xff,0x11,0x88,0xcc,0x33,0,0,0
; 00 = default, 01 = title, 02 = header, 03 = subheader, 04 = low value, 05 = text value, 06 = number value, 07 = highlighted
TEXT_COLOR		db		0x0f,0x0f,0x0f,0x0f,0x0a,0x0f,0x0f,0x70


; ===== video driver functions here =====

INIT_DRIVER:
	cmp [DRIVER_INIT],0x01
	jz INIT_DRIVER_DONE

	call LOAD_TILESET_FILE
	call LOAD_MONSTERS_FILE

	; allocate cga video buffer
    call SETUP_CGA_BUFFER

    ; build row lookup tables
    call BUILD_CGA_ROW_LOOKUP_TABLE
    call BUILD_VGA_ROW_LOOKUP_TABLE

    ; build composite color lookup table
    call BUILD_COMPOSITE_LOOKUP_TABLE

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

    ; free cga video buffer
	call FREE_CGA_BUFFER

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
	push cx
	push di
	push es

	; set VGA video mode
	mov ax,0x0013
	int 0x10

	; load composite cga palette from file
    lea dx,[PALETTE_FILE]
    call LOAD_VGA_PALETTE

	; clear screen
	mov es,[VIDEO_SEGMENT]

	; blacks out CGA video buffer
	mov di,0x0000
	mov al,0x00
	mov cx,0x1f40
	rep stosb
	mov di,0x2000
	mov cx,0x1f40
	rep stosb

	pop es
	pop di
	pop cx
	pop ax
	ret


; ===== Buffer functions =====

; Flushes the game map area to the VGA video buffer.
FLUSH_GAME_MAP:
    push bx
    push cx
    push dx

	; x = 320 columns
	mov bx,0x0000
	mov cx,0x0140
	; y = 160 rows
	mov dl,0x00
	mov dh,0xa0

    call FLUSH_BUFFER_RECT

    pop dx
    pop cx 
    pop bx
    ret


FLUSH_PIXEL:
	; parameters:
	;  ax = pixel x coord
	;  bx = pixel y coord

	push bx
	push dx

	; map x/y params
	mov dx,bx
	mov bx,ax

	; offset by display origin
	add bx,[PIXEL_X_OFFSET]
	add dx,[PIXEL_Y_OFFSET]

	; flush
	call FLUSH_BUFFER_PIXEL

	pop dx
	pop bx
	ret


; ===== CGA core =====

; include the core CGA driver functions
include 'cgacore.asm'


; ===== CGA/VGA offset functions =====

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
	call LOOKUP_CGA_OFFSET

	pop dx
	mov dh,cl			; return param: dh = bit offset
	pop cx
	pop bx
	ret


; ===== supporting libraries =====

include '../common/video/cgacomp.asm'
include '../common/video/palette.asm'
include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
