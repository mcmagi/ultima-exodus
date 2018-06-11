; CGA.ASM
; Author: Michael C. Maggio
;
; Common utility functions for CGA Composite emulated video. Employes a
; dual-buffer strategy to translate CGA data to CGA composite output. These
; functions output to a pre-allocated buffer at some segment address. The
; FLUSH_BUFFER* functions then map the CGA data to the VGA video buffer at
; segment address A000. Expects to operate in VGA video mode 0x13.

; ===== data here =====

VIDEO_SEGMENT           dw      0xb800
VGA_VIDEO_SEGMENT       dw      0xa000
COMPOSITE_LOOKUP        dw      0x100 dup 0
CGA_ROW_OFFSET_LOOKUP   dw      0xc8 dup 0
VGA_ROW_OFFSET_LOOKUP   dw      0xc8 dup 0


; ===== initialization & close funtions here ====

SETUP_CGA_BUFFER:
    push ax

    mov ax,0x4000
    call ALLOCATE_MEMORY
    mov [VIDEO_SEGMENT],ax

    pop ax
    ret


FREE_CGA_BUFFER:
	pushf
	push ax

    ; free our video buffer
    mov ax,[VIDEO_SEGMENT]
    and ax,ax
    jz FREE_CGA_BUFFER_DONE
    call FREE_MEMORY

  FREE_CGA_BUFFER_DONE:
	pop ax
	popf
	ret


; ===== buffer functions =====

; Copies data from the buffered video area to the real video segment
FLUSH_BUFFER:
    pushf
    push dx

    ; start at row 0
    xor dl,dl

  FLUSH_BUFFER_ROW_LOOP:
    ; flush row
    call FLUSH_BUFFER_ROW

    ; advance to next row
    inc dl
    cmp dl,0xc8
    jnz FLUSH_BUFFER_ROW_LOOP

    pop dx
    popf
    ret


; Copies a row from the buffered video area to the real video segment
FLUSH_BUFFER_ROW:
    ; parameters:
    ;  dl = row number

    push bx
    push cx

    ; set column number = 0
    mov bx,0x0000

    ; set # of columns = 0x0140
    mov cx,0x0140

    call FLUSH_BUFFER_LINE

    pop cx
    pop bx
    ret


; Copies a rectangle from the buffered video area to the real video segment
FLUSH_BUFFER_RECT:
    ; parameters:
    ;  bx = starting column
    ;  cx = # of columns
    ;  dl = starting row
    ;  dh = # of rows

    pushf
    push dx

    ; flush each line of rectangle
  FLUSH_BUFFER_RECT_LOOP:
    call FLUSH_BUFFER_LINE
    inc dl
    dec dh
    jnz FLUSH_BUFFER_RECT_LOOP

    pop dx
    popf
    ret


; Copies a line (row segment) from the buffered video area to the real video segment
FLUSH_BUFFER_LINE:
    ; parameters:
    ;  bx = starting column
    ;  cx = # of columns
    ;  dl = row

    pushf
    pusha ; woot! my first 80286 instruction, yay!
    push ds
    push es

    cld

    ; handle pixel immediately after
    inc cx

    ; handle pixel immediately before (if not at beginning)
    and bx,bx
    jz FLUSH_BUFFER_LINE_CHECK_END
    dec bx
    inc cx

  FLUSH_BUFFER_LINE_CHECK_PAIR:
    test bx,0x0001
    jz FLUSH_BUFFER_LINE_CHECK_END

    ; if we start in the middle of a pixel pair, move to the beginning of the pair
    dec bx
    inc cx

  FLUSH_BUFFER_LINE_CHECK_END:
    ; make sure we don't loop past end of row
    mov ax,bx
    add ax,cx
    cmp ax,0x0140
    jbe FLUSH_BUFFER_LINE_GET_OFFSETS

    ; constrain by 0x140 (320) columns
    mov cx,0x0140
    sub cx,bx

  FLUSH_BUFFER_LINE_GET_OFFSETS:
    ; cx gets destroyed by LOOKUP_CGA_OFFSET
    push cx

    ; ds:si => input row; ah = bit offset
    mov ds,[cs:VIDEO_SEGMENT]
    call LOOKUP_CGA_OFFSET
    mov si,di
    mov ah,cl   ; bit offset

    ; es:di => output row
    mov es,[cs:VGA_VIDEO_SEGMENT]
    call LOOKUP_VGA_OFFSET

    ; restore cx
    pop cx

    ; A CGA byte consists of four two-bit pixels (p0,p1,p2,p3 in the register).
    ; The loop which follows processes both pixel "pairs" in the byte (first
    ; p0,p1 then p2,p3).  However the key to the Composite Lookup Table consists
    ; of the pixels immediately before and after those pairs.  Thus, we need
    ; p(-1),p0,p1,p2 for the first pixel and p1,p2,p3,p4 for the second.  This
    ; requires reading the previous byte in advance to obtain p(-1) and the next
    ; byte to obtain p4.

    ; read first pixel
    lodsb               ; al = p0,p1,p2,p3
    mov dh,al           ; save for next pixel pair

    ; two initial possibilities based on bit offset in ah:
    ;  ah=4,6; ds:si => p0,p1,p2,p3           - shift right and read p(-1) from previous byte
    ;  ah=0,2; ds:si => p(-2),p(-1),p0,p1     - shift left and read p2 from next byte
    ; note that we ignore the least-significant bit b/c we will always process pixels in pairs
    test ah,0x04
    jz FLUSH_BUFFER_LINE_PREP

    xor dl,dl           ; dl = 00 (previous pixel init)

    ; if we are at start of line, don't read the previous pixel (just use dl=00)
    and bx,bx
    jz FLUSH_BUFFER_LINE_PREP

    ; read previous pixel
    ;  (note: previous call to lodsb had advanced si, so need to do si-2)
    mov dl,[si-0x02]    ; dl = p(-4),p(-3),p(-2),p(-1)
    and dl,0x03         ; dl = 00,00,00,p(-1)

  FLUSH_BUFFER_LINE_PREP:
    mov bx,cx           ; use bx as the counter (since we need cl for shl/shr)

    ; jump to 2nd pair if necessary
    test ah,0x04
    jz FLUSH_BUFFER_LINE_LOOP_PAIR2

  FLUSH_BUFFER_LINE_LOOP:
    ; on loop pair1 start:
    ;  al = current byte
    ;  dh = current byte (for saving)
    ;  dl = previous byte

    shl dl,6            ; dl = p(-1),00,00,00
    shr al,2            ; al = 00,p0,p1,p2
    or al,dl            ; al = p(-1),p0,p1,p2

    ; set bp = lookup address (al*2)
    mov bp,ax
    and bp,0xff
    shl bp,1

    ; lookup value in lookup table
    mov ax,[cs:COMPOSITE_LOOKUP+bp]
    stosw

    ; update counters & check if we're done looping
    sub bx,0x0002
    jz FLUSH_BUFFER_LINE_DONE
    js FLUSH_BUFFER_LINE_DONE

  FLUSH_BUFFER_LINE_LOOP_PAIR2:
    ; read next byte
    lodsb               ; al = p4,p5,p6,p7
    mov dl,al           ; save for next pixel pair

    ; on loop pair2 start:
    ;  al = next byte
    ;  dh = current byte
    ;  dl = next byte (for saving)

    shl dh,2            ; dh = p1,p2,p3,00
    shr al,6            ; al = 00,00,00,p4
    or al,dh            ; al = p1,p2,p3,p4

    ; set bp = lookup address (al*2)
    mov bp,ax
    and bp,0xff
    shl bp,1

    ; lookup value in lookup table
    mov ax,[cs:COMPOSITE_LOOKUP+bp]
    stosw

    ; adjust registers for next iteration
    xchg dh,dl          ; dl = p1,p2,p3,00; dh = p4,p5,p6,p7 (for saving)
    shr dl,2            ; dl = 00,p1,p2,p3 (we can forget p0; we really only need p3)
    mov al,dh           ; al = p4,p5,p6,p7 (next p0,p1,p2,p3)

    ; update counters & check if we're done looping
    sub bx,0x0002
    jnz FLUSH_BUFFER_LINE_LOOP
    jns FLUSH_BUFFER_LINE_LOOP

  FLUSH_BUFFER_LINE_DONE:
    pop es
    pop ds
    popa
    popf
    ret


FLUSH_BUFFER_PIXEL:
    ; parameters:
    ;  bx = column
    ;  dl = row

    push cx

    ; flush a 1-pixel long "line"
    mov cx,0x0001
    call FLUSH_BUFFER_LINE

    pop cx
    ret


; Returns the byte offset (and bit offset within the byte) into the CGA video
; buffer for a requested pixel.  Uses the lookup table.
LOOKUP_CGA_OFFSET:
    ; parameters:
    ;  bx = pixel column
    ;  dl = pixel row
    ; returns:
    ;  di = video offset
    ;  cl = bit offset

    pushf
    push bx
    push dx
    push bp

    ; set di = row offset
    xor dh,dh
    mov bp,dx
    shl bp,1
    mov di,[cs:CGA_ROW_OFFSET_LOOKUP+bp]

    ; get cl = number of bits into byte
    mov cl,bl
    and cl,0x03             ; last two bits are pixel index w/i byte
	xor cl,0x03				; and invert
    shl cl,1                ; two bits per pixel

    ; calculate column offset (there are 4 pixels per byte)
    shr bx,2

    ; di = offset to pixel in video buffer
    add di,bx

    pop bp
    pop dx
    pop bx
    popf
    ret


LOOKUP_VGA_OFFSET:
    ; parameters:
    ;  bx = pixel column
    ;  dl = pixel row
    ; returns:
    ;  di = video offset

    pushf
    push bx
    push dx
    push bp

    ; set di = row offset
    xor dh,dh
    mov bp,dx
    shl bp,1
    mov di,[cs:VGA_ROW_OFFSET_LOOKUP+bp]

    ; di = offset to pixel in video buffer
    add di,bx

    pop bp
    pop dx
    pop bx
    popf
    ret


BUILD_CGA_ROW_LOOKUP_TABLE:
    pushf
    push bx
    push cx
    push dx
    push bp

    ; start at row 0, column 0
    xor bx,bx
    xor dx,dx

  BUILD_CGA_ROW_LOOKUP_TABLE_LOOP:
    ; get row offset
    call GET_CGA_OFFSET

    ; save offset to table
    mov bp,dx
    shl bp,1
    mov [cs:CGA_ROW_OFFSET_LOOKUP+bp],di

    ; advance to next row
    inc dl
    cmp dl,0xc8
    jnz BUILD_CGA_ROW_LOOKUP_TABLE_LOOP

    pop bp
    pop dx
    pop cx
    pop bx
    popf
    ret


BUILD_VGA_ROW_LOOKUP_TABLE:
    pushf
    push bx
    push cx
    push dx
    push bp

    ; start at row 0, column 0
    xor bx,bx
    xor dx,dx

  BUILD_VGA_ROW_LOOKUP_TABLE_LOOP:
    ; get row offset
    call GET_VGA_OFFSET

    ; save offset to table
    mov bp,dx
    shl bp,1
    mov [cs:VGA_ROW_OFFSET_LOOKUP+bp],di

    ; advance to next row
    inc dl
    cmp dl,0xc8
    jnz BUILD_VGA_ROW_LOOKUP_TABLE_LOOP

    pop bp
    pop dx
    pop cx
    pop bx
    popf
    ret


; Constructs a lookup table of composite indexes (p(-1),p0,p1,p2) to composite
; colors for pixels p0 and p1.  This is done primarily for performance, so the 
; colors need not be calculated when the pixel is being written.
BUILD_COMPOSITE_LOOKUP_TABLE:
    pushf
    push ax
    push bx
    push cx
    push dx
    push di
    push es

    cld

    ; set es:di => composite lookup table
    push ds
    pop es
    lea di,[COMPOSITE_LOOKUP]

    ; bl = current pixel pair + pre/post pixels (p(-1),p0,p1,p2)
    xor bl,bl

  BUILD_COMPOSITE_LOOKUP_TABLE_LOOP:

    ; derive dh = p2
    mov dh,bl
    and dh,0x03     ; dh = 00,00,00,p2
    ; derive dl = p1
    mov dl,bl
    and dl,0x0c     ; dl = 00,00,p1,00
    shr dl,2        ; dl = 00,00,00,p1
    ; derive ch = p0
    mov ch,bl
    and ch,0x30     ; ch = 00,p0,00,00
    shr ch,4        ; ch = 00,00,00,p0
    ; derive cl = p(-1)
    mov cl,bl
    and cl,0xc0     ; cl = p(-1),00,00,00
    shr cl,6        ; cl = 00,00,00,p(-1)

    ; derive bh = composite color index (p0,p1)
    mov bh,bl       ; bh = p(-1),p0,p1,p2
    shr bh,2        ; bh = 00,p(-1),p0,p1
    and bh,0x0f     ; bh = 00,00,p0,p1

    ; now we derive the color for each pixel in the p0,p1 pair

    ; set al = left pixel (p0) color
    mov al,bh       ; default to composite color

    ; if p0 == p(-1) || p0 == p1, use solid color instead
    cmp ch,cl
    je BUILD_COMPOSITE_LOOKUP_TABLE_LEFT_SOLID
    cmp ch,dl
    je BUILD_COMPOSITE_LOOKUP_TABLE_LEFT_SOLID
    jmp BUILD_COMPOSITE_LOOKUP_TABLE_RIGHT_PIXEL

  BUILD_COMPOSITE_LOOKUP_TABLE_LEFT_SOLID:
    ; set al = left pixel (p0) color = solid color
    mov al,ch       ; al = 00,00,00,p0
    shl al,2        ; al = 00,00,p0,00
    or al,ch        ; al = 00,00,p0,p0

  BUILD_COMPOSITE_LOOKUP_TABLE_RIGHT_PIXEL:
    ; set ah = right pixel (p1) color
    mov ah,bh       ; default to composite color

    ; if p1 == p2 || p1 == p0, use solid color instead
    cmp dh,dl
    je BUILD_COMPOSITE_LOOKUP_TABLE_RIGHT_SOLID
    cmp ch,dl
    je BUILD_COMPOSITE_LOOKUP_TABLE_RIGHT_SOLID
    jmp BUILD_COMPOSITE_LOOKUP_TABLE_STORE_PIXEL

  BUILD_COMPOSITE_LOOKUP_TABLE_RIGHT_SOLID:
    ; set ah = right pixel (p1) color = solid color
    mov ah,dl       ; ah = 00,00,00,p1
    shl ah,2        ; ah = 00,00,p1,00
    or ah,dl        ; ah = 00,00,p1,p1

  BUILD_COMPOSITE_LOOKUP_TABLE_STORE_PIXEL:
    ; save ax (p1,p0) to lookup table
    stosw

    inc bl
    jnz BUILD_COMPOSITE_LOOKUP_TABLE_LOOP

    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


include 'cga.asm'
include 'vga.asm'