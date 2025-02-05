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

GRAPHIC_IMAGES	dw		INTRO_FILE,DEMO1_FILE,DEMO2_FILE,DEMO3_FILE,DEMO4_FILE,DEMO5_FILE,DEMO6_FILE
GRAPHIC_INDEX 	db		0,1,1,1,0,0,1
INTRO_FILE      db      "PICDRA.EGA",0
DEMO1_FILE      db      "PICOUT.IDX",0
DEMO2_FILE      db      "PICTWN.IDX",0
DEMO3_FILE      db      "PICCAS.IDX",0
DEMO4_FILE      db      "PICDNG.EGA",0
DEMO5_FILE      db      "PICSPA.EGA",0
DEMO6_FILE      db      "PICMIN.IDX",0
TILESET_FILE    db      "EGATILES",0
MONSTERS_FILE   db      "MONSTERS",0
COLOR_FILE		db		"EGACOLOR",0
THEME_PREFIX	db		"EGATHEME.",0
VIDEO_SEGMENT   dw      0xa000
DRIVER_INIT		db		0
TILESET_ADDR	dd		0
GRAPHIC_ADDR	dd		0
PIXEL_X_OFFSET	dw		0x0010
PIXEL_Y_OFFSET	dw		0x0010
MONSTERS_ADDR	dd		0
MONSTERS_DIST	db		0,0,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

; following section (32 bytes) is replaced by EGACOLOR if present

; color indices provided by MONSTERS file (8 bytes)
MONSTERS_COLOR	db		0x0f,0x02,0x04,0x0c,0x09,0,0,0
; text color indexed by text type (8 bytes)
; 00 = default, 01 = title, 02 = header, 03 = subheader, 04 = low value, 05 = text value, 06 = number value, 07 = highlighted
TEXT_COLOR		db		0x0b,0x0d,0x0f,0x0d,0x0c,0x0c,0x09,0x0f
; star colors, randomly cycled (4 bytes)
; cycles through 4 random star colors
STAR_COLOR		db		0x0f,0x09,0x0c,0x0e
; view helm colors (11 bytes)
; 00 = water, 01 = swamp, 02 = grass, 03 = forest, 04 = mountains, 05 = force,
; 06 = brick, 07 = moongate, 08 = poi, 09 = npcs, 0a = walls
HELM_COLOR		db		0x01,0x03,0x02,0x0a,0x08,0x0e,0x04,0x0b,0x0d,0x07,0x0f
; color of rocket crosshairs
CROSSHAIR_COLOR	db		0x08



; ===== video driver functions here =====

INIT_DRIVER:
	push ax
	cmp [DRIVER_INIT],0x01
	jz INIT_DRIVER_DONE

	call LOAD_TILESET_FILE
	call LOAD_MONSTERS_FILE
	call LOAD_COLOR_FILE

  INIT_DRIVER_DONE:
	mov [DRIVER_INIT],0x01
	pop ax
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


; no buffer in EGA mode
FLUSH_GAME_MAP:
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
	;  cx = tile number (multiple of 2)

	pushf
	push ax
	push dx
	push di
	push si
	push ds
	push es

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VIDEO_OFFSET

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
	call UNPACK_EGA_VIDEO_DATA
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
	;  cx = tile number (multiple of 2)

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


; For dungeon walls
WRITE_WHITE_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)

	push cx

	mov cl,0x0f			; white
	call WRITE_PIXEL

	pop cx
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
	call GET_VIDEO_OFFSET

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

	push cx

	; write black pixel to clear it
	mov cl,0x00
	call WRITE_PIXEL

	pop cx
	ret


WRITE_COLORED_BLOCK:
	; parameters:
	;  ax = pixel x coord
	;  bx = pixel y coord
	;  cl = color index

	pushf
	push ax
	push bx
	push cx
	push dx
	push bp

	; get color data from color index
	mov ch,0x00
	mov bp,cx
	mov cl,[ds:MONSTERS_COLOR+bp]

	mov dh,0x04
  WRITE_COLORED_BLOCK_ROW:
	mov dl,0x04
  WRITE_COLORED_BLOCK_COL:
	call WRITE_PIXEL

	inc ax

	dec dl
	jnz WRITE_COLORED_BLOCK_COL

	; rewind x coord, advance y coord
	sub ax,0x0004
	inc bx

	dec dh
	jnz WRITE_COLORED_BLOCK_ROW

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret


INVERT_TILE:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	;  cx = tile number (multiple of 2)

	pushf
	push ax
	push dx
	push si
	push di
	push ds
	push es

	; es:di => offset to x,y in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VIDEO_OFFSET

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	mov dl,0x10
  INVERT_TILE_ROW:
	mov dh,0x08
  INVERT_TILE_COLUMN:
	mov al,[si]
	call UNPACK_EGA_VIDEO_DATA
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
	push bx
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
	jbe VIEW_HELM_TILE_ENTERABLE
	cmp al,0x6c
	jbe VIEW_HELM_TILE_NPCS
	cmp al,0xec
	jbe VIEW_HELM_TILE_WALLS
	jmp VIEW_HELM_TILE_NPCS

  VIEW_HELM_TILE_WATER:
	mov bx,0x0000
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_SWAMP:
	mov bx,0x0001
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_GRASS:
	mov bx,0x0002
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_FOREST:
	mov bx,0x0003
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_MOUNTAINS:
	mov bx,0x0004
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_FORCE:
	mov bx,0x0005
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_BRICK:
	mov bx,0x0006
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_MOONGATE:
	mov bx,0x0007
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_ENTERABLE:
	mov bx,0x0008
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_NPCS:
	mov bx,0x0009
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_WALLS:
	mov bx,0x000a
	jmp VIEW_HELM_TILE_CALL

  VIEW_HELM_TILE_CALL:
	mov cl,[bx+HELM_COLOR]
	call WRITE_HELM_BLOCK

	pop cx
	pop bx
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


DRAW_DUNGEON_MONSTER:
	; parameters:
	;  ah = monster type 1-8 (in MONSTERS file)
	;  di = monster distance

	pushf
	push ax
	push bx
	push cx
	push dx
	push di
	push es

	; es = address of MONSTERS file
	lea bx,[MONSTERS_ADDR]
	mov es,[bx+0x02]

	; is monster directly in front of player?
	cmp di,0x01
	jz DRAW_DUNGEON_MONSTER_FULL

	; si = offset to distant monster display data
	mov ah,0x00					; monster type = distant
	mov al,[MONSTERS_DIST+di]
	mov si,ax

	jmp DRAW_DUNGEON_MONSTER_LOOP

  DRAW_DUNGEON_MONSTER_FULL:
	; si = offset to monster data
	mov al,0x00
	mov si,ax

  DRAW_DUNGEON_MONSTER_LOOP:
	; dh = x coordinate
	mov al,[es:si]
	inc si
	mov dh,al

	; return if 0
	and al,al
	jz DRAW_DUNGEON_MONSTER_DONE

	; dl = y coordinate
	mov al,[es:si]
	inc si
	mov dl,al
	and dl,0x1f			; y coordinate is lower 5 bits

	; set cl = color
	mov cl,0x05
	shr al,cl			; x coordinate is top 3 bits
	mov cl,al

	; draw cl @ dh,dl
	call DRAW_DUNGEON_MONSTER_BLOCK

	jmp DRAW_DUNGEON_MONSTER_LOOP

  DRAW_DUNGEON_MONSTER_DONE:
	pop es
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret


DRAW_DUNGEON_MONSTER_BLOCK:
	; parameters:
	;  cl = monster block color
	;  dh,dl = x,y coordinates of monster block

	pushf
	push ax
	push bx

	; calc ax = x pixel coordinate
	mov al,dh
	mov ah,0x00
	shl ax,1
	shl ax,1

	; calc bx = y pixel coordinate
	mov bl,dl
	mov bh,0x00
	shl bx,1
	shl bx,1

	; write cl @ ax,bx
	call WRITE_COLORED_BLOCK

	pop bx
	pop ax
	popf
	ret


WRITE_STAR_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)
	;  si = star index

	pushf
	push cx
	push si
	and si,0x03

	; cl = star color based on last 2 bites of star index
	mov cl,[STAR_COLOR+si]

	call WRITE_PIXEL
	pop si
	pop cx
	popf
	ret


DRAW_CROSSHAIRS:
	; parameters:
	;  ax = crosshairs column number (x coordinate)
	;  bx = crosshairs column number (y coordinate)

	pushf
	push bx

	; bx = y - 3
	stc
	cmc	
	sbb bx,0x0003
	cmc

	; vertical component
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL
	inc bx
	call WRITE_CROSSHAIRS_PIXEL

	pop bx
	push ax

	; ax = x - 3
	stc
	cmc
	sbb ax,0x0003
	cmc

	; horizontal component line
	call WRITE_CROSSHAIRS_PIXEL
	inc ax
	call WRITE_CROSSHAIRS_PIXEL
	inc ax
	call WRITE_CROSSHAIRS_PIXEL
	inc ax
	inc ax
	call WRITE_CROSSHAIRS_PIXEL
	inc ax
	call WRITE_CROSSHAIRS_PIXEL
	inc ax
	call WRITE_CROSSHAIRS_PIXEL

	pop ax
	popf
	ret
	

WRITE_CROSSHAIRS_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)

	push cx
	mov cl,[CROSSHAIR_COLOR]
	call WRITE_PIXEL
	pop cx
	ret


DISPLAY_GRAPHIC_IMAGE:
	; parameters:
	;  al = graphic file number

	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push es

	; ah = image index type, ds:dx = image filename
	mov bl,al
	mov bh,0x00
	mov ah,[GRAPHIC_INDEX+bx]
	shl bx,1
	mov dx,[GRAPHIC_IMAGES+bx]

	; ds:bx = image address
	lea bx,[GRAPHIC_ADDR]

	; load image, save address to ds:bx
	call LOAD_THEME_FILE
	jc DISPLAY_GRAPHIC_IMAGE_DONE

	cmp ah,01
	jz DISPLAY_GRAPHIC_IMAGE_INDEXED

	; non-indexed: copy to video buffer

	push ds

	; set es:di => start of video segment
	mov es,[VIDEO_SEGMENT]
	mov di,0x0000

	; set ds:si => start of graphic file
	mov si,[bx]
	mov ax,[bx+0x02]
	mov ds,ax

	; move contents of file to video segment
	mov cx,0xfa00
	rep movsb

	pop ds
	jmp DISPLAY_GRAPHIC_IMAGE_FREE

  DISPLAY_GRAPHIC_IMAGE_INDEXED:
	; indexed: draw each tile

	; set es:si => start of graphic file
	mov si,[bx]
	mov ax,[bx+0x02]
	mov es,ax

  DISPLAY_GRAPHIC_IMAGE_INDEXED_LOOP:
	mov ch,[es:si]			; ch = tile number

	; bx = ax / 20 tiles = tile y position
	mov ax,si
	mov bl,0x14
	div bl
	mov bl,al
	mov bh,0x00

	; ax = remainder = tile x position
	mov al,ah
	mov ah,0x00

	mov cl,0x04
	
	; adjust tile positions to pixel positions
	mov cl,0x04
	shl ax,cl			; ax *= 16
	shl bx,cl			; bx *= 16

	; cx = tile number (multiple of 2 instead of 4)
	mov cl,ch
	mov ch,0x00
	shr cx,1

	call DRAW_TILE

	; inc si, quit out after 200 bytes (20x10)
	inc si
	cmp si,0x00c8
	jnz DISPLAY_GRAPHIC_IMAGE_INDEXED_LOOP

  DISPLAY_GRAPHIC_IMAGE_FREE:
	; free image
	lea bx,[GRAPHIC_ADDR]
	call FREE_GRAPHIC_FILE

  DISPLAY_GRAPHIC_IMAGE_DONE:
	pop es
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret


SCROLL_TEXT_WINDOW:
	; parameters:
	;  cx = y,x of upper-left
	;  dx = y,x of lower-right

	push ax
	push bx

	; scroll up window by 1 line
	mov ah,0x06		; 06 = scroll up window
	mov al,0x01		; 1 line
	mov bh,0x00		; no attributes
	int 0x10

	pop bx
	pop ax
	ret


DISPLAY_CHAR:
	; parameters:
	;  al = ascii code
	;  bl = text type

	pushf
	push ax
	push bx
	push cx
	push dx

	mov dx,0xffff
	cmp bl,0x07
	jnz DISPLAY_CHAR_DO

	; dh,dl = y,x cursor position
	push ax
	mov ah,0x03		; 03 = get cursor position & size
	mov bh,0x00		; page 0
	int 0x10
	pop ax

  DISPLAY_CHAR_DO:
	; converts bl to text color
	call GET_TEXT_COLOR

	mov ah,0x09		; 09 = write char
	mov cx,0x0001	; write it once
	mov bh,0x00		; background = black (doesn't seem to work)
	int 0x10

	and dx,dx
	js DISPLAY_CHAR_DONE

	; invert character @ dl,dh
	call INVERT_CHAR

  DISPLAY_CHAR_DONE:
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret


GET_TEXT_COLOR:
	; parameters:
	;  bl = text type

	mov bh,0x00
	mov bl,[TEXT_COLOR+bx]
	ret


INVERT_CHAR:
	; parameters:
	;  dh,dl = y,x cursor position

	pushf
	push ax
	push bx
	push di
	push es

	; bx = y * 8 (cursor -> pixel)
	mov al,0x08
	mul dh
	mov bx,ax

	; ax = x * 8 (cursor -> pixel)
	mov al,0x08
	mul dl

	; es:di => offset in video segment
	mov es,[VIDEO_SEGMENT]
	call GET_VIDEO_OFFSET

	; prepare to xor lo-nibble
	mov al,0x0f

	mov bl,0x08
  INVERT_CHAR_ROW:

	mov bh,0x08
  INVERT_CHAR_COL:
	xor [es:di],al
	inc di ; advance to next byte/column
	dec bh
	jnz INVERT_CHAR_COL

	add di,0x0138 ; advance to next row
	dec bl
	jnz INVERT_CHAR_ROW

	pop es
	pop di
	pop bx
	pop ax
	popf
	ret


SET_CURSOR_POSITION:
	; parameters:
	;  dh,dl = x,y cursor position

	push ax
	push bx

	mov ah,0x02			; 02 = set cursor position
	mov bh,0x00
	int 0x10

	pop bx
	pop ax
	ret


; ===== utility functions =====

GET_TILE_ADDRESS:
	; parameters:
	;  cx = tile number (multiple of 2)
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
	mul cl				; ax = tile num * 128 bytes/tile (2 * 64)
	add si,ax

	pop cx
	pop bx
	pop ax
	popf
	ret


; Calculates the offset to the pixel row+col in the video segment
GET_VIDEO_OFFSET:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	; returns:
	;  di = video offset

	push bx
	push dx

	; adapt params to library function
	mov dl,bl
	mov bx,ax
	call GET_VGA_OFFSET

	pop dx
	pop bx
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


; ===== file handling functions here =====

LOAD_TILESET_FILE:
    push bx
    push dx

    lea dx,[TILESET_FILE]
    lea bx,[TILESET_ADDR]
    call LOAD_THEME_FILE

    pop dx
    pop bx
    ret


LOAD_MONSTERS_FILE:
    push bx
    push dx

    lea dx,[MONSTERS_FILE]
    lea bx,[MONSTERS_ADDR]
    call LOAD_THEME_FILE

    pop dx
    pop bx
    ret


LOAD_COLOR_FILE:
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es

    lea dx,[COLOR_FILE]
    lea bx,[GRAPHIC_ADDR]
    call LOAD_THEME_FILE

	; if not found, just return
	jc LOAD_COLOR_FILE_DONE

	; set es:di => start of local color data area
	push ds
	pop es
	lea di,[MONSTERS_COLOR]

	; set ds:si => start of color file
	mov si,[bx]
	mov ax,[bx+0x02]
	mov ds,ax

	; move contents of file (32 bytes) to data area
	mov cx,0x0020
	rep movsb

	; free colors file
	push es
	pop ds
	lea bx,[GRAPHIC_ADDR]
	call FREE_GRAPHIC_FILE

  LOAD_COLOR_FILE_DONE:
	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	ret


LOAD_THEME_FILE:
	push ax

	lea ax,[THEME_PREFIX]
	call LOAD_GRAPHIC_FILE_THEME

	pop ax
	ret


; ===== supporting libraries =====

include '../common/video/vga.asm'
include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
