; VIDJMP.ASM
; Author: Michael C. Maggio
;
; These are all the function jumps at the start of every video driver.
; Each jump is to be far-called by the main program.

; initializes the video mode
jmp INIT_DRIVER_FAR                 ; 0000

; frees all resources
jmp CLOSE_DRIVER_FAR                ; 0003