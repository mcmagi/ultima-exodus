; CGA.ASM
; Author: Michael C. Maggio
;
; Common utility functions for CGA video.

; Calculates the byte offset (and bit offset within the byte) into the CGA video
; buffer for a set of pixel coordinates.
GET_CGA_OFFSET:
	; parameters:
	;  bx = pixel x coordinate
	;  dl = pixel y coordinate
	; returns:
	;  di = video offset
	;  cl = bit offset

    pushf
    push ax
	push bx
	push dx

    ; get cl = number of bits into byte
    mov cl,bl
    and cl,0x03             ; last two bits are pixel index w/i byte
	xor cl,0x03				; and invert
    shl cl,1                ; two bits per pixel

    ; set di = 0000 = offset of first page
    xor di,di

    ; determine which CGA page to write to
    shr dl,1                ; right-shift by 1 to get row # in page

    ; if carry was not set, it's the first page
    jnc GET_CGA_OFFSET_FIRST_PAGE

    ; set di = 2000 = offset of second page
    mov di,0x2000

  GET_CGA_OFFSET_FIRST_PAGE:
    ; calculate offset to row
    mov al,0x50             ; size of CGA row = 80 bytes
    mul dl                  ; get row offset w/i page (appears to destroy dx!)
    add di,ax               ; di => row offset within video buffer

    ; calculate column offset (there are 4 pixels per byte)
    shr bx,2

    ; di = offset to pixel in video buffer
    add di,bx

	pop dx
	pop bx
    pop ax
    popf
    ret
