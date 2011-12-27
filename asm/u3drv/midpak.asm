; ===== start jumps into code here =====
; These are all the jumps at the start of the driver.
; Each jump is to be far-called by the main program.

; initializes the music driver
jmp INIT_DRIVER_FAR                 ; 0000

; frees all resources
jmp CLOSE_DRIVER_FAR                ; 0003

; music control functions
jmp PLAY_MAP_MUSIC_FAR              ; 0006
jmp PLAY_MUSIC_FAR                  ; 0009
jmp STOP_MUSIC_FAR                  ; 000c
jmp PLAY_MUSIC_ONCE_FAR             ; 000f


; ===== data here =====

DRIVER_INIT     db  0
MIDPAK          db  "MIDPAK.COM",0  ; midpak driver
MIDPAK_START    db  02," 8",0x0d,0  ; midpak startup command-line options
MIDPAK_STOP     db  02," u",0x0d,0  ; midpak shutdown command-line options
PRM_BLOCK       db  0x16 dup 0      ; parameter black
FCB             db  0x20 dup 0      ; file control block
SONGNUM         db  0               ; current song number playing
ONCE_FLAG       db  0               ; set if current song is playing once
MIDI_TBL        dw  WANDER, CASTLES, RULEBRIT, TOWNS, SHOPPING, COMBAT, DUNGEON, ALIVE, FANFARE, EXODUS
WANDER          db  "WANDER.XMI",0
CASTLES         db  "CASTLES.XMI",0
RULEBRIT        db  "RULEBRIT.XMI",0
TOWNS           db  "TOWNS.XMI",0
SHOPPING        db  "SHOPPING.XMI",0
COMBAT          db  "COMBAT.XMI",0
DUNGEON         db  "DUNGEON.XMI",0
ALIVE           db  "ALIVE.XMI",0
FANFARE         db  "FANFARE.XMI",0
EXODUS          db  "EXODUS.XMI",0


; ===== initialization/cleanup functions here =====

INIT_DRIVER:
    ; returns:
    ;  ax = 01 on error, 00 on success
    pushf
    push bx
    push cx
    push dx
    push es

    ; don't reinitialze driver
    cmp [DRIVER_INIT],0x01
    jz INIT_DRIVER_DONE

    ; set es = ds
    push ds
    pop es

    ; fill parameter block
    lea bx,[PRM_BLOCK]
    mov word [bx],0x0000
    mov word [bx+0x02],MIDPAK_START
    mov [bx+0x04],ds
    mov word [bx+0x06],FCB
    mov [bx+0x08],ds
    mov word [bx+0x0a],FCB
    mov [bx+0x0c],ds

    ; run midpak program
    mov ax,0x4b00
    xor cx,cx               ; clear cx
    lea dx,[MIDPAK]
    int 0x21                ; execute

    ; check for error
    jnc INIT_DRIVER_GOOD

    ; set on error
    mov ax,0x0001
    jmp INIT_DRIVER_DONE

  INIT_DRIVER_GOOD:
    ; no errors
    xor ax,ax
    mov [DRIVER_INIT],0x01

  INIT_DRIVER_DONE:
    pop es
    pop dx
    pop cx
    pop bx
    popf
    ret


CLOSE_DRIVER:
    pushf
    push ax
    push bx
    push cx
    push dx
    push es

    ; don't uninitialze an uninitialized driver
    cmp [DRIVER_INIT],0x01
    jnz CLOSE_DRIVER_DONE

    ; set es = ds
    push ds
    pop es

    ; fill parameter block
    lea bx,[PRM_BLOCK]
    mov word [bx],0x0000
    mov word [bx+0x02],MIDPAK_STOP
    mov [bx+0x04],ds
    mov word [bx+0x06],FCB
    mov [bx+0x08],ds
    mov word [bx+0x0a],FCB
    mov [bx+0x0c],ds

    ; run midpak program
    mov ax,0x4b00
    xor cx,cx               ; clear cx
    lea dx,[MIDPAK]
    int 0x21                ; execute

  CLOSE_DRIVER_DONE:
    pop es
    pop dx
    pop cx
    pop bx
    pop ax
    popf
    ret


; ===== midi driver functions here =====

; This function plays a MID song with the song number passed in AL
; The song number is used as an index into the MIDI_TBL array
PLAY_MIDI:
    ; parameters:
    ;  al = song number (0-9)

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

    ; clear "once" flag
    mov byte [ONCE_FLAG],0x00

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


; Returns whether or not MIDI music is currently playing
MIDI_STATUS:
    ; returns:
    ;  bx = midi status (01 if playing, 0 if not playing)

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


; Returns the song index that should be playing given the map number
; (if map detect is off, returns current song number)
DETECT_SONG_FROM_MAP:
    ; parameters:
    ;  bl = current map id (0x14bc in exodus.bin)
    ;  dx = sosaria map position (0x14c2 in exodus.bin)
    ; returns:
    ;  al = detected song

    pushf

  DETECT_SONG_CHECK_SOSARIA:
    ; check for sosaria
    cmp bl,0x00
    jnz DETECT_SONG_CHECK_COMBAT

    ; set song = Wander
    mov al,0x00
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_COMBAT:
    ; check for combat
    cmp bl,0x80
    jnz DETECT_SONG_CHECK_TOWN

    ; set song = Combat
    mov al,0x05
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_TOWN:
    ; check for town
    cmp bl,0x02
    jnz DETECT_SONG_CHECK_CASTLE

    ; set song = Town
    mov al,0x03
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_CASTLE:
    ; check for castle
    cmp bl,0x03
    jnz DETECT_SONG_CHECK_VISION

    ; there are two castles:

  DETECT_SONG_CHECK_CASTLE_DEATH:
    ; if row/col != 35,0a (Castle of Death), assume Castle of LB
    cmp dx,0x350a
    jnz DETECT_SONG_CHECK_CASTLE_LB

    ; set song = Exodus
    mov al,0x09
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_CASTLE_LB:
    ; it wasn't Castle of Death, so it must be Castle of LB

    ; set song = Castle
    mov al,0x01
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_VISION:
    ; check for shrine/fountain/mark/timelord
    cmp bl,0x04
    jnz DETECT_SONG_CHECK_GEMS

    ; set song = Alive
    mov al,0x07
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_GEMS:
    ; check for gem
    cmp bl,0x11
    jnz DETECT_SONG_CHECK_AMBROSIA

    ; set song = Alive
    mov al,0x07
    jmp DETECT_SONG_RETURN

  DETECT_SONG_CHECK_AMBROSIA:
    ; check for ambrosia
    cmp bl,0xff
    jnz DETECT_DEFAULT

    ; set song = Fanfare
    mov al,0x08
    jmp DETECT_SONG_RETURN

    ; otherwise, use what's playing now
  DETECT_DEFAULT:
    mov al,[SONGNUM]

  DETECT_SONG_RETURN:
    popf
    ret


; Restarts current MIDI song if it has ended, otherwise does nothing
CHECK_MIDI:
    pushf
    push ax
    push bx

    ; get midi status
    call MIDI_STATUS

    ; if midi status == playing, return
    cmp bl,0x01
    jz CHECK_MIDI_DONE

    ; otherwise, restart same song
    xor ah,ah
    mov al,[SONGNUM]
    call PLAY_MIDI

  CHECK_MIDI_DONE:
    pop bx
    pop ax
    popf
    ret


; Plays the appropriate theme for an overworld map.
PLAY_MAP_MUSIC:
    ; parameters:
    ;  bl = current map id (0x14bc in exodus.bin)
    ;  dx = sosaria map position (0x14c2 in exodus.bin)

    push ax

    ; detect song from map and play it
    call DETECT_SONG_FROM_MAP
    call PLAY_MUSIC

    pop ax
    ret


; Plays the new midi song passed in AL.  if it is already the current song,
; it checks that it is still playing, restarting if necessary
PLAY_MUSIC:
    ; parameters:
    ;  al = song number
    pushf
    push ax

    ; if song num midi == 0xff, use current song num
    cmp al,0xff
    jnz PLAY_MUSIC_CHANGED_CHECK
    mov al,[SONGNUM]

  PLAY_MUSIC_CHANGED_CHECK:
    ; if song num != current midi, jump to new midi
    cmp al,[SONGNUM]
    jnz PLAY_MUSIC_ONCE_CHECK

    ; otherwise, check that the old midi is still playing
    call CHECK_MIDI
    jmp PLAY_MUSIC_DONE

  PLAY_MUSIC_ONCE_CHECK:
    ; if "once" flag is clear, restart the song
    cmp byte [ONCE_FLAG],0x00
    jz PLAY_MUSIC_RESTART

    ; or if song is done playing, restart the song
    call MIDI_STATUS
    cmp bx,0x00
    jz PLAY_MUSIC_RESTART

    ; otherwise (song not done and "once" flag set), just update the song number and return
    mov [SONGNUM],al
    jmp PLAY_MUSIC_DONE

  PLAY_MUSIC_RESTART:
    ; stop old midi & start new
    call STOP_MIDI
    call PLAY_MIDI

  PLAY_MUSIC_DONE:
    pop ax
    popf
    ret


; Plays a new song, but preserves the SONGNUM variable with its original value.
; Once the specified song has ended, the original song will restart.
PLAY_MUSIC_ONCE:
    ; parameters:
    ;  al = song to play

    push bx

    ; get current songnum
    mov bl,[SONGNUM]

    ; stop the current song and play the new song
    call STOP_MIDI
    call PLAY_MIDI

    ; save original song
    mov [SONGNUM],bl

    ; set "once" flag
    mov byte [ONCE_FLAG],0x01

    pop bx
    ret


; Stops the currently playing MIDI
STOP_MUSIC:
    call STOP_MIDI
    ret


; ===== far functions here (jumped to from above) =====

; Sets es to the local data segment
SET_SEGMENT:
    ; set ds = cs (local data segment)
    push cs
    pop ds
    ret

; initializes the music driver
INIT_DRIVER_FAR:
    push ds
    call SET_SEGMENT
    call INIT_DRIVER
    pop ds
    retf

; cleans up after the music driver
CLOSE_DRIVER_FAR:
    push ds
    call SET_SEGMENT
    call CLOSE_DRIVER
    pop ds
    retf

; play music normally (maps, etc)
PLAY_MAP_MUSIC_FAR:
    push ds
    call SET_SEGMENT
    call PLAY_MAP_MUSIC
    pop ds
    retf

; plays a song or ensures the music is running; restarts the music if it ends
PLAY_MUSIC_FAR:
    ; parameters:
    ;  al = song number
    push ds
    call SET_SEGMENT
    call PLAY_MUSIC
    pop ds
    retf

; forces full stop of all music
STOP_MUSIC_FAR:
    push ds
    call SET_SEGMENT
    call STOP_MUSIC
    pop ds
    retf

; plays a song once then continues with the previously played song
PLAY_MUSIC_ONCE_FAR:
    ; parameters:
    ;  al = song number
    push ds
    call SET_SEGMENT
    call PLAY_MUSIC_ONCE
    pop ds
    retf
