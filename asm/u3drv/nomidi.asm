; ===== start jumps into code here =====
; These are all the jumps at the start of the driver.
; Each jump is to be far-called by the main program.

jmp INIT_DRIVER_FAR                 ; 0000
jmp CLOSE_DRIVER_FAR                ; 0003
jmp PLAY_MAP_MUSIC_FAR              ; 0006
jmp PLAY_MUSIC_FAR                  ; 0009
jmp STOP_MUSIC_FAR                  ; 000c
jmp PLAY_MUSIC_ONCE_FAR             ; 000f


; ===== far functions here (jumped to from above) =====

INIT_DRIVER_FAR:
    xor ax,ax
    retf

CLOSE_DRIVER_FAR:
    retf

PLAY_MAP_MUSIC_FAR:
    retf

PLAY_MUSIC_FAR:
    retf

STOP_MUSIC_FAR:
    retf

PLAY_MUSIC_ONCE_FAR:
    retf

