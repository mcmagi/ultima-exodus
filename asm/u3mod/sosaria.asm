; SOSARIA.ASM
; Author: Michael C. Maggio
;
; A data 'module' that describes the map files, save files, and locations of
; points of interest in the original game.  Mod authors may use this as a
; template to create new mods.

; jump locations
include 'modjmp.asm'

;
; === MOD DATA ===
;

; save files
SAVE_PARTY              db  "PARTY.ULT",0
SAVE_ROSTER             db  "ROSTER.ULT",0

; world map
MAP_WORLD               db  "SOSARIA.ULT",0
MAP_WORLD_BAK           db  "SOSARIA.RST",0
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
                        dw  MAP_TOWN_BRITAIN,MAP_TOWN_MOON,MAP_TOWN_YEW,MAP_TOWN_MONTOR_EAST
                        dw  MAP_TOWN_MONTOR_WEST,MAP_TOWN_GREY,MAP_TOWN_DAWN
                        dw  MAP_TOWN_DEVIL_GUARD,MAP_TOWN_FAWN,MAP_TOWN_DEATH_GULCH
                        dw  MAP_DUNG_DOOM,MAP_DUNG_FIRE,MAP_DUNG_TIME,MAP_DUNG_SNAKE
                        dw  MAP_DUNG_PERINIAN,MAP_DUNG_MINES,MAP_DUNG_DARDINS

; number of enter-able points of interest on world map
NUM_POI                 dw  0x0013

; poi x/y coordinate table
XY_POI_TABLE            db  0x2d,0x12   ; Castle of Lord British
                        db  0x0a,0x35   ; Castle of Death
                        db  0x2e,0x13   ; Britain
                        db  0x06,0x0d   ; Moon
                        db  0x22,0x10   ; Yew
                        db  0x31,0x3a   ; Montor East
                        db  0x2f,0x3a   ; Montor West
                        db  0x07,0x2c   ; Grey
                        db  0x25,0x35   ; Dawn
                        db  0x12,0x1f   ; Devil Guard
                        db  0x1e,0x02   ; Fawn
                        db  0x38,0x1f   ; Death Gulch
                        db  0x13,0x39   ; Dungeon of Doom
                        db  0x31,0x22   ; Dungeon of Fire
                        db  0x3a,0x1e   ; Dungeon of Time
                        db  0x3a,0x2c   ; Dungeon of the Snake
                        db  0x38,0x06   ; Perinian Depths
                        db  0x09,0x1c   ; Mines of Morinia
                        db  0x2e,0x07   ; Dardin's Pit

; moongate x/y coordinate table
XY_MOONGATE_TABLE       db  0x08,0x08
                        db  0x39,0x2e
                        db  0x0f,0x1b
                        db  0x24,0x3a
                        db  0x0f,0x1d
                        db  0x0c,0x37
                        db  0x1f,0x1f
                        db  0x3a,0x1f

; index into table of town appearing on twin new moons
IDX_NEW_MOONS_TOWN      db  0x08

; index into table of Castle Death (plays Exodus music)
IDX_CASTLE_DEATH        db  0x01

; index into table of Town where <Pray> is to be used (Circle of Light)
IDX_TOWN_PRAY           db  0x04

; x/y coordinates of location to <Pray> within said town
XY_PRAY                 db  0x30,0x30

; x/y coordinates of starting position
XY_START                db  0x2c,0x14

; x/y coordinates for evocare teleport
XY_TELEPORT             db  0x0a,0x38
                        db  0x0a,0x3b

; x/y coordinates for exotics
XY_EXOTIC_WEAPON        db  0x21,0x03
XY_EXOTIC_ARMOR         db  0x13,0x2c


; core functions
include 'modcore.asm'
; far calls
include 'modfar.asm'
