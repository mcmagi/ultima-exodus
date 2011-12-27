; COLOR.ASM
; Author: Michael C. Maggio
;
; A test program used to output the color palettes on the various color modes.
; (CGA, EGA, and VGA)

jmp START

; data section

CGA_VIDEO_SEGMENT       dw  0xb800
EGA_VIDEO_SEGMENT       dw  0xa000
VGA_VIDEO_SEGMENT       dw  0xa000
OLD_VIDEO_MODE          db  0x0

; code section

GET_VIDEO_MODE:
    push ax
    push bx

    mov ah,0x0f
    int 0x10

    ; save old video mode
    mov [OLD_VIDEO_MODE],al

    pop bx
    pop ax
    ret


RESET_VIDEO_MODE:
    push ax

    ; reset prior video mode
    mov ah,0x00
    mov al,[OLD_VIDEO_MODE]
    int 0x10

    pop ax
    ret


SET_CGA_VIDEO_MODE:
    push ax
    push bx

    ; set cga video mode
    mov ah,0x00
    mov al,0x04
    int 0x10

    pop bx
    pop ax
    ret


SET_CGA_PALETTE:
    ; parameter:
    ;  bl = palette number
    push ax
    push bx
    push dx

    ; check for special palette 02
    cmp bl,0x02
    jne SET_CGA_PALETTE_NORMAL

    ; this is for tweaked mode (doesn't really work)
    mov dx,0x03d8
    mov al,0x0e
    out dx,al
    jmp SET_CGA_PALETTE_DONE

  SET_CGA_PALETTE_NORMAL:
    ; set palette for normal modes 00 and 01
    mov ah,0x0b
    mov bh,0x01
    int 0x10

  SET_CGA_PALETTE_DONE:
    pop dx
    pop bx
    pop ax
    ret


SET_EGA_VIDEO_MODE:
    push ax

    ; set ega video mode
    mov ah,0x00
    mov al,0x0d
    int 0x10

    pop ax
    ret


SET_VGA_VIDEO_MODE:
    push ax

    ; set vga video mode
    mov ah,0x00
    mov al,0x13
    int 0x10

    pop ax
    ret


CGA_TEST:
    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; set es:di = b800:0000
    mov es,[CGA_VIDEO_SEGMENT]
    xor di,di

  CGA_TEST_PAGE_LOOP:
    mov bh,0x00

  CGA_TEST_ROW_COLOR_LOOP:
    ; prepare to loop for 0x32 rows/color
    mov dl,0x32

  CGA_TEST_ROW_LOOP:
    ; keep color change w/i row to two colors
    and bl,0x01

  CGA_TEST_COL_COLOR_LOOP:

    ; only first bit should change
    and bl,0x01

    ; set ah = actual color to write
    mov ah,bh
    add ah,bl

    ; repeat color into al 4 times (since 4 pixels per byte @ 2bpp)
    xor al,al
    mov dh,0x04
  CGA_TEST_BIT_LOOP:
    shl al,1
    shl al,1
    or al,ah
    dec dh
    jnz CGA_TEST_BIT_LOOP

    ; write color into a row of block
    mov cx,0x0028
    rep stosb

    ; increment to next color w/i row
    inc bl

    ; stop after two colors
    cmp bl,0x02
    jb CGA_TEST_COL_COLOR_LOOP


    ; increment to next row
    dec dl
    jnz CGA_TEST_ROW_LOOP


    ; advance to next set of row colors
    add bh,0x02

    ; stop after all four colors
    cmp bh,0x04
    jb CGA_TEST_ROW_COLOR_LOOP


    ; if we just wrote the second page, then we're done
    cmp di,0x2000
    jae CGA_TEST_DONE

    ; otherwise, advance to second page
    mov di,0x2000
    jmp CGA_TEST_PAGE_LOOP

  CGA_TEST_DONE:
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret

EGA_TEST:
    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; set es:di = a000:0000
    mov es,[EGA_VIDEO_SEGMENT]
    xor di,di

    ; 320x200:
    ;  0x0028 bytes per row (per bit plane)
    ;  0x1f40 bytes per bit plane
    ; --- I/O ports ---
    ;  0x03c4 - sequencer address regiser (02 for writing)
    ;  0x03c5 - send bit plane (bits 0-3: 0000IRGB)

    ; 8 - intensity (lower two rows: 2,3: 10,11: test row,02)
    ; 4 - red (odd rows, 1,3: 01,11: test row,01)
    ; 2 - green (right two columns: 2,3)
    ; 1 - blue (odd columns: 1,3)

    ; bit plane number
    mov bh,0x01

  EGA_PLANE_LOOP:

    ; test first bitplane (blue)
    mov dx,0x03c4
    mov al,0x02
    out dx,al
    inc dx
    mov al,bh
    out dx,al

    xor di,di       ; start at top of video buffer

    ; loop through 4 color rows
    mov dl,0x00     ; color row counter
  EGA_ROW_LOOP:

    mov bl,0x32     ; pixel row counter

    ; if (intensity (bh&0x08) && lower row (dl&02))
    test bh,0x08
    jz EGA_RED_ROW_TEST
    test dl,0x02
    jz EGA_ROW_COLOR_SKIP

  EGA_RED_ROW_TEST:
    ; if (red (bh&0x04) && odd row (dl&01))
    test bh,0x04
    jz EGA_ROW_COLOR_LOOP
    test dl,0x01
    jz EGA_ROW_COLOR_SKIP

    ; loop through 40 (bh=0x32) pixel rows per color
  EGA_ROW_COLOR_LOOP:

    mov dh,0x00     ; color col counter

    ; loop through 4 color columns
  EGA_COL_LOOP:
    ; if (green (bh&0x02) && right col (dh&02))
    test bh,0x02
    jz EGA_BLUE_COL_TEST
    test dh,0x02
    jz EGA_COL_COLOR_SKIP

  EGA_BLUE_COL_TEST:
    ; if (blue (bh&0x01) && odd col (dh&01))
    test bh,0x01
    jz EGA_COL_COLOR_WRITE
    test dh,0x01
    jz EGA_COL_COLOR_SKIP

  EGA_COL_COLOR_WRITE:
    ; write 10 bytes (5 words) to video buffer
    mov ax,0xffff
    mov cx,0x0005
    rep stosw
    jmp EGA_COL_NEXT

  EGA_COL_COLOR_SKIP:
    ; skip 10 (0x0a) bytes
    add di,0x0a

  EGA_COL_NEXT:
    ; stop after 4 cols
    inc dh
    cmp dh,0x04
    jnz EGA_COL_LOOP

    dec bl
    jnz EGA_ROW_COLOR_LOOP
    jmp EGA_ROW_NEXT

  EGA_ROW_COLOR_SKIP:
    ; skip 40 bytes/row * 50 rows = 2000 (0x07d0) bytes
    add di,0x07d0

  EGA_ROW_NEXT:
    ; stop after 4 rows
    inc dl
    cmp dl,0x04
    jnz EGA_ROW_LOOP

    ; shift to next bit plane
    shl bh,1

    ; stop after all 4 bitplanes
    cmp bh,0x10
    jne EGA_PLANE_LOOP

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


VGA_TEST:
    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; set es:di = a000:0000
    mov es,[VGA_VIDEO_SEGMENT]
    xor di,di

    mov bl,0x00
    mov bh,0x00

  VGA_TEST_ROW_COLOR_LOOP:
    ; prepare to loop for 0x0c rows/color
    mov dl,0x0c

  VGA_TEST_ROW_LOOP:
    ; keep color change w/i row to 16 colors
    and bl,0x0f

  VGA_TEST_COL_COLOR_LOOP:
    ; only first nybble should change
    and bl,0x0f

    ; set al = actual color to write
    mov al,bh
    add al,bl

    ; write color into a row of block
    mov cx,0x0014
    rep stosb

    ; increment to next color w/i row
    inc bl

    ; stop after 16 colors
    cmp bl,0x10
    jb VGA_TEST_COL_COLOR_LOOP


    ; increment to next row
    dec dl
    jnz VGA_TEST_ROW_LOOP


    ; advance to next set of row colors
    add bh,0x10

    ; stop after all 256 colors (bh overflows)
    jnc VGA_TEST_ROW_COLOR_LOOP

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


WAIT_FOR_KEYPRESS:
    ; returns:
    ;  ax = pressed key

    pushf

    ; wait until a key is pressed
  WAIT_FOR_KEY_LOOP:
    mov ah,0x01
    int 0x16
    jnz WAIT_FOR_KEY_LOOP

    ; get actual key
    mov ah,0x00
    int 0x16
    
    popf
    ret


START:
    ; ds starts 100 bytes after cs in .COM files
    mov ax,cs
    add ax,0x0010
    mov ds,ax

    call GET_VIDEO_MODE

    ; set video mode and palette 0
    call SET_CGA_VIDEO_MODE
    mov bl,0x00
    call SET_CGA_PALETTE

    ; do cga test
    call CGA_TEST
    call WAIT_FOR_KEYPRESS

    ; show cga colors with palette 1
    mov bl,0x01
    call SET_CGA_PALETTE
    call WAIT_FOR_KEYPRESS

    ; show ega colors
    call SET_EGA_VIDEO_MODE
    call EGA_TEST
    call WAIT_FOR_KEYPRESS

    ; show vga colors
    call SET_VGA_VIDEO_MODE
    call VGA_TEST
    call WAIT_FOR_KEYPRESS

    call RESET_VIDEO_MODE

    ; exit to DOS
    mov ah,0x4c
    mov al,0x00
    int 0x21
