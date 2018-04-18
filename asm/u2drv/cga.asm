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
VIDEO_SEGMENT   dw      0xb800
DRIVER_INIT		db		0
TILESET_ADDR	db		0


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
	push dx
	push di
	push si
	push ds
	push es

	mov es,[VIDEO_SEGMENT]

	; ds:si => tile in shapes file
	call GET_TILE_ADDRESS

	; dl = 16 rows
	mov dl,0x10

  DRAW_TILE_LOOP:
	; es:di => offset to x,y in video segment, dh = bit number
	call GET_CGA_OFFSET

	; transfer pixel row (4 bytes) to video segment
	movsw
	movsw

	dec dl
	jnz DRAW_TILE_LOOP

	pop es
	pop ds
	pop si
	pop di
	pop dx
	pop ax
	popf
	ret


ROTATE_TILE:
	ret


INVERT_GAME_SCREEN:
	ret


CLEAR_GAME_SCREEN:
	pushf
	push ax
	push cx
	push di
	push es

	mov es,[VIDEO_SEGMENT]

	; set data = 0 (row of 8 black vga pixels)
	mov ax,0x0000

	; write black pixels to first page
	mov di,0x0000
	mov cx,0x0fa0
	rep
	stosw

	; write black pixels to second page
	mov di,0x2000
	mov cx,0x0fa0
	rep
	stosw

	pop es
	pop di
	pop cx
	pop ax
	popf
	ret


WRITE_PIXEL:
	ret


CLEAR_PIXEL:
	ret


INVERT_TILE:
	ret ; for now
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
    mov al,0x50             ; size of CGA row = 0x50
    mul bl                  ; get row offset w/i page
    add di,ax               ; di => row offset within video buffer

    ; get dh = number of bits into byte
    mov dh,bl
    and dh,0x03             ; last two bits are pixel index w/i byte
    shl dh,1                ; two bits per pixel

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


include '../common/vidfile.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
