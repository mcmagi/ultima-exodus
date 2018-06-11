; VGA.ASM
; Author: Michael C. Maggio
;
; Common utility functions for VGA video.

; Calculates the offset to pixel coordinates in a VGA video segment.
GET_VGA_OFFSET:
	; parameters:
	;  bx = pixel x coordinate
	;  dl = pixel y coordinate
	; returns:
	;  di = video offset

	pushf
	push ax
	push dx

	; dx = y
	mov dh,0x00

	; di = y * 320 + x
	mov di,bx
	mov ax,0x0140
	mul dx
	add di,ax
	
	pop dx
	pop ax
	popf
	ret


; EGA video data is 4bpp, thus 2 pixels/byte
; the current video mode (13h) is 8bpp, thus 1 pixel/byte
; we must move the upper nybble to the high-order byte
UNPACK_EGA_VIDEO_DATA:
    ; parameters:
    ;  al = packed (ega) video data
    ; returns:
	;  ax = unpacked (vga) video data

    mov ah,al       ; get copy of data
    and ah,0x0f     ; clear upper nybble of ah

    ; right-shift 4 times (also clears lower nybble of al)
    shr al,4

    ret
