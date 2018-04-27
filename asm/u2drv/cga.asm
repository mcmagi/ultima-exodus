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

INTRO_FILE      db      "PICDRA",0
DEMO1_FILE      db      "PICOUT",0
DEMO2_FILE      db      "PICTWN",0
DEMO3_FILE      db      "PICCAS",0
DEMO4_FILE      db      "PICDNG",0
DEMO5_FILE      db      "PICSPA",0
DEMO6_FILE      db      "PICMIN",0
TILESET_FILE    db      "CGATILES",0
MONSTERS_FILE   db      "MONSTERS",0
VIDEO_SEGMENT   dw      0xb800
DRIVER_INIT		db		0
TILESET_ADDR	dd		0
PIXEL_X_OFFSET	dw		0x0010
PIXEL_Y_OFFSET	dw		0x0010
MONSTERS_ADDR	dd		0
MONSTERS_DIST	db		0,0,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
COLORED_PIXELS	db		0xff,0x11,0x88,0xcc,0x33,0,0,0


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


DRAW_TILE:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	;  cx = tile number (multiple of 4)

	pushf
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	push ds
	push es

	mov es,[VIDEO_SEGMENT]

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; cx = 16 rows
	mov cx,0x0010
  DRAW_TILE_LOOP:
	; es:di => offset to x,y in video segment, dh = bit number
	call GET_CGA_OFFSET

	; transfer pixel row (4 bytes) to video segment
	movsw
	movsw

	inc bx		; advance to next row
	loop DRAW_TILE_LOOP

	pop es
	pop ds
	pop si
	pop di
	pop dx
	pop cx
	pop bx
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

	; set cx = 2 words (length of one row)
	mov cx,0x0002
  ROTATE_TILE_FIRST_ROW:
	; push first row onto stack
	lodsw
	push ax
	loop ROTATE_TILE_FIRST_ROW

	; move si back to start of tile
	sub si,0x0004

	; set cx = 30 words (2 words/row, 15 rows)
	mov cx,0x001e
  ROTATE_TILE_ROW:
	; fetch next row, store it into this row
	mov ax,[si+0x04]
	mov [si],ax
	; advance to next word
	add si,0x0002
	loop ROTATE_TILE_ROW

	; move to end of tile
	add si,0x0002

	; set cx = 2 words (length of one row)
	mov cx,0x0002
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
	push ax
	push es

	; set video segment = first page
	mov ax,[VIDEO_SEGMENT]
	mov es,ax
	call INVERT_GAME_SCREEN_PAGE

	; set video segment = second page
	add ax,0x0200
	mov es,ax
	call INVERT_GAME_SCREEN_PAGE

	pop es
	pop ax
	ret

INVERT_GAME_SCREEN_PAGE:
	pushf
	push ax
	push bx

	; set data = row of 4 white pixels
	mov ax,0xffff

	; initial offset
	mov bx,0x0000
  INVERT_GAME_SCREEN_PAGE_LOOP:
	; invert pixels on screen
	xor [es:bx],ax
	; advance by 8 cga pixels
	add bx,0x02
	cmp bx,0x1900			; 320x160 pixels / 4 pixels/byte / 2 pages
	jnz INVERT_GAME_SCREEN_PAGE_LOOP

	pop bx
	pop ax
	popf
	ret


CLEAR_GAME_SCREEN:
	push ax
	push es

	; set video segment = first page
	mov ax,[VIDEO_SEGMENT]
	mov es,ax
	call CLEAR_GAME_SCREEN_PAGE

	; set video segment = second page
	add ax,0x0200
	mov es,ax
	call CLEAR_GAME_SCREEN_PAGE

	pop es
	pop ax
	ret

CLEAR_GAME_SCREEN_PAGE:
	pushf
	push ax
	push cx
	push di

	; set data = 0 (row of 8 black cga pixels)
	mov ax,0x0000
	mov di,0x0000
	mov cx,0x0c80			; 320x160 pixels / 8 pixels/word / 2 pages
	rep
	stosw

	pop di
	pop cx
	pop ax
	popf
	ret


WRITE_WHITE_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)

	push cx

	mov cl,0x03			; white
	call WRITE_PIXEL

	pop cx
	ret


WRITE_PIXEL:
	; parameters:
	;  ax = pixel column number (x coordinate)
	;  bx = pixel row number (y coordinate)
	;  cl = pixel color

	pushf
	push ax
	push bx
	push cx
	push dx
	push di
	push es

	; save color in ch
	mov ch,cl

	; offset by display origin
	add ax,[PIXEL_X_OFFSET]
	add bx,[PIXEL_Y_OFFSET]

	; es:di => offset to x,y in video segment, dh = bit number
	mov es,[VIDEO_SEGMENT]
	call GET_CGA_OFFSET

	; clear pixel at location
	mov al,0x3
	mov cl,dh
	shl al,cl
	xor al,0xff			; invert white pixel to clear existing value
	and [es:di],al

	; position pixel within byte
	mov al,ch
	shl al,cl

	; 'or' pixel into video buffer
	or [es:di],al

	pop es
	pop di
	pop dx
	pop cx
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
	mov cl,[ds:COLORED_PIXELS+bp]

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
	;  cx = tile number (multiple of 4)

	pushf
	push bx
	push cx
	push dx
	push si
	push di
	push ds
	push es

	mov es,[VIDEO_SEGMENT]

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; cx = 16 rows
	mov cx,0x0010
  INVERT_TILE_LOOP:
	; es:di => offset to x,y in video segment, dh = bit number
	call GET_CGA_OFFSET

	; xor pixel row (4 bytes) into video segment
	push ax
	lodsw
	xor [es:di],ax
	lodsw
	xor [es:di+0x02],ax
	add di,0x04
	pop ax

	inc bx		; advance to next row
	loop INVERT_TILE_LOOP

	pop es
	pop ds
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	popf
	ret


; Given a tile number and location on the map, outputs a
; 4x2 block to the display.
VIEW_HELM_TILE:
	; parameters:
	;  al = tile number
	;  dl,dh = x,y tile coordinate

	pushf
	push bx

	; if terrain == water, don't output
	and al,al
	jz VIEW_HELM_TILE_DONE

	; if terrain == mountains
	cmp al,0x10
	jz VIEW_HELM_TILE_WALLS

	; if terrain is a wall
	cmp al,0x78
	jb VIEW_HELM_TILE_NOT_WALLS
	cmp al,0xf0
	jb VIEW_HELM_TILE_WALLS

  VIEW_HELM_TILE_NOT_WALLS:
	; if terrain == grass
	cmp al,0x08
	jz VIEW_HELM_TILE_GRASS

	; if terrain == forets
	cmp al,0x0c
	jz VIEW_HELM_TILE_FORESTS

	; if terrain == swamp
	cmp al,0x04
	jz VIEW_HELM_TILE_SWAMP

	; if terrain == brick
	cmp al,0x70
	jz VIEW_HELM_TILE_BRICK

	jmp VIEW_HELM_TILE_OTHER
	
  VIEW_HELM_TILE_WALLS:
	mov bl,0x00
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x00
	mov bh,0x01
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x01
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x00
	call WRITE_HELM_PIXEL

  VIEW_HELM_TILE_FORESTS:
	mov bl,0x01
	mov bh,0x01
	call WRITE_HELM_PIXEL
	mov bl,0x03
	mov bh,0x00
	call WRITE_HELM_PIXEL

  VIEW_HELM_TILE_GRASS:
	mov bl,0x01
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x03
	mov bh,0x01
	call WRITE_HELM_PIXEL

	jmp VIEW_HELM_TILE_DONE

  VIEW_HELM_TILE_SWAMP:
	mov bl,0x01
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x03
	mov bh,0x00
	call WRITE_HELM_PIXEL

	jmp VIEW_HELM_TILE_DONE

  VIEW_HELM_TILE_BRICK:
	mov bl,0x00
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x00
	mov bh,0x01
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x01
	call WRITE_HELM_PIXEL

	jmp VIEW_HELM_TILE_DONE

  VIEW_HELM_TILE_OTHER:
	mov bl,0x01
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x00
	call WRITE_HELM_PIXEL
	mov bl,0x02
	mov bh,0x01
	call WRITE_HELM_PIXEL
	mov bl,0x01
	mov bh,0x01
	call WRITE_HELM_PIXEL

  VIEW_HELM_TILE_DONE:
	pop bx
	popf
	ret


WRITE_HELM_PIXEL:
	; parameters:
	;  bl,bh = x,y of pixel w/i block
	;  dl,dh = x,y of tile

	pushf
	push ax
	push bx
	push cx

	mov ah,0x00

	; get x coordinate of pixel to write
	mov al,dl
	add al,al
	add al,al		; multiply by block width (4 pixels)
	adc al,bl		; offset to pixel w/i block

	; save x coordinate
	push ax

	; get y coordinate of pixel to write
	mov al,dh
	add al,al		; multiply by block height (2 pixels)
	adc al,bh		; offset to pixel w/i block

	; set bx = y coordinate
	mov bl,al
	mov bh,0x00

	; set ax = x coordinate
	pop ax

	; write a pixel to ax,bx
	call WRITE_WHITE_PIXEL

	pop cx
	pop bx
	pop ax
	popf
	ret


DRAW_DUNGEON_MONSTER:
	; parameters:
	;  ah = monster type (in MONSTERS file)
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
	mov ah,0x00
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

	; si = compute offset to CGA tile in shapes file
	mov al,0x20
	mul cl				; ax = tile num * 128 bytes/tile (4 * 32)
	add si,ax

	pop cx
	pop bx
	pop ax
	popf
	ret


; Calculates the offset to the pixel row+col in the video segment
GET_CGA_OFFSET:
	; parameters:
	;  ax = pixel x coordinate of tile
	;  bx = pixel y coordinate of tile
	; returns:
	;  di = video offset
	;  dh = bit offset

    pushf
    push ax
    push bx

    ; get dh = number of bits into byte
    mov dh,al
    and dh,0x03             ; last two bits are pixel index w/i byte
    shl dh,1                ; two bits per pixel

    ; set di = 0000 = offset of first page
    xor di,di

    ; determine which CGA page to write to
    shr bl,1                ; right-shift by 1 to get row # in page

    ; if carry was not set, it's the first page
    jnc GET_CGA_OFFSET_FIRST_PAGE

    ; set di = 2000 = offset of second page
    mov di,0x2000

  GET_CGA_OFFSET_FIRST_PAGE:
    ; calculate offset to row
	push ax
    mov al,0x50             ; size of CGA row = 80 bytes
    mul bl                  ; get row offset w/i page
    add di,ax               ; di => row offset within video buffer
	pop ax

    ; calculate column offset (there are 4 pixels per byte)
    shr ax,1
    shr ax,1

    ; di = offset to pixel in video buffer
    add di,ax

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


LOAD_MONSTERS_FILE:
    push bx
    push dx

    lea dx,[MONSTERS_FILE]
    lea bx,[MONSTERS_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
