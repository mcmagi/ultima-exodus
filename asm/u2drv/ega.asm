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
TILESET_ADDR	dd		0
GRAPHIC_MODE	db		0

; TODO:
; intro/demo files are loaded directly to video buffer in game code


SET_TEXT_DISPLAY_MODE:
	push ax

	call SET_VGA_VIDEO_MODE

	; set coordinates to upper-left corner
	mov byte ptr [es:0x002f],0x00		; text cursor y position
	mov byte ptr [es:0x002e],0x00		; text cursor x position

	call RESET_CURSOR_POSITION

	; set default width to 28 characters
	mov byte ptr [es:0x0031],0x28		; text mode width

	; set display mode = 0 = text
	mov byte ptr [GRAPHIC_MODE],0x00

	call SET_TEXT_COLOR

	pop ax
	ret

SET_GRAPHIC_DISPLAY_MODE:
	push ax
	push bx

	call SET_VGA_VIDEO_MODE

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


; TODO: change where this is called so that params are passed properly
DRAW_TILE:
	; parameters:
	;  ax = tile column number (x coordinate)
	;  bx = tile row number (y coordinate)
	;  cx = tile number (multiple of 4)

	pushf
	push dx
	push di
	push si
	push es

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; es:di => row+col in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_TILE_VIDEO_OFFSET

    ; prepare to write 0x10 (16) rows
	mov dh,0x10
  DRAW_TILE_ROW_LOOP:

	; prepare to write 0x08 words within the row (16 cols)
	mov dl,0x08
  DRAW_TILE_COLUMN_LOOP:
	; read bye from ds:si (shapes), unpack, and write word to es:di (video)
	lodsb
	call UNPACK_VIDEO_DATA
	stosw
	dec dl
	jnz DRAW_TILE_COLUMN_LOOP

	; move to next pixel row
	add di,0x0130				; distance to beginning of next row w/i tile
	dec dh
	jnz DRAW_TILE_ROW_LOOP

	pop es
	pop si
	pop di
	pop dx
	popf
	ret


ANIMATE_WATER:

ANIMATE_FORCEFIELD:

; TODO: change where this is called so that params are passed properly
ROTATE_TILE:
	; parameters:
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push cx
	push di

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; set cx = 4 words (length of one row)
	mov cx,0x004
  ROTATE_TILE_FIRST_ROW:
	; push first row onto stack
	lodsw
	push ax
	loop ROTATE_TILE_FIRST_ROW

	; move si back to start of tile
	sub si,0x0008

	; set cx = 60 words (4 words/row, 15 rows)
	mov cx,0x003c
  ROTATE_TILE_ROW:
	; fetch next row, store it into this row
	mov ax,[si+0x08]
	mov [si],ax
	; advance to next word
	add si,0x02
	loop ROTATE_TILE_ROW

	; move to end of tile
	add si,0x06

	; set cx = 4 words (length of one row)
	mov cx,0x0004
  ROTATE_TILE_LAST_ROW:
	; pop first row off of stack into last row
	pop [si]
	dec si
	dec si
	loop ROTATE_TILE_LAST_ROW

	pop di
	pop cx
	pop ax
	popf
	ret


INVERT_GAME_SCREEN:
	pushf
	push ax
	push bx
	push es

	; set video segment
	mov es,[VIDEO_SEGMENT]

	; set data = row of 2 white pixels
	mov ax,0x0f0f

	; initial offset
	mov bx,0x0000
  INVERT_GAME_SCREEN_LOOP:
	; invert pixels on screen
	xor [es:bx],ax
	; advance by 2 vga pixels
	add bx,0x02
	cmp bx,0xc8000
	jnz INVERT_GAME_SCREEN_LOOP

	pop es
	pop bx
	pop ax
	popf
	ret


CLEAR_GAME_SCREEN:
	pushf
	push ax
	push bx
	push es

	; set video segment
	mov es,[VIDEO_SEGMENT]

	; set data = 0 (row of 2 black vga pixels)
	mov ax,0x0000

	; initial offset
	mov bx,0x0000
  CLEAR_GAME_SCREEN_LOOP:
	; write black pixels to screen
	mov [es:bx],ax
	; advance by 2 vga pixels
	add bx,0x02
	cmp bx,0xc8000
	jnz CLEAR_GAME_SCREEN_LOOP

	pop es
	pop bx
	pop ax
	popf
	ret

WRITE_PIXEL:

CLEAR_PIXEL:

WRITE_COLORED_PIXEL:

; TODO: change where this is called so that params are passed properly
INVERT_TILE:
	; parameters:
	;  ax = tile column number (x coordinate)
	;  bx = tile row number (y coordinate)
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push dx
	push di
	push si
	push es

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; es:di => row+col in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_TILE_VIDEO_OFFSET

	mov dl,0x10
  INVERT_TILE_ROW:
	mov dh,0x08
  INVERT_TILE_COLUMN:
	mov al,[si]
	call UNPACK_EGA_DATA
	xor [es:di],ax
	inc si
	inc di
	inc di
	dec dh
	jnz INVERT_TILE_COLUMN

	add di,0x0130
	dec dl
	jnz INVERT_TILE_ROW

	pop es
	pop si
	pop di
	pop dx
	pop ax
	popf
	ret


GET_TILE_ADDRESS:
	; parameters:
	;  cx = tile number (multiple of 4)
	; returns:
	;  es:di => tile address in shapes file

	pushf
	push ax
	push bx
	push cx

	; ds:si => shapes file
	lea bx,[SHAPES_ADDR]
	mov si,[bx]
	mov ax,[bx+0x02]
	mov ds,ax

	; si = compute offset to EGA tile in shapes file
	mov al,0x40
	mul cl				; ax = tile num * 256 bytes/tile (4 * 64)
	add si,ax

	pop cx
	pop bx
	pop ax
	popf


; Calculates the offset to the tile row+col in the video segment
GET_TILE_VIDEO_OFFSET:
	; parameters:
	;  ax = tile column number (x coordinate)
	;  bx = tile row number (y coordinate)
	; returns:
	;  di = video offset

	push ax
	push bx
	push dx

	xchg bx,ax
	mov dl,0x10
	mul dl				; ax = tile row # * 16 rows per tile
	mov dx,0x0140
	mul dx				; ax = pixel row # * 320 pixels/row
	mov di,ax
	mov ax,0x0010
	mul bx				; ax = tile col * 16 cols per tile
	add di,ax			; ax += col

	pop dx
	pop bx
	pop ax
	popf
	ret


; Ega video data is 4bpp, thus 2 pixels/byte
; the current video mode (13h) is 8bpp, thus 1 pixel/byte
; we must move the upper nybble to the high-order byte
UNPACK_VIDEO_DATA:
    ; parameters
    ; al = packed (ega) video data
    ; returns ax = unpacked (vga) video data

    mov ah,al       ; get copy of data
    and ah,0x0f     ; clear upper nybble of ah

    ; right-shift 4 times (also clears lower nybble of al)
    shr al,1
    shr al,1
    shr al,1
    shr al,1

    ret


SET_VGA_VIDEO_MODE:
	pushf
	push ax
	push bx
	push es

	; get current video mode
	mov ah,0x0f
	int 0x10

	; if already set, clear screen and return
	cmp al,0x13
	jz SET_VGA_VIDEO_MODE_CLEAR_SCREEN

	; set VGA video mode
	mov ax,0x0013
	int 0x10

  SET_VGA_VIDEO_MODE_CLEAR_SCREEN:
	; clear screen
	mov es,[VIDEO_SEGMENT]
	xor bx,bx

  SET_VGA_VIDEO_MODE_CLEAR_PIXEL:
	mov [es:bx],al
	inc bx
	cmp bh,0xfa
	jnz SET_VGA_VIDE_MODE_CLEAR_PIXEL

	pop es
	pop bx
	pop ax
	popf
	ret