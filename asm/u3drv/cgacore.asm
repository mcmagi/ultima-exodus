; CGACORE.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade common CGA routines.  Shared by both the standard CGA and
; composite CGA drivers.  Most of this code was extracted from the U3 binaries
; since CGA was the default display mode.  CGA data is written to the video
; buffer defined by the master assembly program.

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

    ; Here we determine color and pixel information based on the map object.
    ; Color information for all 4 pixels to be output is condensed within ah
    ; while which pixel gets written is contained within dx.

    ; set ah = 00 (color = BBBB)
    xor ah,ah

    ; if al == 00 (water)
    cmp al,0x00
    jz DRAW_GEM_END

    ; set ah = 40 (color = BWBB)
    mov ah,0x40

    ; if al == 04 (grass)
    cmp al,0x04
    jz DRAW_GEM_GRASS

    ; if al == 08 (brush)
    cmp al,0x08
    jz DRAW_GEM_BRUSH

    ; if al == 0c (forest)
    cmp al,0x0c
    jz DRAW_GEM_FOREST

    ; set ah = c0 (color = WBBB)
    mov ah,0xc0

    ; if al = 10 (mountain)
    cmp al,0x10
    jz DRAW_GEM_WALL

    ; if al = 20 (brick)
    cmp al,0x20
    jz DRAW_GEM_BRICK

    ; if al = 8c (wall)
    cmp al,0x8c
    jz DRAW_GEM_WALL

    ; all else...
    jmp DRAW_GEM_OTHER

  DRAW_GEM_GRASS:
    ; call write_gem_pixel(0001 or 0101)
    mov dh,cl
    and dh,0x01
    mov dl,0x01
    call WRITE_GEM_PIXEL

    ; done drawing
    jmp DRAW_GEM_END

  DRAW_GEM_BRUSH:
    ; brush, forest, mountains, & walls

    ; call write_gem_pixel(0101)
    mov dx,0x0101
    call WRITE_GEM_PIXEL

    ; done drawing
    jmp DRAW_GEM_END

  DRAW_GEM_FOREST:
    ; forest, mountains & walls

    ; call write_gem_pixel(0001)
    mov dx,0x0001
    call WRITE_GEM_PIXEL

    ; kinda silly, but let the draw brush section fill in the rest...
    jmp DRAW_GEM_BRUSH

  DRAW_GEM_BRICK:
    ; call write_gem_pixel(0000)
    mov dx,0x0000
    call WRITE_GEM_PIXEL

    ; call write_gem_pixel(0100)
    mov dx,0x0100
    call WRITE_GEM_PIXEL

    ; done drawing
    jmp DRAW_GEM_END

  DRAW_GEM_WALL:
    ; call write_gem_pixel(0000)
    mov dx,0x0000
    call WRITE_GEM_PIXEL

    ; call write_gem_pixel(0100)
    mov dx,0x0100
    call WRITE_GEM_PIXEL

    ; kinda silly, but let the draw forest section fill in the rest...
    jmp DRAW_GEM_FOREST

  DRAW_GEM_OTHER:
    ; call write_gem_pixel(0000)
    mov dx,0x0000
    call WRITE_GEM_PIXEL

    ; call write_gem_pixel(0001)
    mov dx,0x0001
    call WRITE_GEM_PIXEL

  DRAW_GEM_END:
    pop dx
    pop ax
    popf
    ret


; Cycle order is as follows:
;  step 0, dx=0000
;  step 1, dx=0101
;  step 2, dx=0001
;  step 3, dx=0100
;  repeat...
CYCLE_GEM_BLOCK:
    ; parameters:
    ;  al = step (0-3)
    ;  cl = map column
    ;  ch = map row

    pushf
    push ax
    push dx

    ; set color = WBBB
    mov ah,0xc0

    ; first ensure steps are constrained to values 0-3
    and al,0x03

    ; odd steps (1 and 3) set bottom row
    mov dh,al
    and dh,0x01

    ; steps 1 and 2 set right column
    shr al,1
    xor al,dh
    mov dl,al

    ; output pixel step
    call WRITE_GEM_PIXEL

    pop dx
    pop ax
    popf
    ret


; There are four pixels per tile in the gem rendition:
;   top-left, top-right, bottom-left, and bottom-right
;   Which one gets written is based on dx
WRITE_GEM_PIXEL:
    ; parameters:
    ;  ah = color to write
    ;  cl = map column
    ;  ch = map row
    ;  dl = 0 - left column, 1 - right column
    ;  dh = 0 - top row, 1 - bottom row

    ; store
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; cl *= 2, ch *= 2 (each gem object is a 2x2 block)
    shl cl,1
    shl ch,1

    ; cl += dl, ch += dh (offset to quadrant in gem object)
    add cl,dl
    add ch,dh

    ; cl += 0x20, ch += 0x20 (offset to col 20 row 20 of screen)
    add ch,0x20
    add cl,0x20

    ; set bx = column number
    xor bh,bh
    mov bl,cl

    ; set dl = row number
    mov dl,ch

    ; es:di => offset to gem block in video buffer
    ; cl = bit index in byte of pixel
    call GET_CGA_OFFSET

    ; shift ah to pixel
    shr ah,cl

    ; write byte to bx
    xor [es:di],ah

    ; flush pixel
    call FLUSH_BUFFER_PIXEL

    ; restore & return
    pop es
    pop di
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

    ; clear the last line of text from the buffer
    ;  (needed in CGA composite mode since int 10 doesn't touch the dbl-buffer)
    mov ch,0x17
    mov dh,0x17
    mov cl,0x18
    mov dl,0x27
    call CLEAR_WINDOW_SPACES

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

    ; set color = 2222 (BRBRBRBR)
    mov ax,0x2222

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

    call FLUSH_BUFFER

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

    ; set color = 2222 (BRBRBRBR)
    mov ax,0x2222

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

    call FLUSH_BUFFER

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

    ; bx => starting offset (ignore bit offset)
    push cx
    call GET_CGA_OFFSET
    mov bx,di
    pop cx

    mov dx,0x0140       ; move forward 8 rows
    call DRAW_BORDER

    pop di
    pop dx
    pop bx
    ret


DRAW_HORIZONTAL_BORDER:
    ; parameters:
    ;  ax = video data to write
    ;  bx = starting column
    ;  cx = number of rows to write
    ;  dl = starting row

    push bx
    push dx
    push di

    push cx
    call GET_CGA_OFFSET
    mov bx,di
    pop cx

    mov dx,0x0002   ; move forward 8 columns
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
    ;int 0x10
    call CLEAR_WINDOW_SPACES

    mov al,0x20
    mov cl,0x01
    mov dh,0x01

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
    ;int 0x10
    call CLEAR_WINDOW_SPACES

    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; Software simulation of int 10 fcn 06 (clear text window)
CLEAR_WINDOW_SPACES:
    ; parameters:
    ;  ch = starting row
    ;  cl = starting column
    ;  dh = ending row (inclusive)
    ;  dl = ending column (inclusive)

    pushf
    push ax
    push cx

    ; set character = space
    mov al,0x20

  CLEAR_WINDOW_SPACES_ROW_LOOP:

    push cx

  CLEAR_WINDOW_SPACES_COL_LOOP:

    call DISPLAY_CHAR

    ; advance to next column
    inc cl
    cmp cl,dl
    jna CLEAR_WINDOW_SPACES_COL_LOOP

    pop cx

    ; advance to next row
    inc ch
    cmp ch,dh
    jna CLEAR_WINDOW_SPACES_ROW_LOOP

    pop cx
    pop ax
    popf
    ret


; Displays a character in the text window
DISPLAY_CHAR:
    ; parameters:
    ;  al = ASCII character
    ;  cl = column position (in 8x8 characters)
    ;  ch = row position (in 8x8 characters)

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
    ;  cl = column position (in 8x8 characters)
    ;  ch = row position (in 8x8 characters)
    ;  dx:si => charset file

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

    ; check that charset is loaded
    and dx,dx
    jz DISPLAY_CHAR_NO_CHARSET

    ; ds:si => charset file
    mov ds,dx

    ; multiply ascii char code * 16 (16 bytes in CGA ascii char tile)
    mov ah,0x00
    shl ax,1
    shl ax,1
    shl ax,1
    shl ax,1

    ; set si = ptr to 8x8 pixel char in charset file
    add si,ax

    ; set bx = starting column (in pixels)
    mov bl,cl
    mov bh,0x00
    shl bx,1
    shl bx,1
    shl bx,1

    ; set dl = starting row (in pixels)
    mov dl,ch
    shl dl,1
    shl dl,1
    shl dl,1

    ; move 8 words (8 pixels each) at ds:si into first page of video buffer
    mov dh,0x04
  DISPLAY_CHAR_EVEN_ROWS:
    call GET_CGA_OFFSET
    movsw
    add dl,0x02
    dec dh
    jnz DISPLAY_CHAR_EVEN_ROWS

    ; move back to row 1
    sub dl,0x07

    ; move 8 words (8 pixels each) at ds:si into second page of video buffer
    mov dh,0x04
  DISPLAY_CHAR_ODD_ROWS:
    call GET_CGA_OFFSET
    movsw
    add dl,0x02
    dec dh
    jnz DISPLAY_CHAR_ODD_ROWS

    ; set row/col counters to size of char
    mov dh,0x08
    mov cx,0x0008

    ; reset dl back to row 0 of char
    sub dl,0x09

    ; output character
    call FLUSH_BUFFER_RECT

  DISPLAY_CHAR_DONE:
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

  DISPLAY_CHAR_NO_CHARSET:
    push cx

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

    pop cx
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

    push ds

    ; get video buffer
    mov ds,[VIDEO_SEGMENT]

    ; write ax to ds:(bx + offset)
    ; where offset = multiple of 0x50
    ; this writes an 8x8 block of video data
    mov [bx],ax
    mov [bx+0x0050],ax
    mov [bx+0x00a0],ax
    mov [bx+0x00f0],ax

    ; repeat for second page
    mov [bx+0x2000],ax
    mov [bx+0x2050],ax
    mov [bx+0x20a0],ax
    mov [bx+0x20f0],ax

    pop ds
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

    ; calculate offset to start of tile
    mov ax,0x0040           ; size of one CGA tile in bytes
    mul dh

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
    call GET_CGA_OFFSET

    ; make sure direction flag is clear
    cld

    ; prepare to output 8 even rows of tile
    mov cx,0x0008
  DISPLAY_TILE_EVEN_ROWS:
    ; 16 pixels = 4 bytes = 2 words
    movsw
    movsw
    add di,0x4c             ; distance to next row (0x50 - 0x04)
    loop DISPLAY_TILE_EVEN_ROWS

    ; advance to second CGA page
    add di,0x1d80           ; distance to second CGA page

    ; prepare to output 8 odd rows of tile
    mov cx,0008
  DISPLAY_TILE_ODD_ROWS:
    ; 16 pixels = 4 bytes = 2 words
    movsw
    movsw
    add di,0x4c             ; distance to next row (0x50 - 0x04)
    loop DISPLAY_TILE_ODD_ROWS

    ; flush tile in buffer
    mov cx,0x0010
    mov dh,0x10
    call FLUSH_BUFFER_RECT

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

    ; write 4000 words of 0000's to es:di
    mov cx,0x0fa0
    repz
    stosw

    ; set di = 2000 (start offset of second CGA page)
    mov di,0x2000

    ; write 4000 words of 0000's to es:di
    mov cx,0x0fa0
    repz
    stosw

    call FLUSH_BUFFER

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
    push dx
    push es

    ; es:bx => tile in shapes file
    call GET_TILE_OFFSET
    mov bx,ax

    ; set ax = 60 bytes into tile (row 15a)
    mov ax,[es:bx+0x3c]

    ; set dx = 62 bytes into tile (row 15b)
    mov dx,[es:bx+0x3e]

    ; loop 8 times (two rows at a time)
    mov cx,0x0008

  SCROLL_TILE_LOOP:
    ; swap row 15a with row 0a
    xchg ax,[es:bx]

    ; swap row 0a with row 1a
    xchg ax,[es:bx+0x20]

    ; swap row 15b with row 0b
    xchg dx,[es:bx+0x02]

    ; swap row 0b with row 1b
    xchg dx,[es:bx+0x22]

    ; move forward two rows
    add bx,0x0004
    loop SCROLL_TILE_LOOP

    pop es
    pop dx
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
    push dx
    push si
    push di
    push ds
    push es

    ; ds:ax = ds:bx => tile in shapes file
    call GET_TILE_OFFSET
    mov bx,ax

    ; save row numbers in dx
    mov dx,cx

    ; interlaced row # = (row # + (row # % 1) * 16) / 2
    ;  (i.e., if row is odd, we add 16 to row number then divide by 2;
    ;         if row is even, we just divide by 2)
    and dl,0x01             ; get bit 0 of row # (0 if even, 1 if odd)
    shl dl,1
    shl dl,1
    shl dl,1
    shl dl,1                ; dl = 0 if even, 16 if odd
    add cl,dl
    shr cl,1

    ; cl = row # * 4 bytes/row = byte offset for row
    shl cl,1
    shl cl,1

    ; set es:di => first row in shapes file
    add al,cl
    adc ah,0x00
    mov di,ax

    ; interlaced row # = (row # + (row # % 1) * 16) / 2
    ;  (i.e., if row is odd, we add 16 to row number then divide by 2;
    ;         if row is even, we just divide by 2)
    and dh,0x01             ; get bit 0 of row # (0 if even, 1 if odd)
    shl dh,1
    shl dh,1
    shl dh,1
    shl dh,1                ; dh = 0 if even, 16 if odd
    add ch,dh
    shr ch,1

    ; ch = row # * 4 bytes/row / 2 pages = byte offset for row
    shl ch,1
    shl ch,1

    ; set ds:si => second row in shapes file
    add bl,ch
    adc bh,0x00
    mov si,bx
    push es
    pop ds

    ; swap two words (8 bytes) or tile row
    mov cx,0x0002
    call REP_XCHGSW

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

    ; swap 0x20 words
    mov cx,0x0020
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
    ; parameters
    ;  bl = tile number
    ; returns:
    ;  ex:ax => tile in shapes file

    pushf
    push bx
    push dx
    push bp

    ; set ax = tile offset
    xor bh,bh
    mov ax,0x0040           ; size of CGA tile
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
    ; parameters:
    ;  al = party member number (0-3)

    pushf
    push bx
    push cx
    push dx
    push di
    push ds

    ; get video segment
    mov ds,[VIDEO_SEGMENT]

    ; pixel row = (party member number) * 32 + 8
    mov dl,al
    shl dl,1
    shl dl,1
    shl dl,1
    shl dl,1
    shl dl,1
    add dl,08

    ; pixel column = 00c0
    mov bx,0x00c0

    call GET_CGA_OFFSET

    ; loop 12 times across rows (2 rows at a time - one per page)
    mov dh,0x0c
  INVERT_PARTY_MEMBER_BOX_ROW_LOOP:

    ; loop across 15 words
    mov cx,0x000f
  INVERT_PARTY_MEMBER_BOX_COL_LOOP:

    ; invert word at next two rows
    xor word [di],0xffff
    xor word [di+0x2000],0xffff

    ; advance to next word
    inc di
    inc di
    loop INVERT_PARTY_MEMBER_BOX_COL_LOOP

    ; advance to next row
    add di,0x0032
    dec dh
    jnz INVERT_PARTY_MEMBER_BOX_ROW_LOOP

    ; flush rectangle
    mov dh,0x18
    mov cx,0x0078
    call FLUSH_BUFFER_RECT

    pop ds
    pop di
    pop dx
    pop cx
    pop bx
    popf
    ret


INVERT_GAME_SCREEN:
    push ax

    ; invert by white
    mov ax,0xffff
    call INVERT_GAME_SCREEN_WITH_MASK

    pop ax
    ret


INVERT_ENDGAME_SCREEN:
    ; parameters:
    ;  al = step number

    pushf
    push ax
    push bx

    ; step number must be 0-6
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

    ; set bx = 0x0142 (start of game map)
    mov bx,0x0142

    ; loop 0x58 times (for each row)
    mov dx,0x0058
  INVERT_GAME_SCREEN_ROW_LOOP:

    ; loop 0x16 times (for each word in a row)
    mov cx,0x0016
  INVERT_GAME_SCREEN_COL_LOOP:

    ; write an 8x2 block
    xor word [bx],ax
    xor word [bx+0x2000],ax

    ; advance to next word
    inc bx
    inc bx
    loop INVERT_GAME_SCREEN_COL_LOOP

    ; advance to next row
    add bx,0x0024
    dec dx
    jnz INVERT_GAME_SCREEN_ROW_LOOP

    ; flush changes to buffer
    mov bx,0x0008
    mov cx,0x00b0
    mov dl,0x08
    mov dh,0xb0
    call FLUSH_BUFFER_RECT

    pop ds
    pop dx
    pop cx
    pop bx
    popf
    ret


INVERT_PARTY_MEMBER_NUMBER:
    ; parameters:
    ;  al = party member number (1-4)

    pushf
    push bx
    push cx
    push dx
    push di
    push ds

    ; get video segment
    mov ds,[VIDEO_SEGMENT]

    ; dl = pixel row = (party member number - 1) * 32
    mov dl,al
    dec dl
    shl dl,1
    shl dl,1
    shl dl,1
    shl dl,1
    shl dl,1

    ; bx = pixel column
    mov bx,0x00f8

    call GET_CGA_OFFSET

    ; do inversion on first page
    xor word [di],0xffff
    xor word [di+0x0050],0xffff
    xor word [di+0x00a0],0xffff
    xor word [di+0x00f0],0xffff

    ; do inversion on second page
    xor word [di+0x2000],0xffff
    xor word [di+0x2050],0xffff
    xor word [di+0x20a0],0xffff
    xor word [di+0x20f0],0xffff

    ; flush buffer
    mov cx,0x0008
    mov dh,0x08
    call FLUSH_BUFFER_RECT

    pop ds
    pop di
    pop dx
    pop cx
    pop bx
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

    ; copy 2000 words from blank.ibm to video buffer
    mov cx,0x2000
    rep movsw

    call FLUSH_BUFFER

    pop es
    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    popf
    ret


; Copies an 8-pixel line of the EXOD.IBM file to the video buffer.  The starting
; column must begin at a byte offset (or it will be rounded down to one).
DISPLAY_EXOD_LINE:
    ; parameters:
    ;  ax = 0000 to write blanks, non-zero otherwise
    ;  bx = starting column
    ;  dl = starting row on source
    ;  dh = starting row on destination

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

    ; si = offset of pixel within EXOD.IBM
    call GET_CGA_OFFSET
    mov si,di

    ; es:di => video buffer
    xchg dl,dh
    mov es,[VIDEO_SEGMENT]
    call GET_CGA_OFFSET

    ; check if we are writing zero
    and ax,ax
    jz DISPLAY_EXOD_LINE_STORE

    ; ds:si => starting pixel in EXOD.IBM
    push bx
    lea bx,[EXOD_ADDR]
    add si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax
    pop bx

    ; move 8 pixels (2 bytes) of data
    lodsw
  DISPLAY_EXOD_LINE_STORE:
    stosw

    ; flush row (dl = row in video buffer, bx = starting column)
    mov cx,0x0008
    call FLUSH_BUFFER_LINE

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


DISPLAY_LORDBRIT_PIXEL:
    ; parameters:
    ;  cl = column number from pixel 0x14 (in pixels)
    ;  ch = row number (in pixels)

    pushf
    push ax
    push bx
    push dx

    ; set al = color to write
    mov al,0x03

    ; set dl = row number
    mov dl,ch

    ; set bx = actual column number
    mov bl,cl
    xor bh,bh
    add bx,0x0014

    ; output pixel
    call WRITE_PIXEL

    ; flush this row (dl = row number, bx = column number)
    call FLUSH_BUFFER_PIXEL

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
    push cx
    push di
    push es

    ; get video segment
    mov es,[VIDEO_SEGMENT]

    ; prepare a mask
    mov ah,0x03

    ; make sure it's a 2-bit color
    and al,ah

    ; shift pixel (& mask) to left so it's at the first pixel in byte
    mov cl,0x06
    shl al,cl
    shl ah,cl

    ; get cga offset
    call GET_CGA_OFFSET

    ; shift pixel (& mask) to appropriate bit
    shr al,cl
    shr ah,cl

    ; write mask to clear pixel
    not ah
    and [es:di],ah

    ; now write actual pixel
    or [es:di],al

    pop es
    pop di
    pop cx
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

    ; si = offset to desired sequence in ANIMATE.DAT
    mov cx,0x05c0           ; # of bytes per sequence
    mul cx
    mov si,ax

    ; determine frame 0 or 1 in sequence
    mov dx,bx
    and dx,0x0003           ; dx = 0 for frame 0, 2 for frame 1

    ; si = offset to desired frame in ANIMATE.EGA
    mov ax,0x0170           ; 1/2 size of frame (since dx is double)
    mul dx
    add si,ax

    ; ds:si => starting pixel in ANIMATE.EGA
    push bx
    lea bx,[ANIMATE_ADDR]
    add si,[bx]
    mov ax,[bx+0x02]
    mov ds,ax
    pop bx

    ; set dl = starting row number
    mov dl,0xa8

    ; row loop counter
    mov cx,0x0010
  DISPLAY_ANIMATION_FRAME_ROW_LOOP:
    push cx

    ; es:di => animation location in the video buffer
    call GET_CGA_OFFSET

    ; clear byte before frame row
    mov byte [es:di-0x01],0x00

    ; move row to video buffer
    mov cx,0x0017
    rep movsb

    ; clear byte after frame row
    mov byte [es:di],0x00

    ; flush row (dl = current row number)
    call FLUSH_BUFFER_ROW

    ; advance to next row
    pop cx
    inc dl
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
DRAW_DUNGEON_CHEST_LINE:
DRAW_VERTICAL_LINE:
    ; parameters:
    ;  ah = current "block" number (20 for doorway at 00)
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
    add dl,0x20

    ; set bx = starting column
    mov bl,cl
    mov bh,0x00

    ; es:di => location to write line
    call GET_CGA_OFFSET

    ; if ah == 20 (in doorway), handle it differently
    cmp ah,0x20
    jz DRAW_VERTICAL_LINE_DOOR

    ; set al = offset pixel by bit location w/i byte
    mov al,0xc0
    shr al,cl

  DRAW_VERTICAL_LINE_WALL_LOOP:
    ; recalc offset
    call GET_CGA_OFFSET

    ; or pixel into video buffer
    or [es:di],al

    ; flush pixel
    call FLUSH_BUFFER_PIXEL

    ; advance to next row
    inc dl
    dec dh
    jnz DRAW_VERTICAL_LINE_WALL_LOOP

    jmp DRAW_VERTICAL_LINE_DONE

  DRAW_VERTICAL_LINE_DOOR:

    ; shift al to pixel (and wrap)
    mov al,0x3f
    ror al,cl

  DRAW_VERTICAL_LINE_DOOR_LOOP:
    ; recalc offset
    call GET_CGA_OFFSET

    ; and pixel into video buffer
    and [es:di],al

    ; flush pixel
    call FLUSH_BUFFER_PIXEL

    ; advance to next row
    inc dl
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
    ; parameters:
    ;  ch = row number
    ;  cl = column number

    pushf
    push bx
    push cx
    push dx

    ; offset row/column by 20 pixels
    add ch,0x20
    add cl,0x20

    ; set bx = column
    mov bl,cl
    mov bh,0x00

    ; set dl = row
    mov dl,ch

    ; set color = white
    mov al,0x03

    call WRITE_PIXEL

    ; flush this row (dl = row number, bx = column number)
    call FLUSH_BUFFER_PIXEL

    pop dx
    pop cx
    pop bx
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
