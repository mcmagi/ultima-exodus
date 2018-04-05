; CGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade CGA driver.  The functions in the included cgacore.asm output
; directly to the CGA video buffer at segment address B800.  Since data is
; written directly to the video buffer, the FLUSH_* functions have no
; implementation.

INTRO_FILE      db      "PICDRA",0
DEMO1_FILE      db      "PICOUT",0
DEMO2_FILE      db      "PICTWN",0
DEMO3_FILE      db      "PICCAS",0
DEMO4_FILE      db      "PICDNG",0
DEMO5_FILE      db      "PICSPA",0
DEMO6_FILE      db      "PICMIN",0
TILESET         db      "CGATILES",0        ; TODO: they are actually in game code
VIDEO_SEGMENT   dw      0xb800

; TODO:
; intro/demo files are loaded directly to video buffer in game code
