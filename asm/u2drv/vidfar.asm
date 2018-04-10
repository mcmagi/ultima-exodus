; VIDFAR.ASM
; Author: Michael C. Maggio
;
; Video driver wrapper functions that manage receipt of the far call from the
; main program.  Sets the data segment (ds) register before calling the actual
; driver implementation, then does a far-return (retf).

; Sets ds to the local data segment
SET_SEGMENT:
	; set es = original data segment of calling program
	;  This allows manipulation of calling program's data.
	push ds
	pop es

    ; set ds = local data segment (cs - 0x10 paragraphs)
    ;  (Previously, when I was using a86, all data addresses were +0x100 bytes
    ;   greater than the code segment, so we needed to adjust ds. This is no
    ;   longer necessary with fasm. Now the two segment registers can be equal.)
    push cs
    pop ds
    ret


INIT_DRIVER_FAR:
	push ds
	push es
	call SET_SEGMENT
	call INIT_DRIVER
	pop es
	pop ds
	retf

CLOSE_DRIVER_FAR:
	push ds
	push es
	call SET_SEGMENT
	call CLOSE_DRIVER
	pop es
	pop ds
	retf
