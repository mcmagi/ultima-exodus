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
FLUSH_GAME_MAP:
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
GET_VIDEO_OFFSET:
	; parameters:
	;  bx = pixel x coordinate
	;  dl = pixel y coordinate
	; returns:
	;  di = video offset
	;  cl = bit offset
	
	call GET_CGA_OFFSET
	ret


; ===== supporting libraries =====

include '../common/video/cga.asm'
include '../common/vidfile.asm'
include '../common/xchgs.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'