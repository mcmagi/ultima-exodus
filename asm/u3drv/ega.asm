; EGA.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade EGA driver.  Despite the name, it does not use any EGA video
; modes instead uses VGA video mode 0x13.  Emulates EGA by limiting video output
; to 16 colors.  EGA data is packed with two pixels per byte and therefore must
; be unpacked to one pixel per byte before outputting to the video buffer at 
; segment address A000.

; ===== start jumps into code here =====
include 'vidjmp.asm'


; ===== data here =====

CHARSET_FILE    db      "CHARSET.EGA",0
SHAPES_FILE     db      "SHAPES.EGA",0
MOONS_FILE      db      "MOONS.EGA",0
BLANK_FILE      db      "BLANK.EGA",0
EXOD_FILE       db      "EXOD.EGA",0
ANIMATE_FILE    db      "ANIMATE.EGA",0
ENDGAME_MASK    dw      0x0e0e,0x0c0c,0x0909,0x0e0e,0x0909,0x0505,0x0606
VIDEO_SEGMENT   dw      0x0a000
DRIVER_INIT     db      0
CHARSET_ADDR    dd      0
SHAPES_ADDR     dd      0
MOONS_ADDR      dd      0
BLANK_ADDR      dd      0
EXOD_ADDR       dd      0
ANIMATE_ADDR    dd      0


; ===== video driver functions here =====

INIT_DRIVER:
    pushf
    push ax

    ; don't reinitialize driver
    cmp [DRIVER_INIT],0x01
    jz INIT_DRIVER_DONE

    ; set vga video mode
    mov ah,0x00
    mov al,0x13
    int 0x10

    ; initialization of cursor is in game code

    mov [DRIVER_INIT],0x01

  INIT_DRIVER_DONE:
    pop ax
    popf
    ret


CLOSE_DRIVER:
    pushf
    push bx

    ; free shapes
    lea bx,[SHAPES_ADDR]
    call FREE_GRAPHIC_FILE

    ; free charset
    lea bx,[CHARSET_ADDR]
    call FREE_GRAPHIC_FILE

    ; free moons
    lea bx,[MOONS_ADDR]
    call FREE_GRAPHIC_FILE

    ; free blank image
    lea bx,[BLANK_ADDR]
    call FREE_GRAPHIC_FILE

    ; free exodus image
    lea bx,[EXOD_ADDR]
    call FREE_GRAPHIC_FILE

    ; free intro animation
    lea bx,[ANIMATE_ADDR]
    call FREE_GRAPHIC_FILE

    pop bx
    popf
    ret


; no buffer in EGA mode
FLUSH_GAME_MAP:
    ret


; Outputs pixels to the appropriate location on the peer gem window
; for a given map object.
DRAW_GEM_BLOCK:
    ; parameters:
    ;  al = map object
    ;  cl = map column
    ;  ch = map row

    pushf
    push ax
    push dx

    ; Here were determine color information based on the map object.
    ; Each nybble of ah represents a color to "dither" to the output block.

    ; default object color is light grey
    mov ah,0x77

  DRAW_GEM_WATER:
    cmp al,0x00
    jnz DRAW_GEM_GRASS

    ; found water tile (blue)
    mov ah,0x11
    jmp DRAW_GEM_DONE

  DRAW_GEM_GRASS:
    cmp al,0x04
    jnz DRAW_GEM_BRUSH

    ; found grass tile (dithered black & green)
    mov ah,0x02
    jmp DRAW_GEM_DONE

  DRAW_GEM_BRUSH:
    cmp al,0x08
    jnz DRAW_GEM_FOREST

    ; found brush tile (green)
    mov ah,0x22
    jmp DRAW_GEM_DONE

  DRAW_GEM_FOREST:
    cmp al,0x0c
    jnz DRAW_GEM_MOUNTAINS

    ; found forest tile (dithered green & light green)
    mov ah,0x2a
    jmp DRAW_GEM_DONE

  DRAW_GEM_MOUNTAINS:
    cmp al,0x10
    jnz DRAW_GEM_BRICK

    ; found mountains tile (brown)
    mov ah,0x66
    jmp DRAW_GEM_DONE

  DRAW_GEM_BRICK:
    cmp al,0x20
    jnz DRAW_GEM_FORCE

    ; found brick tile (dithered black & red)
    mov ah,0x04
    jmp DRAW_GEM_DONE

  DRAW_GEM_FORCE:
    cmp al,0x80
    jnz DRAW_GEM_LAVA

    ; found force field tile (yellow)
    mov ah,0xee
    jmp DRAW_GEM_DONE

  DRAW_GEM_LAVA:
    cmp al,0x84
    jnz DRAW_GEM_WALL

    ; found lava tile (red)
    mov ah,0x44
    jmp DRAW_GEM_DONE

  DRAW_GEM_WALL:
    cmp al,0x8c
    jnz DRAW_GEM_DONE

    ; found wall tile (white)
    mov ah,0xff

  DRAW_GEM_DONE:
    ; call write_gem_block(ah,cl,ch)
    call WRITE_GEM_BLOCK

    pop dx
    pop ax
    popf
    ret


; Cycle order is as follows:
;  step 0, ah=00
;  step 1, ah=cc
;  repeat...
CYCLE_GEM_BLOCK:
    ; parameters:
    ;  al = step (0-3)
    ;  cl = map column
    ;  ch = map row

    pushf
    push ax

    ; get even or odd step
    and al,0x01

    ; color is either 00 or cc
    mov ah,0xcc
    mul ah

    ; set ah = color
    mov ah,al
    call WRITE_GEM_BLOCK

    pop ax
    popf
    ret


; Outputs all four pixels of a gem block.  Each 4-pixel block represents
; a tile on the map.
WRITE_GEM_BLOCK:
    ; parameters:
    ;  ah = color to write
    ;  cl = map column
    ;  ch = map row

    ; store
    push ax
    push bx
    push cx
    push dx
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; cl *= 2, ch *= 2 (each gem object is a 2x2 block)
    shl cl,1
    shl ch,1

    ; cl += 20, ch += 20 (offset to col 20, row 20 of screen)
    add ch,0x20
    add cl,0x20

    ; we need ax for multiplication for a sec...
    push ax

    ; set ax = row
    mov al,ch
    mov ah,0x00

    ; ax *= 0140h (320 dec) - offset of row in video segment
    mov dx,0x0140
    mul dx

    ; set bx = ax
    mov bx,ax

    ; ok, restore it back to the color data that was input
    pop ax

    ; bx += cl - add column position to video data offset
    ; (have to figure bl/bh separately so be sure to add carry)
    add bl,cl
    adc bh,0x00

    ; unpack color information
    mov al,ah
    call UNPACK_EGA_VIDEO_DATA

    ; toggle top row into video buffer
    xor [es:bx],ax

    ; toggle bottom row into video buffer
    xchg al,ah
    xor [es:bx+0x0140],ax

    ; restore and return
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    ret


SCROLL_TEXT_WINDOW:
    push ax
    push bx
    push cx
    push dx
    push bp

    ; scroll window up 1 line from line 11,18 to 17,27
    mov al,0x01
    mov bh,0x00
    mov ch,0x11
    mov cl,0x18
    mov dh,0x17
    mov dl,0x27
    mov ah,0x06
    int 0x10

    ; drawing the ">" character is in game code

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret


DRAW_GAME_BORDER:
    pushf
    push ax
    push bx
    push cx
    push dx

    ; this doesn't seem necessary...
    mov ax,0x0000

    ; clear the screen
    call CLEAR_SCREEN

    ; set color = 0909 (two light blue pixels)
    mov ax,0x0909

    ; draw left border of game map (row 0x00, column 0x00)
    mov bx,0x0000
    mov dl,0x00
    mov cx,0x0018
    call DRAW_VERTICAL_BORDER

    ; draw right border of game map (row 0x00, column 0xb8)
    mov bx,0x00b8
    mov dl,0x00
    mov cx,0x0018
    call DRAW_VERTICAL_BORDER

    ; draw top border of game map (row 0x00, column 0x00)
    mov bx,0x0000
    mov dl,0x00
    mov cx,0x0018
    call DRAW_HORIZONTAL_BORDER

    ; draw bottom border of game map (row 0xb8, column 0x00)
    mov bx,0x0000
    mov dl,0xb8
    mov cx,0x0018
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame top border (row 0x00, column 0xc0)
    mov bx,0x00c0
    mov dl,0x00
    mov cx,0x0011
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame first divider (row 0x20, column 0xc0)
    mov bx,0x00c0
    mov dl,0x20
    mov cx,0x0011
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame second divider (row 0x40, column 0xc0)
    mov bx,0x00c0
    mov dl,0x40
    mov cx,0x0011
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame third divider (row 0x60, column 0xc0)
    mov bx,0x00c0
    mov dl,0x60
    mov cx,0x0011
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame bottom border (row 0x80, column 0xc0)
    mov bx,0x00c0
    mov dl,0x80
    mov cx,0x0011
    call DRAW_HORIZONTAL_BORDER

    ; draw party frame right border (row 0, column 138)
    mov bx,0x0138
    mov dl,0x00
    mov cx,0x0011
    call DRAW_VERTICAL_BORDER

    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


DRAW_MENU_BORDER:
    pushf
    push ax
    push bx
    push cx
    push dx

    ; clear bottom row (row c0, column 0x00)
    mov ax,0x0000
    mov bx,0x0000
    mov dl,0xc0
    mov cx,0x0028
    call DRAW_HORIZONTAL_BORDER

    ; set color = light blue
    mov ax,0x0909

    ; draw lower border around demo map (row 0xb8, column 0x00)
    mov bx,0x0000
    mov dl,0xb8
    mov cx,0x0028
    caLL DRAW_HORIZONTAL_BORDER

    ; draw upper border around demp map (row 0x50, column 0x08)
    mov bx,0x0008
    mov dl,0x50
    mov cx,0x0026
    call DRAW_HORIZONTAL_BORDER

    ; draw left border of demo map (row 0x50, column 0x00)
    mov bx,0x0000
    mov dl,0x50
    mov cx,0x000e
    call DRAW_VERTICAL_BORDER

    ; draw right border of demo map (row 0x50, column 0x0138)
    mov bx,0x0138
    mov dl,0x50
    mov cx,0x000e
    call DRAW_VERTICAL_BORDER

    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


DRAW_VERTICAL_BORDER:
    ; parameters:
    ;  ax = video data to write
    ;  bx = starting column
    ;  cx = number of rows to write
    ;  dl = starting row

    push bx
    push dx
    push di

    ; bx => starting offset
    call GET_VGA_OFFSET
    mov bx,di

    mov dx,0x0a00       ; move forward 8 rows
    call DRAW_BORDER

    pop di
    pop dx
    pop bx
    ret


DRAW_HORIZONTAL_BORDER:
    ; parameters:
    ;  ax = video data to write
    ;  bx = starting offset
    ;  cx = number of rows to write

    push bx
    push dx
    push di

    ; bx => starting offset
    call GET_VGA_OFFSET
    mov bx,di

    mov dx,0x0008       ; move forward 8 columns
    call DRAW_BORDER

    pop di
    pop dx
    pop bx
    ret


DRAW_BORDER:
    ; parameters:
    ;  ax = video data to write
    ;  bx = starting offset
    ;  cx = number of rows to write
    ;  dx = number of bytes to advance

    pushf
    push bx
    push cx

  DRAW_BORDER_LOOP:
    call WRITE_BORDER_BLOCK
    add bx,dx
    loop DRAW_BORDER_LOOP

    pop cx
    pop bx
    popf
    ret


; Clears the entire game window (to black)
CLEAR_GAME_WINDOW:
    push ax
    push bx
    push cx
    push dx
    push bp

    ; clear window from [text] line 01,01 to 16,16
    mov bx,0x0000
    mov cx,0x0101
    mov dx,0x1616
    mov ax,0x0600
    int 0x10

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret


CLEAR_DEMO_WINDOW:
    push ax
    push bx
    push cx
    push dx
    push bp

    ; clear window from lines 0b,01 to 16,26
    mov al,0x00
    mov ch,0x0b
    mov cl,0x01
    mov dh,0x16
    mov dl,0x26
    mov bh,0x00
    mov ah,0x06
    int 0x10

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; Displays a character in the text window
DISPLAY_CHAR:
    ; parameters:
    ;  al = ASCII character
    ;  cl = column position
    ;  ch = row position

    push bx
    push dx
    push si

    ; dx:si => charset file
    lea bx,[CHARSET_ADDR]
    mov si,[bx]
    mov dx,[bx+0x02]

    call DISPLAY_CHAR_COMMON

    pop si
    pop dx
    pop bx
    ret


; Displays a character with a provided charset in dx:si
DISPLAY_CHAR_COMMON:
    ; parameters:
    ;  al = ASCII character
    ;  cl = column position
    ;  ch = row position
    ;  dx:si => charset file

    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    push ds
    push es
    cld

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; check that charset is loaded
    and dx,dx
    jz DISPLAY_CHAR_NO_CHARSET

    ; ds:si => charset file
    mov ds,dx

    ; calculate offset into charset.ult
    mov ah,0x00
    mov dx,0x0020       ; 0x20 bytes per EGA character
    mul dx              ; offset from start ofcharset.ult to start of char
    add si,ax           ; SI = offset from start of segment to start of char

    ; calculate row offset into video buffer
    mov ah,0x00
    mov al,ch
    mov dx,0x0a00       ; 0xa00 bytes in 1 VGA 40-char row
    mul dx              ; # of bytes to start of row number
    mov bx,ax

    ; calculate col offset starting at row offset
    mov ah,0x00
    mov al,cl
    mov dl,0x08
    mul dl              ; 8 bytes across 1 VGA column

    ; offset into video buffer for start of text
    add bx,ax

    ; set vars for loop
    mov di,0x0000
    mov cx,0x0008

  DISPLAY_CHAR_ROW_LOOP:
    mov dx,0x0004

  DISPLAY_CHAR_COL_LOOP:
    ; read a byte, unpack, and write a word
    lodsb
    call UNPACK_EGA_VIDEO_DATA

    mov [es:bx+di],ax
    add di,0x0002       ; move DI forward by one word
    dec dx
    jnz DISPLAY_CHAR_COL_LOOP

    add di,0x0138       ; move DI to beginning of next row
    loop DISPLAY_CHAR_ROW_LOOP

  DISPLAY_CHAR_DONE:
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

  DISPLAY_CHAR_NO_CHARSET:
    ; set system cursor position
    mov ah,0x02
    mov bh,0x00
    mov dx,cx
    int 0x10

    ; display character using system charset
    mov ah,0x09
    mov bl,0x0f
    mov cx,0x0001
    int 0x10

    jmp DISPLAY_CHAR_DONE


; Translates a moon number to a moon character for display
DISPLAY_MOON_CHAR:
    ; parameters:
    ;  al = moon number (0-7)
    ;  cl = column position
    ;  ch = row position

    pushf
    push ax
    push bx
    push dx
    push si

    ; remove high bits
    and al,0x07

    ; dx:si => charset file
    lea bx,[MOONS_ADDR]
    mov si,[bx]
    mov dx,[bx+0x02]

    call DISPLAY_CHAR_COMMON

    pop si
    pop dx
    pop bx
    pop ax
    popf
    ret


; Outputs an 8x8 block used for building the border
WRITE_BORDER_BLOCK:
    ; parameters
    ;  ax = word to write
    ;  bx = byte offset into row

    push cx
    push di
    push ds

    ; get video data
    mov ds,[VIDEO_SEGMENT]

    ; clear di & set cx = 8 for outer loop
    mov di,0x0000
    mov cx,0x0008

  WRITE_BORDER_BLOCK_ROW_LOOP:
    push cx
    mov cl,0x04

  WRITE_BORDER_BLOCK_COL_LOOP:
    mov [bx+di],ax
    add di,0x0002
    loop WRITE_BORDER_BLOCK_COL_LOOP

    ; advance to next row
    pop cx
    add di,0x0138
    loop WRITE_BORDER_BLOCK_ROW_LOOP

    pop ds
    pop di
    pop cx
    mov ax,ax       ; set flags?
    ret


DISPLAY_TILE:
    ; parameters:
    ;  bx = starting pixel column of game map
    ;  ch = # of tiles down (y coordinate)
    ;  cl = # of tiles across (x coordinate)
    ;  dh = tile number
    ;  dl = starting pixel row of game map

    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; ds:si => shapes file
    push bx
    lea bx,[SHAPES_ADDR]
    mov si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax
    pop bx

    ; get vga offset
    mov ax,di
    call CGA_TO_VGA_OFFSET
    mov di,ax

    ; calculate offset to start of tile
    push dx
    mov ax,0x0080           ; size of one EGA tile in bytes
    mov dl,dh
    mov dh,0x00
    mul dx
    pop dx

    ; calculate offset to tile within shapes file
    add si,ax

    ; get pixel row of tile
    shl ch,1
    shl ch,1
    shl ch,1
    shl ch,1                ; multiply tile row * 16
    add dl,ch

    ; get pixel column of tile
    xor ch,ch
    shl cx,1
    shl cx,1
    shl cx,1
    shl cx,1                ; multiply tile column * 16
    add bx,cx

    ; set di = starting offset of game map in video buffer
    call GET_VGA_OFFSET

    ; make sure direction flag is clear
    cld

    ; prepare to write 0x10 (16) rows
    mov cx,0x0010

  DISPLAY_TILE_ROW:
    ; prepare to write 0x08 words within the row (16 columns)
    push cx
    mov cl,0x08

  DISPLAY_TILE_COLUMN:
    ; read byte from ds:si (shapes), unpack, and write word to es:di (video)
    lodsb
    call UNPACK_EGA_VIDEO_DATA
    stosw
    loop DISPLAY_TILE_COLUMN

    ; loop to next row
    add di,0x0130           ; distance to beginning of next row w/i tile
    pop cx
    loop DISPLAY_TILE_ROW

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


; Given a byte offset into a CGA video buffer, calculates the corresponding
; byte offset into the VGA video buffer.
CGA_TO_VGA_OFFSET:
    ; parameters:
    ;  ax = CGA offset
    ; returns:
    ;  ax = VGA offset

    pushf
    push cx
    push dx
    
    ; first, we find the x,y pixel coordinates

    ; performs y = CGA Offset / CGA width * 2
    ;  (the * 2 is because the CGA buffer is interlaced)
    mov cx,0x0050       ; CGA width in bytes
    xor dx,dx
    div cx
    mov cx,dx           ; save the remainder
    shl ax,1            ; this is the y coordinate

    ; x = remainder (row offset) * 4 (or 8 bits/byte / 2 bpp)
    shl cx,1
    shl cx,1

    ; next, we find the VGA offset from the pixel coordinates

    ; VGA Offset = VGA width * y + x
    mov dx,0x0140       ; VGA width in bytes
    mul dx
    add ax,cx           ; VGA offset

    pop dx
    pop cx
    popf
    ret


CLEAR_SCREEN:
    pushf
    push ax
    push cx
    push di
    push es

    ; clear ax & direction flag
    mov ax,0x0000
    cld

    ; set es:di to start of video segment
    mov es,[VIDEO_SEGMENT]
    mov di,0x0000

    ; write 320x200 bytes to video seg
    mov cx,0x7d00
    repz
    stosw

    ; setting the cursor position happens in game code

    pop es
    pop di
    pop cx
    pop ax
    popf
    ret


SCROLL_TILE:
    ; parameters:
    ;  bl = tile number

    pushf
    push ax
    push bx
    push cx
    push es

    ; es:bx => tile in shapes file
    call GET_TILE_OFFSET
    mov bx,ax

    mov cx,0x0004

  SCROLL_TILE_ROW:
    mov ax,[es:bx]
    push cx
    push bx

    mov cl,0x0f
  SCROLL_TILE_COL:
    add bx,0x08
    xchg ax,[es:bx]
    loop SCROLL_TILE_COL

    pop bx
    pop cx
    mov [es:bx],ax
    add bx,0x0002
    loop SCROLL_TILE_ROW

    pop es
    pop cx
    pop bx
    pop ax
    popf
    ret


SWAP_TILE_ROWS:
    ; parameters:
    ;  bl = tile number
    ;  ch = row 1
    ;  cl = row 2
    
    pushf
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push es

    ; es:ax = es:bx => tile in shapes file
    call GET_TILE_OFFSET
    mov bx,ax

    ; cl = row # * 8 bytes/row = byte offset for row
    shl cl,1
    shl cl,1
    shl cl,1

    ; set es:di => first row in shapes file
    add al,cl
    adc ah,0x00
    mov di,ax

    ; ch = row # * 8 bytes/row = byte offset for row
    shl ch,1
    shl ch,1
    shl ch,1

    ; set ds:si => second row in shapes file
    add bl,ch
    adc bh,0x00
    mov si,bx
    push es
    pop ds

    ; swap four words (8 bytes) of tile row
    mov cx,0x0004
    call REP_XCHGSW

    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    popf
    ret


SWAP_TILES:
    ; parameters:
    ;  bl = tile number 1
    ;  bh = tile number 2

    pushf
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push es

    cld

    ; es:di => tile 1 in shapes file
    call GET_TILE_OFFSET
    mov di,ax

    ; set bl = tile number 2
    mov bl,bh

    ; ds:si => tile 2 in shapes file
    call GET_TILE_OFFSET
    mov si,ax
    push es
    pop ds

    ; swap 0x40 words
    mov cx,0x0040
    call REP_XCHGSW

    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    popf
    ret


GET_TILE_OFFSET:
    ; parameters:
    ;  bl = tile number
    ; returns:
    ;  es:ax => tile in shapes file

    pushf
    push bx
    push dx
    push bp

    ; set ax = tile offset
    xor bh,bh
    mov ax,0x0080           ; size of EGA tile
    mul bx
    mov bx,ax

    ; es:dx => shapes file
    lea bp,[SHAPES_ADDR]
    mov dx,[ds:bp]
    mov ax,[ds:bp+0x02]
    mov es,ax

    ; es:ax => tile in shapes file
    mov ax,bx
    add ax,dx

    pop bp
    pop dx
    pop bx
    popf
    ret


INVERT_PARTY_MEMBER_BOX:
    pushf
    push ax
    push bx
    push cx
    push dx
    push ds

    ; get video segment
    mov ds,[VIDEO_SEGMENT]

    ; set dl = number of rows to loop through
    mov dl,0x18

    ; compute row offset
    mov ah,0x00
    mov bl,0x28
    mul bl
    add al,0x0a
    mov bh,al

    ; compute column offset
    mov bl,0xc0

    ; loop for each row
  INVERT_PARTY_MEMBER_BOX_ROW_LOOP:

    ; loop for each column
    mov cx,0x003c
  INVERT_PARTY_MEMBER_BOX_COL_LOOP:

    ; invert word in row
    xor word [bx],0x0f0f

    ; advance to next word
    inc bx
    inc bx
    loop INVERT_PARTY_MEMBER_BOX_COL_LOOP

    ; advance to next row
    add bx,0x00c8
    dec dl
    jnz INVERT_PARTY_MEMBER_BOX_ROW_LOOP

    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


INVERT_GAME_SCREEN:
    push ax

    ; invert by white
    mov ax,0x0f0f
    call INVERT_GAME_SCREEN_WITH_MASK

    pop ax
    ret


INVERT_ENDGAME_SCREEN:
    ; parameters:
    ;  al = step number

    pushf
    push ax
    push bx

    ; step number must be 0-6, so get mod 7
    xor ah,ah
    mov bl,0x07
    div bl

    ; get offset into endgame inversion mask
    lea bx,[ENDGAME_MASK]
    add bl,ah
    adc bh,0x00

    ; invert by specified mask
    mov ax,[bx]
    call INVERT_GAME_SCREEN_WITH_MASK

    pop bx
    pop ax
    popf
    ret


INVERT_GAME_SCREEN_WITH_MASK:
    ; parameters:
    ;  ax = inversion mask

    pushf
    push bx
    push cx
    push dx
    push ds

    ; get video segment
    mov ds,[VIDEO_SEGMENT]

    ; set bx = start of game map
    mov bx,0x0a08

    ; loop for each row
    mov dx,0x00b0
  INVERT_GAME_SCREEN_ROW_LOOP:

    ; loop for each word in a row
    mov cx,0x0058
  INVERT_GAME_SCREEN_COL_LOOP:

    ; invert word in row
    xor word [bx],ax

    ; advance to next word
    inc bx
    inc bx
    loop INVERT_GAME_SCREEN_COL_LOOP

    ; advance to next row
    add bx,0x0090
    dec dx
    jnz INVERT_GAME_SCREEN_ROW_LOOP

    pop ds
    pop dx
    pop cx
    pop bx
    popf
    ret


INVERT_PARTY_MEMBER_NUMBER:
    ; parameters:
    ;  al = party member number

    pushf
    push ax
    push bx
    push cx
    push ds

    ; get video segment
    mov ds,[VIDEO_SEGMENT]

    mov ah,0x00
    dec al
    mov bl,0x28
    mul bl
    mov bh,al
    mov bl,0xf8

    ; loop for each row
    mov cx,0x0008
  INVERT_NUMBER_ROW_LOOP:
    push cx

    ; loop for each word in row
    mov cl,0x04
  INVERT_NUMBER_WORD_LOOP:
    xor word [bx],0x0f0f
    inc bx
    inc bx
    loop INVERT_NUMBER_WORD_LOOP

    pop cx
    add bx,0x0138       ; advance to next row
    loop INVERT_NUMBER_ROW_LOOP

    pop ds
    pop cx
    pop bx
    pop ax
    popf
    ret


DISPLAY_BLANK_INTRO:

    pushf
    push ax
    push bx
    push cx
    push si
    push di
    push ds
    push es

    cld

    ; es:di => video buffer
    mov es,[VIDEO_SEGMENT]
    xor di,di

    ; ds:si => blank file
    lea bx,[BLANK_ADDR]
    mov si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax

    ; prepare to copy 0x7d00 bytes from blank.ega to video buffer
    mov cx,0x7d00

  DISPLAY_BLANK_INTRO_LOOP:
    ; load byte, unpack to word, write word
    lodsb
    call UNPACK_EGA_VIDEO_DATA
    stosw
    loop DISPLAY_BLANK_INTRO_LOOP

    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    popf
    ret


; Copies an 8-pixel line of the EXOD.EGA file to the video buffer.  The starting
; column must begin at a byte offset (or it will be rounded down to one).
DISPLAY_EXOD_LINE:
    ; parameters:
    ;  ax = 0000 to write blanks, non-zero otherwise
    ;  bx = starting column
    ;  dl = starting row on source
    ;  dh = starting row on destination

    pusha
    push ds
    push es

    ; inline SET_SEGMENT for performance
    push cs
    pop ds

    cld

    ; prepare to write 4 words (8 pixels)
    mov cx,0x0004

    ; si = offset of pixel within EXOD.EGA
    call GET_VGA_OFFSET
    mov si,di
    shr si,1                ; EGA offset is VGA offset / 2

    ; es:di => starting pixel on video buffer
    xchg dl,dh
    mov es,[VIDEO_SEGMENT]
    call GET_VGA_OFFSET

    ; check if we are writing zero
    and ax,ax
    jz DISPLAY_EXOD_LINE_BLANK

    ; ds:si => starting pixel in EXOD.EGA
    lea bx,[EXOD_ADDR]
    add si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax

  DISPLAY_EXOD_LOOP:
    ; read byte, unpack, and output 2 pixels
    lodsb
    call UNPACK_EGA_VIDEO_DATA
    stosw
    loop DISPLAY_EXOD_LOOP

  DISPLAY_EXOD_LINE_DONE:
    pop es
    pop ds
    popa
    retf

  DISPLAY_EXOD_LINE_BLANK:
    rep stosw
    jmp DISPLAY_EXOD_LINE_DONE


DISPLAY_LORDBRIT_PIXEL:
    ; parameters:
    ;  cl = column number from pixel 0x14 (in pixels)
    ;  ch = row number (in pixels)

    pushf
    push ax
    push bx
    push dx

    ; set al = lt cyan
    mov al,0x0b

    ; set dl = row number
    mov dl,ch

    ; set bx = actual column number
    mov bl,cl
    xor bh,bh
    add bx,0x0014

    ; output pixel
    call WRITE_PIXEL

    pop dx
    pop bx
    pop ax
    popf
    ret


WRITE_PIXEL:
    ; parameters:
    ;  al = pixel to write
    ;  bx = pixel column number
    ;  dl = pixel row number

    pushf
    push ax
    push di
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; make sure it's a 4-bit color
    and al,0x0f

    ; get cga offset
    call GET_VGA_OFFSET

    ; now write actual pixel
    mov [es:di],al

    pop es
    pop di
    pop ax
    popf
    ret


DISPLAY_ANIMATION_FRAME:
    ; parameters:
    ;  al = sequence number (0-3)
    ;  bl = column offset from pixel 0x14, counts once every 2 pixels
    ;       l.o. bit determines frame 0 or 1 in sequence

    pushf
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es

    cld

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; set bx = starting column number
    shl bx,1
    add bx,0x0014

    ; set dl = starting row number
    mov dl,0x00a8

    ; es:di => animation location in video buffer
    call GET_VGA_OFFSET

    ; si = offset to desired sequence in ANIMATE.EGA
    mov cx,0x0b80           ; # of bytes per sequence
    mul cx
    mov si,ax

    ; determine frame 0 or 1 in sequence
    mov dx,bx
    and dx,0x0003           ; dx = 0 for frame 0, 2 for frame 1

    ; si = offset to desired frame in ANIMATE.EGA
    mov ax,0x02e0           ; 1/2 size of frame (since dx is double)
    mul dx
    add si,ax

    ; ds:si => starting pixel in ANIMATE.EGA
    lea bx,[ANIMATE_ADDR]
    add si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax

    ; row loop counter
    mov cx,0x0010
  DISPLAY_ANIMATION_FRAME_ROW_LOOP:

    ; clear word before frame row
    mov word [es:di-0x02],0x0000

    ; column loop counter (counts every two pixels)
    mov dl,0x002e
  DISPLAY_ANIMATION_FRAME_COL_LOOP:
    ; read a byte, unpack, it and store as word
    lodsb
    call UNPACK_EGA_VIDEO_DATA
    stosw

    ; advance to next column
    dec dl
    jnz DISPLAY_ANIMATION_FRAME_COL_LOOP

    ; clear word after frame row
    mov word [es:di],0x0000

    ; advance to next row
    add di,0x00e4           ; distance to next frame row (0x0140-2*0x2e)
    loop DISPLAY_ANIMATION_FRAME_ROW_LOOP

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


DRAW_DUNGEON_WALL_LINE:
    ; parameters:
    ;  ah = current "block" number
    ;  cl = column
    ;  ch = top row
    ;  dl = bottom row

    pushf
    push ax
    push cx

    cmp ah,0x20
    ja DRAW_DUNGEON_DOOR_LINE

    ; draw brown wall
    mov al,0x06
    call DRAW_VERTICAL_LINE
    jmp DRAW_DUNGEON_WALL_LINE_DONE

  DRAW_DUNGEON_DOOR_LINE:
    ; draw grey door
    mov al,0x07
    call DRAW_VERTICAL_LINE
    inc cl
    call DRAW_VERTICAL_LINE

  DRAW_DUNGEON_WALL_LINE_DONE:
    pop cx
    pop ax
    popf
    ret


DRAW_DUNGEON_CHEST_LINE:
    ; parameters:
    ;  ah = current "block" number
    ;  cl = column
    ;  ch = top row
    ;  dl = bottom row

    pushf
    push ax

    ; draw yellow chest
    mov al,0x0e
    call DRAW_VERTICAL_LINE

    pop ax
    popf
    ret


DRAW_VERTICAL_LINE:
    ; parameters:
    ;  ah = current "block" number (20 for doorway at 00)
    ;  al = color to write
    ;  cl = column
    ;  ch = top row
    ;  dl = bottom row

    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; offset column by 20 pixels
    add cl,0x20

    ; set dh = # of rows
    mov dh,dl
    sub dh,ch

    ; set dl = starting row (offset by 20 pixels)
    mov dl,ch
    add dl,0x0020

    ; set bx = starting column
    mov bl,cl
    mov bh,0x00

    ; es:di => location to write line
    call GET_VGA_OFFSET

    ; if ah == 0x20 (in doorway), handle it differently
    cmp ah,0x20
    jz DRAW_VERTICAL_LINE_DOOR

  DRAW_VERTICAL_LINE_WALL_LOOP:
    ; move pixel into video buffer
    or [es:di],al

    ; advance to next row
    add di,0x0140
    dec dh
    jnz DRAW_VERTICAL_LINE_WALL_LOOP

    jmp DRAW_VERTICAL_LINE_DONE

  DRAW_VERTICAL_LINE_DOOR:

    ; set pixel = black
    mov al,0x00

  DRAW_VERTICAL_LINE_DOOR_LOOP:
    ; and pixel into both pages
    and [es:di],al

    ; advance to next row
    add di,0x0140
    dec dh
    jnz DRAW_VERTICAL_LINE_DOOR_LOOP

  DRAW_VERTICAL_LINE_DONE:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


DRAW_DUNGEON_LADDER_PIXEL:
DRAW_PIXEL:
    ; parameters:
    ;  ch = row number
    ;  cl = column number

    mov al,0x0f

    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; offset row/column by 20 pixels
    add ch,0x20
    add cl,0x20

    ; set bx = column
    mov bl,cl
    mov bh,0x00

    ; set dl = row
    mov dl,ch

    ; es:di => location to write pixel
    call GET_VGA_OFFSET

    ; write pixel into video buffer
    stosb

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


; ===== file handling functions here =====

LOAD_SHAPES_FILE:
    push bx
    push dx

    lea dx,[SHAPES_FILE]
    lea bx,[SHAPES_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


LOAD_CHARSET_FILE:
    pushf
    push ax
    push bx
    push dx

    lea dx,[CHARSET_FILE]
    lea bx,[CHARSET_ADDR]
    call LOAD_GRAPHIC_FILE
    jc LOAD_CHARSET_FILE_DONE

    lea dx,[MOONS_FILE]
    lea bx,[MOONS_ADDR]
    call LOAD_GRAPHIC_FILE

  LOAD_CHARSET_FILE_DONE:
    pop dx
    pop bx
    pop ax
    popf
    ret


LOAD_BLANK_FILE:
    push bx
    push dx

    lea dx,[BLANK_FILE]
    lea bx,[BLANK_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


LOAD_EXOD_FILE:
    push bx
    push dx

    lea dx,[EXOD_FILE]
    lea bx,[EXOD_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


LOAD_ANIMATE_FILE:
    push bx
    push dx

    lea dx,[ANIMATE_FILE]
    lea bx,[ANIMATE_ADDR]
    call LOAD_GRAPHIC_FILE

    pop dx
    pop bx
    ret


; ===== supporting libraries =====

include '../common/video/vga.asm'
include '../common/vidfile.asm'
include '../common/xchgs.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
