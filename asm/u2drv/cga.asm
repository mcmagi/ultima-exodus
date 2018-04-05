; CGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade CGA driver.  The functions in the included cgacore.asm output
; directly to the CGA video buffer at segment address B800.  Since data is
; written directly to the video buffer, the FLUSH_* functions have no
; implementation.

INTRO_FILE      db      "PICDRA",0
DEMO1_FILE      db      "PICOUT",0
DEMO2_FILE      db      "PICTWN",0
DEMO3_FILE      db      "PICCAS",0
DEMO4_FILE      db      "PICDNG",0
DEMO5_FILE      db      "PICSPA",0
DEMO6_FILE      db      "PICMIN",0
TILESET         db      "CGATILES",0        ; TODO: they are actually in game code
VIDEO_SEGMENT   dw      0xb800

CURSOR_X		db		0
CURSOR_Y		db		0
GRAPHIC_MODE	db		0

; TODO:
; intro/demo files are loaded directly to video buffer in game code

SET_TEXT_DISPLAY_MODE:
	push ax

	; set display mode to 40x25 text
	mov ax,0x0001
	int 0x10

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

	; TODO: cx in CGA logic is actually "tile address" - reconcile this with portion of EGA code
	mov si,cx

	; di = col*4
	shr ax,1
	shr ax,1
	mov di,ax

	; bx = row*2
	shl bx,1

	; dl = 16 rows
	mov dl,0x10

	; skip word buffer between tiles
	add si,0x02
	
  DRAW_TILE_LOOP:
	; get video segment
	mov ax,[VIDEO_SEGMENT]
	;mov ax,[bx+0x48dc] -- sooo, we have a lookup table for each tile in the video segment; we should calc this ourselves
	mov es,ax

	; transfer pixel row to video segment
	mov ax,[si]
	mov [es:di],ax
	mov ax,[si+02]
	mov [es:di+02],ax

	; move si to next row of tile
	add si,0x04

	; move bx forward to next address in video segment table
	add bx,0x02

	dec dl
	jnz DRAW_TILE_LOOP

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

	mov si,cx

	shr ax,1
	shr ax,1
	mov di,ax

	shl bx,1

	mov dl,0x10
	add si,0x02