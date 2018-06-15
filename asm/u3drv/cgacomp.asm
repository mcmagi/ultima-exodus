; CGACOMP.ASM
; Author: Michael C. Maggio
;
; Ultima 3 Upgrade Composite CGA driver.  Employes a dual-buffer strategy to
; translate CGA data to CGA composite output.  The functions in the included
; cgacore.asm output to a pre-allocated buffer at some segment address.  The
; FLUSH_* functions then map the CGA data to the VGA video buffer at segment
; address A000.  Uses VGA video mode 0x13.  Loads CGACOMP.PAL to configure the
; VGA palette with CGA composite colors.

; ===== start jumps into code here =====
include 'vidjmp.asm'


; ===== data here =====

CHARSET_FILE            db      "CHARSET.ULT",0
SHAPES_FILE             db      "SHAPES.ULT",0
MOONS_FILE              db      "MOONS.ULT",0
BLANK_FILE              db      "BLANK.IBM",0
EXOD_FILE               db      "EXOD.IBM",0
ANIMATE_FILE            db      "ANIMATE.DAT",0
PALETTE_FILE            db      "CGACOMP.PAL",0
ENDGAME_MASK            dw      0xffff,0x3333,0xcccc,0xffff,0x3333,0xffff,0xcccc
DRIVER_INIT             db      0
CHARSET_ADDR            dd      0
SHAPES_ADDR             dd      0
MOONS_ADDR              dd      0
BLANK_ADDR              dd      0
EXOD_ADDR               dd      0
ANIMATE_ADDR            dd      0



; ===== Video driver initialization functions =====

INIT_DRIVER:
    pushf
    push ax
    push dx

    ; don't reinitialize driver
    cmp [DRIVER_INIT],0x01
    jz INIT_DRIVER_DONE

    ; set vga video mode
    mov ah,0x00
    mov al,0x13
    int 0x10

    ; initialization of cursor is in game code

    ; load composite cga palette from file
    lea dx,[PALETTE_FILE]
    call LOAD_VGA_PALETTE

	; allocate cga video buffer
    call SETUP_CGA_BUFFER

    ; build row lookup tables
    call BUILD_CGA_ROW_LOOKUP_TABLE
    call BUILD_VGA_ROW_LOOKUP_TABLE

    ; build composite color lookup table
    call BUILD_COMPOSITE_LOOKUP_TABLE

    mov [DRIVER_INIT],0x01

  INIT_DRIVER_DONE:
    pop dx
    pop ax
    popf
    ret


; frees any resources in use by the driver
CLOSE_DRIVER:
    pushf
    push ax
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

    ; free cga video buffer
	call FREE_CGA_BUFFER

  CLOSE_DRIVER_DONE:
    pop bx
    pop ax
    popf
    ret


; ===== Buffer functions =====

FLUSH_GAME_MAP:
    ; parameters:
    ;  ah = height in tiles
    ;  al = width in tiles
    ;  bx = starting pixel column of game map
    ;  dl = starting pixel row of game map

    pushf
    push cx
    push dx

    ; save cl=width, dh=height (in tiles)
    mov cl,al
    mov dh,ah

    ; set cx = width in pixels
    mov ax,0x0010
    mul cl
    mov cx,ax

    ; set dh = height in pixels
    mov ax,0x0010
    mul dh
    mov dh,al

    call FLUSH_BUFFER_RECT

    pop dx
    pop cx 
    popf
    ret


; ===== CGA core =====

; include the core CGA driver functions
include 'cgacore.asm'


; ===== CGA/VGA offset functions =====

; Returns the byte offset (and bit offset within the byte) into the CGA video
; buffer for a requested pixel.
GET_VIDEO_OFFSET:
	; parameters:
	;  bx = pixel x coordinate
	;  dl = pixel y coordinate
	; returns:
	;  di = video offset
	;  cl = bit offset
	
	call LOOKUP_CGA_OFFSET
	ret


; ===== supporting libraries =====

include '../common/video/cgacomp.asm'
include '../common/video/palette.asm'
include '../common/vidfile.asm'
include '../common/xchgs.asm'


; ===== far functions here (jumped to from above) =====
include 'vidfar.asm'
