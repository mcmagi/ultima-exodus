; SOSARIA.ASM
; Author: Michael C. Maggio
;
; A data 'module' that describes the map files, save files, and locations of
; points of interest in Lands of Lord British mod.

; jump locations
include 'modjmp.asm'

;
; === MOD DATA ===
;

; save files
SAVE_PARTY              db  "PARTY.ULT",0
SAVE_ROSTER             db  "ROSTER.ULT",0

; world map
MAP_WORLD               db  "LOLB.ULT",0
MAP_WHIRLPOOL           db  "AMBROSIA.ULT",0

; poi files
MAP_CASTLE_BRITISH      db  "BRITISH.ULT",0
MAP_CASTLE_DEATH        db  "EXODUS.ULT",0
MAP_TOWN_BRITAIN        db  "LCB.ULT",0
MAP_TOWN_MOON           db  "MOON.ULT",0
MAP_TOWN_YEW            db  "YEW.ULT",0
MAP_TOWN_MONTOR_EAST    db  "MONTOR_E.ULT",0
MAP_TOWN_MONTOR_WEST    db  "MONTOR_W.ULT",0
MAP_TOWN_GREY           db  "GREY.ULT",0
MAP_TOWN_DAWN           db  "DAWN.ULT",0
MAP_TOWN_DEVIL_GUARD    db  "DEVIL.ULT",0
MAP_TOWN_FAWN           db  "FAWN.ULT",0
MAP_TOWN_DEATH_GULCH    db  "DEATH.ULT",0
MAP_DUNG_DOOM           db  "M.ULT",0
MAP_DUNG_FIRE           db  "FIRE.ULT",0
MAP_DUNG_TIME           db  "TIME.ULT",0
MAP_DUNG_SNAKE          db  "P.ULT",0
MAP_DUNG_PERINIAN       db  "PERINIAN.ULT",0
MAP_DUNG_MINES          db  "MINE.ULT",0
MAP_DUNG_DARDINS        db  "DARDIN.ULT",0

; poi filename table
MAP_POI_TABLE           dw  MAP_CASTLE_BRITISH,MAP_CASTLE_DEATH
                        dw  MAP_TOWN_BRITAIN,MAP_TOWN_MOON,MAP_TOWN_YEW
                        dw  MAP_TOWN_MONTOR_EAST,MAP_TOWN_MONTOR_WEST,MAP_TOWN_GREY
                        dw  MAP_TOWN_DEVIL_GUARD,MAP_TOWN_FAWN,MAP_TOWN_DEATH_GULCH
                        dw  MAP_DUNG_DOOM,MAP_DUNG_FIRE,MAP_DUNG_TIME,MAP_DUNG_SNAKE
                        dw  MAP_DUNG_PERINIAN,MAP_DUNG_MINES,MAP_DUNG_DARDINS

; number of enter-able points of interest on world map
NUM_POI                 dw  0x0013

; poi x/y coordinate table
XY_POI_TABLE            db  0x1e,0x1f   ; Castle of Lord British
                        db  0x18,0x38   ; Castle of Death
                        db  0x1d,0x20   ; Britain
                        db  0x37,0x22   ; Moon
                        db  0x07,0x17   ; Yew
                        db  0x2f,0x3b   ; Montor East
                        db  0x2d,0x3b   ; Montor West
                        db  0x35,0x0f   ; Grey
                        db  0x0a,0x26   ; Dawn
                        db  0x16,0x14   ; Devil Guard
                        db  0x0e,0x34   ; Fawn
                        db  0x30,0x16   ; Death Gulch
                        db  0x1e,0x33   ; Dungeon of Doom
                        db  0x32,0x2c   ; Dungeon of Fire
                        db  0x13,0x1e   ; Dungeon of Time
                        db  0x3b,0x05   ; Dungeon of the Snake
                        db  0x08,0x03   ; Perinian Depths
                        db  0x05,0x26   ; Mines of Morinia
                        db  0x2d,0x07   ; Dardin's Pit

; moongate x/y coordinate table
XY_MOONGATE_TABLE       db  0x3b,0x2b
                        db  0x3a,0x08
                        db  0x22,0x3b
                        db  0x13,0x16
                        db  0x30,0x0a
                        db  0x1a,0x3a
                        db  0x07,0x35
                        db  0x13,0x1f

; x/y coordinates of town appearing on twin new moons
XY_NEW_MOONS_TOWN       db  0x0a,0x26

; x/y coordinates of starting position
XY_START                db  0x1f,0x1c

; x/y coordinates for evocare teleport
XY_TELEPORT             db  0x18,0x3b
                        db  0x18,0x3e

; x/y coordinates for exotics
XY_EXOTIC_WEAPON        db  0x21,0x03
XY_EXOTIC_ARMOR         db  0x13,0x2c


; core functions
include 'modcore.asm'
; far calls
include 'modfar.asm'