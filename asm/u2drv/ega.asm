; EGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade EGA driver.  Despite the name, it does not use any EGA video
; modes instead uses VGA video mode 0x13.  Emulates EGA by limiting video output
; to 16 colors.  EGA data is packed with two pixels per byte and therefore must
; be unpacked to one pixel per byte before outputting to the video buffer at 
; segment address A000.

; ===== start jumps into code here =====
include 'vidjmp.asm'


; ===== data here =====

INTRO_FILE      db      "PICDRA-E",0
DEMO1_FILE      db      "PICOUT-E",0
DEMO2_FILE      db      "PICTWN-E",0
DEMO3_FILE      db      "PICCAS-E",0
DEMO4_FILE      db      "PICDNG-E",0
DEMO5_FILE      db      "PICSPA-E",0
DEMO6_FILE      db      "PICMIN-E",0
TILESET_FILE    db      "EGATILES",0
VIDEO_SEGMENT   dw      0xa000
DRIVER_INIT		db		0
TILESET_ADDR	dd		0
PIXEL_X_OFFSET	dw		0x0010
PIXEL_Y_OFFSET	dw		0x0010


; ===== video driver functions here =====

INIT_DRIVER:
	cmp [DRIVER_INIT],0x01
	jz INIT_DRIVER_DONE

	call LOAD_TILESET_FILE

  INIT_DRIVER_DONE:
	mov [DRIVER_INIT],0x01
	ret


CLOSE_DRIVER:
	push bx

	; free tileset
	lea bx,[TILESET_ADDR]
	call FREE_GRAPHIC_FILE

	pop bx
	ret


SET_TEXT_DISPLAY_MODE:
	call SET_VGA_VIDEO_MODE
	ret


SET_GRAPHIC_DISPLAY_MODE:
	call SET_VGA_VIDEO_MODE
	ret


DRAW_TILE:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push dx
	push di
	push si
	push ds
	push es

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VGA_OFFSET

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

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
	pop ds
	pop si
	pop di
	pop dx
	pop ax
	popf
	ret


ROTATE_TILE:
	; parameters:
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push cx
	push si
	push ds

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; set cx = 4 words (length of one row)
	mov cx,0x0004
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
	add si,0x0002
	loop ROTATE_TILE_ROW

	; move to end of tile
	add si,0x0006

	; set cx = 4 words (length of one row)
	mov cx,0x0004
  ROTATE_TILE_LAST_ROW:
	; pop first row off of stack into last row
	popw [si]
	dec si
	dec si
	loop ROTATE_TILE_LAST_ROW

	pop ds
	pop si
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
	cmp bx,0xc800			; 320x160 pixels
	jnz INVERT_GAME_SCREEN_LOOP

	pop es
	pop bx
	pop ax
	popf
	ret


CLEAR_GAME_SCREEN:
	pushf
	push ax
	push cx
	push di
	push es

	; set video segment
	mov es,[VIDEO_SEGMENT]

	; set data = 0 (row of 2 black vga pixels)
	mov ax,0x0000

	; write black pixels to screen
	mov di,0x0000
	mov cx,0x6400			; 320x160 pixels / 2 pixels/word
	rep
	stosw

	pop es
	pop di
	pop cx
	pop ax
	popf
	ret


WRITE_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)
	;  cl = pixel value

	pushf
	push ax
	push bx
	push di
	push es

	; offset by display origin
	add ax,[PIXEL_X_OFFSET]
	add bx,[PIXEL_Y_OFFSET]

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VGA_OFFSET

	; write pixel to video buffer
	mov al,cl
	mov [es:di],al

	pop es
	pop di
	pop bx
	pop ax
	popf
	ret


CLEAR_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)
	;  cl = pixel value

	pushf
	push ax
	push di
	push es

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VGA_OFFSET

	; toggle pixel, 'and' pixel to es:di
	mov al,0x00
	mov [es:di],al		; TODO: CGA was and, EGA used mov 00; which is better?

	pop es
	pop di
	pop ax
	popf
	ret


INVERT_TILE:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push dx
	push si
	push di
	push ds
	push es

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VGA_OFFSET

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	mov dl,0x10
  INVERT_TILE_ROW:
	mov dh,0x08
  INVERT_TILE_COLUMN:
	mov al,[si]
	call UNPACK_VIDEO_DATA
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
	pop ds
	pop di
	pop si
	pop dx
	pop ax
	popf
	ret


; Given a tile number and a location on the map, outputs a
; 4x2 block to the display.
VIEW_HELM_TILE:
	; parameters:
	;  al = tile number
	;  dl,dh = x,y tile coordinates

	pushf
	push cx

	cmp al,0x00
	jz VIEW_HELM_TILE_WATER
	cmp al,0x04
	jz VIEW_HELM_TILE_SWAMP
	cmp al,0x08
	jz VIEW_HELM_TILE_GRASS
	cmp al,0x0c
	jz VIEW_HELM_TILE_FOREST
	cmp al,0x10
	jz VIEW_HELM_TILE_MOUNTAINS
	cmp al,0x5c
	jz VIEW_HELM_TILE_FORCE
	cmp al,0x70
	jz VIEW_HELM_TILE_BRICK
	cmp al,0xc0
	jz VIEW_HELM_TILE_MOONGATE
	cmp al,0x28
	jz VIEW_HELM_TILE_ENTERABLE
	cmp al,0x6c
	jbe VIEW_HELM_TILE_NPCS
	cmp al,0xec
	jbe VIEW_HELM_TILE_WALLS
	jmp VIEW_HELM_TILE_NPCS

  VIEW_HELM_TILE_WATER:
	mov cl,0x01 ; blue
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_SWAMP:
	mov cl,0x03 ; cyan
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_GRASS:
	mov cl,0x02 ; green
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_FOREST:
	mov cl,0x0a ; light green
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_MOUNTAINS:
	mov cl,0x08 ; dark gray
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_FORCE:
	mov cl,0x0e ; yellow
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_BRICK:
	mov cl,0x04 ; red
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_MOONGATE:
	mov cl,0x0b ; light cyan
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_ENTERABLE:
	mov cl,0x07 ; gray
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_NPCS:
	mov cl,0x07 ; grey
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_WALLS:
	mov cl,0x0f ; white
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_CALL:
	call WRITE_HELM_BLOCK

	pop cx
	popf
	ret


WRITE_HELM_BLOCK:
	; parameters:
	;  cl = block color
	;  dl,dh = x,y of tile

	pushf
	push ax
	push bx

	mov ah,0x00

	; loop for each column
	mov bl,0x03
  WRITE_HELM_BLOCK_COLUMN:

	; loop for each row
	mov bh,0x01
  WRITE_HELM_BLOCK_ROW:
	; save loop counters
	push bx

	; get x coordinate of pixel to write
	mov al,dl
	add al,al
	add al,al		; multiply by block width (4 pixels)
	adc al,bl		; offset to pixel w/i block

	; save x cordinate
	push ax

	; get y coordinate of pixel to write
	mov al,dh
	add al,al		; multiple by block width (4 pixels)
	adc al,bh		; offset to pixel w/i block

	; set bx = y coordinate
	mov bl,al
	mov bh,0x00

	; set ax = x coordinate
	pop ax

	; write cl to ax,bx
	call WRITE_PIXEL

	; restore loop counters
	pop bx

	; repeat for each pixel in row
	dec bh
	jns WRITE_HELM_BLOCK_ROW

	; repeat for each row in column
	dec bl
	jns WRITE_HELM_BLOCK_COLUMN

	pop bx
	pop ax
	popf
	ret


GET_TILE_ADDRESS:
	; parameters:
	;  cx = tile number (multiple of 4)
	; returns:
	;  ds:si => tile address in shapes file

	pushf
	push ax
	push bx
	push cx

	; ds:si => shapes file
	lea bx,[TILESET_ADDR]
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
	ret


; Calculates the offset to the pixel row+col in the video segment
GET_VGA_OFFSET:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	; returns:
	;  di = video offset

	pushf
	push ax
	push dx

	; di = y * 320 + x
	mov di,ax
	mov ax,0x0140
	mul bx
	add di,ax
	
	pop dx
	pop ax
	popf
	ret


; Ega video data is 4bpp, thus 2 pixels/byte
; the current video mode (13h) is 8bpp, thus 1 pixel/byte
; we must move the upper nybble to the high-order byte
UNPACK_VIDEO_DATA:
    ; parameters:
    ;  al = packed (ega) video data
    ; returns:
	;  ax = unpacked (vga) video data

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

	; blacks out screen
	mov al,0x00
  SET_VGA_VIDEO_MODE_CLEAR_PIXEL:
	mov [es:bx],al
	inc bx
	cmp bh,0xfa
	jnz SET_VGA_VIDEO_MODE_CLEAR_PIXEL

	pop es
	pop bx
	pop ax
	popf
	ret


; TODO:
; intro/demo files are loaded directly to video buffer in game code


; ===== file handling functions here =====

LOAD_TILESET_FILE:
    push bx
    push dx

    lea dx,[TILESET_FILE]
    lea bx,[TILESET_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
