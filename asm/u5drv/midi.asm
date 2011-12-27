; MIDI.ASM
; Author: Michael C. Maggio
;
; Ultima 5 Upgrade MIDI driver.

; ===== start jumps into code here =====
jmp PLAY_BY_MAP		    ; 0000
jmp STOP_MUSIC			; 0003
jmp PLAY_BY_STORY		; 0006
jmp PLAY_INTRO			; 0009
jmp PLAY_CHARACTER		; 000c
jmp START_MAP_DETECT	; 000f
jmp FORCE_STONES		; 0012
jmp FORCE_RULEBRIT		; 0015
jmp PLAY_BY_ENDGAME		; 0018
jmp PLAY_RULEBRIT		; 001b


; ===== data here =====

SONGNUM		    db	0
MAPDETECT		db	0
MIDI_TBL		dw	U5THEME, BRITLAND, HORNPIPE, ENGGMNT, STONES, GREYSON, FANFARE, MONARCH, TRNTLLA, HALLS, WRLDBLW, BLCKTHRN, LADYNAN, REUNION, RULEBRIT, AMIGA
U5THEME		    db	"U5THEME.XMI",0
BRITLAND		db	"BRITLAND.XMI",0
HORNPIPE		db	"HORNPIPE.XMI",0
ENGGMNT		    db	"ENGGMNT.XMI",0
STONES		    db	"STONES.XMI",0
GREYSON		    db	"GREYSON.XMI",0
FANFARE		    db	"FANFARE.XMI",0
MONARCH		    db	"MONARCH.XMI",0
TRNTLLA		    db	"TRNTLLA.XMI",0
HALLS		    db	"HALLS.XMI",0
WRLDBLW		    db	"WRLDBLW.XMI",0
BLCKTHRN		db	"BLCKTHRN.XMI",0
LADYNAN		    db	"LADYNAN.XMI",0
REUNION		    db	"REUNION.XMI",0
RULEBRIT		db	"RULEBRIT.XMI",0
AMIGA		    db	"AMIGA.XMI",0


; ===== midi driver functions here =====

; This function plays a MID song with the song number passed in AL
; The song number is used as an index into the MIDI_TBL array
PLAY_MIDI:
	; passed: al = song number

	pushf
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es

	cmp al,0xff
	jz END_PLAY

	; store song number
	mov [SONGNUM],al

	; set bx = address to midi file
	mov bl,al
	xor bh,bh
	shl bx,1
	mov bx,[bx+MIDI_TBL]

	; register midi file
	mov ax,0x070d
	mov cx,ds
	int 0x66

	; play midi file
	mov ax,0x0702
	mov bx,0x0000
	int 0x66

  END_PLAY:
	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret

; This function stops any MIDI music that may be playing
STOP_MIDI:
	pushf
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es

	mov ax,0x0705
	int 0x66

	mov [SONGNUM],0xff

	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	ret


; returns whether or not MIDI music is currently playing
MIDI_STATUS:
	; returns bx = midi status
	pushf
	push ax
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es

	mov ax,0x070c
	int 0x66

	mov bx,ax

	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop ax
	popf
	ret


; returns the song index that should be playing given the map number
; (if map detect is off, returns current song number)
DETECT_SONG_FROM_MAP:
	; passed: bx = data segment
	; returns: al = detected song
	pushf
	push bx
	push ds

	; if mapdetect != 0, begin detection by checking combat
	cmp [MAPDETECT],0x00
	jnz CHECK_COMBAT

	; otherwise, just select current song
	mov al,[SONGNUM]

	; return
	jmp RETURN_DETECT
	

  CHECK_COMBAT:
	; set ds = data segment w/ map data
	mov ds,bx

	; clear ah
	xor ah,ah

	; get map #
	mov bl,[0x5893]

	; if map != combat, check overworld
	cmp bl,0xff
	jnz CHECK_FRIGATE

	; set bh = battle successful flag
	mov bh,[0x58a3]

	; set song = Engagement and Melee
	mov al,0x03

	; if battle is not successful, then return
	cmp bh,0x00
	jnz MONSTERS_DEFEATED
	jmp RETURN_DETECT

  MONSTERS_DEFEATED:
	; set song = Ultima Theme
	mov al,0x00
	jmp RETURN_DETECT

  CHECK_FRIGATE:
	; get player icon (removing bits 0-1)
  	mov bh,[0x587c]
	and bh,0xf8
	
	; if icon != frigate, check combat
	cmp bh,0x20
	jnz CHECK_OVERWORLD

	; set song = Cap'n Jhone's Hornpipe
	mov al,0x02
	jmp RETURN_DETECT

  CHECK_OVERWORLD:
	; if map != overworld, jump to next
	cmp bl,0x00
	jnz CHECK_CITY

	; set song = Britannic Lands
	mov al,0x01

	; if level == britannia, return
	mov bh,[0x5895]
	cmp bh,0x00
	jz RETURN_DETECT

	; otherwise, set song = Worlds Below
	mov al,0x0a
	jmp RETURN_DETECT

  CHECK_CITY:
	; if map > new magincia, check lighthouse
	cmp bl,0x08
	ja CHECK_LIGHTHOUSE

	; set song = Villager Tarantella
	mov al,0x08
	jmp RETURN_DETECT

  CHECK_LIGHTHOUSE:
  	; if map > waveguide, check huts
	cmp bl,0x0c
	ja CHECK_HUTS

	; set song = Dream of Lady Nan
	mov al,0x0c
	jmp RETURN_DETECT

  CHECK_HUTS:
  	; if map > Grendel's hut, check LB's Castle
	cmp bl,0x10
	ja CHECK_LBCASTLE

	; set song = Greyson's Tale
	mov al,0x05
	jmp RETURN_DETECT

  CHECK_LBCASTLE:
  	; if map > LB's Castle, check Blackthorn's Palace
	cmp bl,0x11
	ja CHECK_BLACKTHORN

	; set song = The Missing Monarch
	mov al,0x07
	jmp RETURN_DETECT

  CHECK_BLACKTHORN:
  	; if map > Blackthorn's Palace, check towns
	cmp bl,0x12
	ja CHECK_TOWNS

	; set song = Lord Blackthorn
	mov al,0x0b
	jmp RETURN_DETECT

  CHECK_TOWNS:
  	; if map > Buccaneer's Den, check keeps
	cmp bl,0x18
	ja CHECK_KEEPS

	; set song = Greyson's Tale
	mov al,0x05
	jmp RETURN_DETECT

  CHECK_KEEPS:
  	; if map > Stonegate, check castles
	cmp bl,0x1d
	ja CHECK_CASTLES

	; set song = Dream of Lady Nan
	mov al,0x0c
	jmp RETURN_DETECT

  CHECK_CASTLES:
  	; if map > Serpent's Hold, check dungeons
	cmp bl,0x20
	ja CHECK_DUNGEONS

	; set song = Fanfare for the Virtuous
	mov al,0x06
	jmp RETURN_DETECT

  CHECK_DUNGEONS:
	; if map > Doom, no detect
  	cmp bl,0x28
	ja RETURN_DETECT

	; set song = Halls of Doom
	mov al,0x09
	jmp RETURN_DETECT

  NO_DETECT:
	; set song = none
    mov al,0xff

  RETURN_DETECT:
	pop ds
	pop bx
	popf
	ret


; returns the song index that should be playing given a story id (intro)
DETECT_SONG_FOR_STORY:
	; passed: bx = story id

	pushf
	push bx

  	; clear ah
	xor ah,ah

  CHECK_SUMMONING:
	; if id > 7, check arrival
	cmp bl,0x07
	ja CHECK_ARRIVAL

	; set song = Stones
	mov al,0x04
	jmp RETURN_STORY

  CHECK_ARRIVAL:
	; if id > e, check tale
	cmp bl,0x0e
	ja CHECK_TALE

	; set song = Halls of Doom
	mov al,0x09
	jmp RETURN_STORY

  CHECK_TALE:
	; if id > 15, no story
	cmp bl,0x15
	ja NO_STORY

	; set song = Greyson's Tale
	mov al,0x05
	jmp RETURN_STORY

  NO_STORY:
	; set song = none
  	mov al,0xff

  RETURN_STORY:
	; restore & return
  	pop bx
	popf
	ret


; returns the song index that should be playing given a endgame id (endgame)
DETECT_SONG_FOR_ENDGAME:
	; passed: bx = endgame id

	pushf
	push bx

  	; clear ah
	xor ah,ah

  CHECK_HOMECOMING:
	; if id > 3, check dream
	cmp bl,0x03
	ja CHECK_DREAM

	; set song = Stones
	mov al,0x04
	jmp RETURN_ENDGAME

  CHECK_DREAM:
	; if id > 7, no endgame
	cmp bl,0x07
	ja NO_ENDGAME

	; set song = Dream of Lady Nan
	mov al,0x0c
	jmp RETURN_ENDGAME

  NO_ENDGAME:
	; set song = none
  	mov al,0xff

  RETURN_ENDGAME:
	; restore & return
  	pop bx
	popf
	ret


; plays the new midi song passed in AL.  if it is already the current song,
; it checks that it is still playing, restarting if necessary
PLAY_NEW_MIDI:
	; passed: al = new midi
	pushf

	; if new midi != current midi, jump to new midi
	cmp al,[SONGNUM]
	jnz NEW_MIDI

	; otherwise, check that the old midi is still playing
	call CHECK_MIDI
	jmp RETURN_PLAY

  NEW_MIDI:
	; stop old midi & start new
  	call STOP_MIDI
	call PLAY_MIDI

  RETURN_PLAY:
	popf
	ret


; restarts current MIDI song if it has ended, otherwise does nothing
CHECK_MIDI:
	pushf
	push ax
	push bx

	; get midi status
	call MIDI_STATUS

	; if midi status == playing, return
	cmp bl,0x01
	jz RETURN_CHECK

	; otherwise, restart same song
	xor ah,ah
	mov al,[SONGNUM]
	call PLAY_MIDI

  RETURN_CHECK:
	pop bx
	pop ax
  	popf
	ret


; enable detection by mapid
START_DETECT:
	mov [MAPDETECT],0x01
	ret


; disable detection by mapid, forces current song to play continously
STOP_DETECT:
	mov [MAPDETECT],0x00
	ret


; set data segment
SET_SEGMENT:
	; set ds = cs (local data segment)
    push cs
    pop ds
	ret


; ===== far functions here (jumped to from above) =====

; play music normally (maps, etc)
PLAY_BY_MAP:
	; passed: bx = data segment with map data
	push ax
	push ds

	call SET_SEGMENT

	; detect midi & play it
	call DETECT_SONG_FROM_MAP
	call PLAY_NEW_MIDI

	; restore & return
	pop ds
	pop ax
	retf


; begin playing music for intro story sequence
PLAY_BY_STORY:
	; passed: bx = story id
	push ax
	push ds

	call SET_SEGMENT

	; detect midi & play it
	call DETECT_SONG_FOR_STORY
	call PLAY_NEW_MIDI

	; return
	pop ds
	pop ax
	retf


; begin playing music for main menu
PLAY_INTRO:
	; store
	push ax
	push ds

	call SET_SEGMENT

	call STOP_DETECT

	; set song = Ultima Theme
	mov al,0x00
	call PLAY_NEW_MIDI

	; restore & return
	pop ds
	pop ax
	retf


; plays character creation theme
PLAY_CHARACTER:
	; store
	push ax
	push ds
	
	call SET_SEGMENT

	; set song = Amiga Theme
	mov al,0x0f
	call PLAY_NEW_MIDI

	; restore & return
	pop ds
	pop ax
	retf


; forces full stop of all music
STOP_MUSIC:
	; store
	push ds

	call SET_SEGMENT

	; stop song
	call STOP_MIDI

	; stop detection by map id
	call STOP_DETECT

	; restore & return
	pop ds
	retf


; segment wrapper for START_DETECT
START_MAP_DETECT:
	; store
	push ds

	call SET_SEGMENT

	; start detection by map id
	call START_DETECT

	; restore & return
	pop ds
	retf


; forces stones to play (continuous)
FORCE_STONES:
	; store
	push ax
	push ds

	call SET_SEGMENT

	; stop detection by map id for stones
	call STOP_DETECT

	; set song = stones
	mov al,0x04
	call PLAY_NEW_MIDI

	; restore & return
	pop ds
	pop ax
	retf


; forces one joyous runion, then rule britannia (continous) to play
FORCE_RULEBRIT:
	; store
	push ax
	push ds

	call SET_SEGMENT

	; stop detection by map id for endgame
	call STOP_DETECT

	; set song = Joyous Reunion (plays once)
	mov al,0x0d
	call PLAY_NEW_MIDI

	; set future songs = Rule Britannia
	mov [SONGNUM],0x0e

	; restore & return
	pop ds
	pop ax
	retf


; wrapper for endgame music
PLAY_BY_ENDGAME:
	; passed: bx = endgame id
	push ax
	push ds

	call SET_SEGMENT

	; detect midi & play it
	call DETECT_SONG_FOR_ENDGAME
	call PLAY_NEW_MIDI

	; return
	pop ds
	pop ax
	retf


; forces rule britannia to play (once)
PLAY_RULEBRIT:
	push ax
	push ds

	call SET_SEGMENT

	; set song = Rule Britannia
	mov al,0x0e
	call PLAY_NEW_MIDI

	pop ds
	pop ax
	retf
