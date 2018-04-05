; EGA.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade EGA driver.  Despite the name, it does not use any EGA video
; modes instead uses VGA video mode 0x13.  Emulates EGA by limiting video output
; to 16 colors.  EGA data is packed with two pixels per byte and therefore must
; be unpacked to one pixel per byte before outputting to the video buffer at 
; segment address A000.


INTRO_FILE      db      "PICDRA-E",0
DEMO1_FILE      db      "PICOUT-E",0
DEMO2_FILE      db      "PICTWN-E",0
DEMO3_FILE      db      "PICCAS-E",0
DEMO4_FILE      db      "PICDNG-E",0
DEMO5_FILE      db      "PICSPA-E",0
DEMO6_FILE      db      "PICMIN-E",0
TILESET         db      "EGATILES",0
VIDEO_SEGMENT   dw      0xa000

; TODO:
; intro/demo files are loaded directly to video buffer in game code
