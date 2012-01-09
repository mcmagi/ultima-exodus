; CGA.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade CGA driver.  The functions in the included cgacore.asm output
; directly to the CGA video buffer at segment address B800.  Since data is
; written directly to the video buffer, the FLUSH_* functions have no
; implementation.

; ===== start jumps into code here =====
include 'vidjmp.asm'


; ===== data here =====

CHARSET_FILE    db      "CHARSET.ULT",0
SHAPES_FILE     db      "SHAPES.ULT",0
MOONS_FILE      db      "MOONS.ULT",0
BLANK_FILE      db      "BLANK.IBM",0
EXOD_FILE       db      "EXOD.IBM",0
ANIMATE_FILE    db      "ANIMATE.DAT",0
ENDGAME_MASK    dw      0xffff,0x3333,0xcccc,0xffff,0x3333,0xffff,0xcccc
VIDEO_SEGMENT   dw      0xb800
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
    push bx

    ; don't reinitialze driver
    cmp [DRIVER_INIT],0x01
    jz INIT_DRIVER_DONE

    ; set cga video mode
    mov ah,0x00
    mov al,0x04
    int 0x10

    ; set palette cyan-magenta-white
    mov ah,0x0b
    mov bh,0x01
    mov bl,0x01
    int 0x10

    ; initialization of cursor is in game code

    mov [DRIVER_INIT],0x01

  INIT_DRIVER_DONE:
    pop bx
    pop ax
    popf
    ret


; frees any resources in use by the driver
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


; These have no implementation in the CGA (4-color) driver
FLUSH_BUFFER:
FLUSH_BUFFER_ROW:
FLUSH_BUFFER_RECT:
FLUSH_BUFFER_LINE:
FLUSH_BUFFER_PIXEL:
    ret


; include the core CGA driver functions
include 'cgacore.asm'


; Returns the byte offset (and bit offset within the byte) into the CGA video
; buffer for a requested pixel.
GET_CGA_OFFSET:
    ; parameters:
    ;  bx = pixel column
    ;  dl = pixel row
    ; returns:
    ;  di = video offset
    ;  cl = bit offset

    pushf
    push ax
    push bx
    push dx

    ; set di = offset of first page
    xor di,di

    ; determine which CGA page to write to
    shr dl,1                ; right-shift by 1 to get row # in page

    ; if carry was not set, it's the first page
    jnc GET_VIDEO_OFFSET_FIRST_PAGE

    ; set di = offset of second page
    mov di,0x2000

  GET_VIDEO_OFFSET_FIRST_PAGE:
    ; calculate offset to row
    mov al,0x50             ; size of CGA row = 0x50
    mul dl                  ; get row offset w/i page
    add di,ax               ; di => row offset within video buffer

    ; get cl = number of bits into byte
    mov cl,bl
    and cl,0x03             ; last two bits are pixel index w/i byte
    shl cl,1                ; two bits per pixel

    ; calculate column offset (there are 4 pixels per byte)
    shr bx,1
    shr bx,1

    ; di = offset to pixel in video buffer
    add di,bx

    pop dx
    pop bx
    pop ax
    popf
    ret


; ===== supporting libraries =====

include 'vidfile.asm'

include '../common/xchgs.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'