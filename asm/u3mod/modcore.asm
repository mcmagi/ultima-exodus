; MODCORE.ASM
; Author: Michael C. Maggio
;
; Common mod plugin functions that manage behavior and return data from the mod
; to the main program.  This includes functions to manage the following:
;  * world map
;    * load on startup (modify EXODUS.BIN:main - 0x2513)
;    * save on: Q&S, auto-save (modify EXODUS.BIN:save_sosaria_file - 0x207d)
;  * towns/castles/dungeons:
;    * enter
;  * ambrosia
;    * provide map name (modify EXODUS.BIN:enter_whirlpool - 0x2168)
;  * dawn
;    * appearance location (hard coded as 0x0e65 in display_moon_phases())
;  * starting location
;  * moongates:
;    * appearance
;    * entry to source & relocation to destination
;  * save file names (party/roster)
;  * yell: "evocare" locations
;  * search: exotics locations

INIT_MOD:
    ; returns:
    ;  signed flag = set if error, unset if successful
    push ax
    push bx
    push dx

    lea dx,[MAP_WORLD]
    call TEST_FILE_EXISTS
    js INIT_MOD_DONE        ; return on error

    ; if file exists, proceed to party
    jnc INIT_MOD_PARTY

    ; otherwise, create the world map
    call RESET_WORLD_MAP

  INIT_MOD_PARTY:
    lea dx,[SAVE_PARTY]
    call TEST_FILE_EXISTS
    js INIT_MOD_DONE        ; return on error

    ; if file exists, proceed to roster
    jnc INIT_MOD_ROSTER

    ; otherwise, create the world map
    call RESET_PARTY

  INIT_MOD_ROSTER:
    lea dx,[SAVE_ROSTER]
    call TEST_FILE_EXISTS
    js INIT_MOD_DONE        ; return on error

    ; if file exists, proceed to done
    jnc INIT_MOD_DONE

    ; otherwise, create the world map
    call RESET_ROSTER

  INIT_MOD_DONE:
    pop dx
    pop bx
    pop ax
    ret


TEST_FILE_EXISTS:
    ; param:
    ;  ds:dx -> filename
    ; returns:
    ;  carry = set if file does not exist, clear if exists

    push ax
    push bx

    ; try to open map file
    mov al,0x00     ; read
    mov ah,0x3d     ; fcn 0x3d = open file
    int 0x21

    ; if cannot open file, confirm why
    jc TEST_FILE_EXISTS_CHECK_CODE

    ; file exists, now close it and resume
    mov bx,ax
    mov ah,0x3e     ; fcn 0x3e = close file
    int 0x21
    jmp TEST_FILE_EXISTS_DONE

    ; set return flags
    test al,0x00    ; sf = false (success)
    clc             ; cf = false (exists)
    jmp TEST_FILE_EXISTS_DONE

  TEST_FILE_EXISTS_CHECK_CODE:
    ; if cannot open file
    cmp ax,0x0002   ; error code = file not found
    jnz TEST_FILE_EXISTS_ERROR

    ; set return flags
    test al,0x00    ; sf = false (success)
    stc             ; cf = true (does not exist)

  TEST_FILE_EXISTS_DONE:
    pop bx
    pop ax
    ret

  TEST_FILE_EXISTS_ERROR:
    or al,0xff      ; sf = true (error)
    jmp TEST_FILE_EXISTS_DONE



CLOSE_MOD:
    ret


GET_POI_INDEX:
    ; parameters:
    ;  al,ah = x,y coordinates
    ; returns:
    ;  bx = poi index
    pushf
    push cx
    push di
    push es

    push ds
    pop es

    ; scan coordinate table until we find a match
    cld
    mov cx,[NUM_POI]
    mov bx,cx
    lea di,[XY_POI_TABLE]
    repnz
    scasw

    jnz GET_POI_INDEX_ERROR

    ; set bx = poi index
    sub bx,cx
    dec bx

  GET_POI_INDEX_RETURN:
    pop es
    pop di
    pop cx
    popf
    ret

  GET_POI_INDEX_ERROR:
    ; set bx = -1 if not found
    mov bx,0xffff
    jmp GET_POI_INDEX_RETURN


GET_POI_STR:
    ; parameters:
    ;  bx = poi index
    ;  es:dx = destination addr of poi map filename
    ; returns:
    ;  es:dx -> poi map filename
    pushf
    push bx
    push si
    push di

    ; set ds:si -> poi map filname (w/i mod)
    shl bx,1
    mov si,[bx+MAP_POI_TABLE]
    ; set es:di = destination addr of poi map filename
    mov di,dx

    ; copy string from ds:si -> es:di
    call STRCPY

    pop di
    pop si
    pop bx
    popf
    ret


GET_WORLD_STR:
    ; parameters:
    ;  es:dx = destination addr of world map filename
    ; returns:
    ;  es:dx -> world map filename
    push si
    push di

    ; set ds:si -> world map filname (w/i mod)
    lea si,[MAP_WORLD]
    ; set es:di = destination addr of world map filename
    mov di,dx

    ; copy string from ds:si -> es:di
    call STRCPY

    pop di
    pop si
    ret


GET_WHIRLPOOL_STR:
    ; parameters:
    ;  es:dx = destination addr of whirlpool map filename
    ; returns:
    ;  es:dx -> whirlpool map filename
    push si
    push di

    ; set ds:si -> whirlpool map filname (w/i mod)
    lea si,[MAP_WHIRLPOOL]
    ; set es:di = destination addr of whirlpool map filename
    mov di,dx

    ; copy string from ds:si -> es:di
    call STRCPY

    pop di
    pop si
    ret


GET_PARTY_STR:
    ; parameters:
    ;  es:dx = destination addr of party filename
    ; returns:
    ;  es:dx -> party filename
    push si
    push di

    ; set ds:si -> party filname (w/i mod)
    lea si,[SAVE_PARTY]
    ; set es:di = destination addr of party filename
    mov di,dx

    ; copy string from ds:si -> es:di
    call STRCPY

    pop di
    pop si
    ret


GET_ROSTER_STR:
    ; parameters:
    ;  es:dx = destination addr of roster filename
    ; returns:
    ;  es:dx -> roster filename
    push si
    push di

    ; set ds:si -> roster filname (w/i mod)
    lea si,[SAVE_ROSTER]
    ; set es:di = destination addr of roster filename
    mov di,dx

    ; copy string from ds:si -> es:di
    call STRCPY

    pop di
    pop si
    ret


GET_MOONGATE_COORDS:
    ; parameters:
    ;  es:dx = destination addr of moongate coords
    ; returns:
    ;  es:dx -> moongate coords
    pushf
    push cx
    push si
    push di

    ; set ds:si -> first moongate x coords (w/i mod)
    lea si,[XY_MOONGATE_TABLE]
    ; set es:di = destination addr of moongate coords
    mov di,dx

    ; copy x values from ds:si -> es:di
    cld
    mov cx,0x0008
  GET_MOONGATE_COORDS_X:
    movsb
    inc si ; skip y coord
    loop GET_MOONGATE_COORDS_X

    ; set ds:si -> first moongate y coord (w/i mod)
    lea si,[XY_MOONGATE_TABLE+0x01]

    ; copy y values from ds:si -> es:di
    mov cx,0x0008
  GET_MOONGATE_COORDS_Y:
    movsb
    inc si ; skip x coord
    loop GET_MOONGATE_COORDS_Y

    pop di
    pop si
    pop cx
    popf
    ret


GET_START:
    ; returns:
    ;  al = x coordinate, ah = y coordinate
    mov al,[XY_START+0x00]
    mov ah,[XY_START+0x01]
    ret


GET_NEW_MOON_TOWN_OFFSET:
    ; returns:
    ;  bx = offset to town that appears during new moons

    pushf
    push ax
    push cx

    ; set bl = index of new moons town
    mov bl,[IDX_NEW_MOONS_TOWN]
    call GET_POI_BY_OFFSET

    ; set bx = x coordinate
    mov bh,0x00
    mov bl,al

    ; set al = y coordinate
    mov al,ah

    ; set ax = offset to row
    mov cl,0x40
    mul cl

    ; set bx = offset to town
    add bx,ax

    pop cx
    pop ax
    popf
    ret


GET_POI_BY_OFFSET:
    ; parameters:
    ;  bl = poi number
    ; returns:
    ;  al = poi x coordinate, ah = poi y coordinate

    pushf
    push bx

    ; bx = offset into poi table
    mov bh,00
    shl bx,1

    ; set ax = x/y coordinates
    mov al,[bx+XY_POI_TABLE+0x00]
    mov ah,[bx+XY_POI_TABLE+0x01]

    pop bx
    popf
    ret


GET_SNAKE_TELEPORT:
    ; parameters:
    ;  al = current x, ah = current y
    ; returns:
    ;  ax = coords to teleport to, 0xffff (-1) if no teleport

    pushf
    push bx
    push dx

    ; get first teleport location (source)
    mov bl,[XY_TELEPORT+0x00]
    mov bh,[XY_TELEPORT+0x01]
    ; get second teleport location (destination)
    mov dl,[XY_TELEPORT+0x02]
    mov dh,[XY_TELEPORT+0x03]

    ; if matches, return dx (destination)
    cmp ax,bx
    jz GET_SNAKE_TELEPORT_RETURN

    ; swap source/destination
    xchg bx,dx

    ; if matches, return dx (destination)
    cmp ax,bx
    jz GET_SNAKE_TELEPORT_RETURN

    ; otherwise, no teleport for you!
    mov dx,0xffff

  GET_SNAKE_TELEPORT_RETURN:
    ; set ax = return value
    mov ax,dx
    pop dx
    pop bx
    popf
    ret


IS_EXOTIC_WEAPON:
    ; parameters:
    ;  al = current x, ah = current y
    ; returns:
    ;  flags = z if exotics
    push dx
    ; set dx = location of exotic weapon
    mov dl,[XY_EXOTIC_WEAPON+0x00]
    mov dh,[XY_EXOTIC_WEAPON+0x01]
    ; do compare
    cmp ax,dx
    ; return with flags
    pop dx
    ret


IS_EXOTIC_ARMOR:
    ; parameters:
    ;  al = current x, ah = current y
    ; returns:
    ;  flags = z if exotics
    push dx
    ; set dx = location of exotic armor
    mov dl,[XY_EXOTIC_ARMOR+0x00]
    mov dh,[XY_EXOTIC_ARMOR+0x01]
    ; do compare
    cmp ax,dx
    ; return with flags
    pop dx
    ret


GET_CASTLE_DEATH:
    ; returns:
    ;  al = x coordinate, ah = y coordinate
    push bx

    ; set bl = index of castle death
    mov bl,[IDX_CASTLE_DEATH]
    call GET_POI_BY_OFFSET

    pop bx
    ret


GET_PRAY_LOCATION:
    ; returns:
    ;  al = x coordinate of town, ah = y coordinate of town
    ;  bl = x coordinate w/i town, bh = y coordinate w/i town

    ; set bl = index of pray town
    mov bl,[IDX_TOWN_PRAY]
    call GET_POI_BY_OFFSET

    ; set bx = coordinates of pray location
    mov bl,[XY_PRAY+0x00]
    mov bh,[XY_PRAY+0x01]

    ret


RESET_WORLD_MAP:
    ; returns:
    ;  signed flag = set if error, unset if successful

    push ax
    push cx
    push dx
    push di
    push es

    ; load backup map file
    mov al,0x01
    mov cx,0x0000
    lea dx,[MAP_WORLD_BAK]
    call LOAD_FILE

    ; check for error
    cmp ax,0xffff
    jz RESET_WORLD_MAP_ERROR

    ; save backup map file at ax:0000 to map file
    mov es,ax
    mov di,0x0000
    lea dx,[MAP_WORLD]
    call SAVE_FILE

    ; check for error
    cmp ax,0xffff
    jz RESET_WORLD_MAP_ERROR2

    test al,0x00    ; sf = false (success)

  RESET_WORLD_MAP_FREE:
    ; free it
    mov ax,es
    call FREE_MEMORY

  RESET_WORLD_MAP_DONE:
    pop es
    pop di
    pop dx
    pop cx
    pop ax
    ret

  RESET_WORLD_MAP_ERROR:
    or al,0x00    ; sf = true (error)
    jmp RESET_WORLD_MAP_DONE

  RESET_WORLD_MAP_ERROR2:
    or al,0x00    ; sf = true (error)
    jmp RESET_WORLD_MAP_FREE


IS_WORLD_MODIFIED:
    ; returns:
    ;  carry flag = set if modified, unset if unmodified
    ;  signed flag = set if error, unset if successful

    push ax
    push cx
    push dx
    push si
    push di
    push ds
    push es

    ; load map file
    mov al,0x01
    mov cx,0x0000
    lea dx,[MAP_WORLD]
    call LOAD_FILE

    ; check for error
    cmp ax,0xffff
    jz IS_WORLD_MODIFIED_ERROR

    ; set es:di = map file
    mov es,ax
    mov di,0x0000

    ; load backup map file
    mov al,0x01
    mov cx,0x0000
    lea dx,[MAP_WORLD_BAK]
    call LOAD_FILE

    ; check for error
    cmp ax,0xffff
    jz IS_WORLD_MODIFIED_ERROR

    ; set ds:si = backup map file
    mov ds,ax
    mov si,0x0000

    cld
    repz cmpsb

    ; if we stop comparing b/c not equal, set carry and return
    jnz IS_WORLD_MODIFIED_TRUE

    test al,0x00    ; sf = false (success)
    clc             ; cf = false (unmodified)
    jmp IS_WORLD_MODIFIED_FREE_MAPS

  IS_WORLD_MODIFIED_TRUE:
    test al,0x00    ; sf = false (success)
    stc             ; cf = true (modified)

  IS_WORLD_MODIFIED_FREE_MAPS:
    ; free backup map file
    mov ax,es
    call FREE_MEMORY

  IS_WORLD_MODIFIED_FREE_MAP:
    ; free map file
    mov ax,ds
    call FREE_MEMORY

  IS_WORLD_MODIFIED_DONE:
    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret

  IS_WORLD_MODIFIED_ERROR2:
    or al,0xff      ; sf = true (error)
    jmp IS_WORLD_MODIFIED_FREE_MAP

  IS_WORLD_MODIFIED_ERROR:
    or al,0xff      ; sf = true (error)
    jmp IS_WORLD_MODIFIED_DONE


RESET_PARTY:
    ; returns:
    ;  sf = true on error, false on success

    push cx
    push dx

    mov cx,0x0112
    lea dx,[SAVE_PARTY]
    call CREATE_EMPTY_FILE

    pop dx
    pop cx
    ret


RESET_ROSTER:
    ; returns:
    ;  sf = true on error, false on success

    push cx
    push dx

    mov cx,0x0500
    lea dx,[SAVE_ROSTER]
    call CREATE_EMPTY_FILE

    pop dx
    pop cx
    ret


CREATE_EMPTY_FILE:
    ; params:
    ;  cx = file size
    ;  dx = file name
    ; returns:
    ;  sf = true on error, false on success

    push ax
    push bx
    push cx
    push di
    push es

    ; set bx = file size
    mov bx,cx

    ; allocate memory segment
    mov ax,cx
    call ALLOCATE_MEMORY

    ; check for error
    cmp ax,0xffff
    jz CREATE_EMPTY_FILE_ALLOC_ERROR

    ; initialize space to 0x00
    cld
    mov es,ax
    mov di,0x0000
    mov al,0x00
    rep stosb

    ; save file to disk
    mov cx,bx
    mov di,0x0000
    call SAVE_FILE

    ; check for error
    cmp ax,0xffff
    jz CREATE_EMPTY_FILE_SAVE_ERROR

    test al,0x00    ; sf = false (success)

  CREATE_EMPTY_FILE_FREE:
    ; free memory segment
    mov ax,es
    call FREE_MEMORY

  CREATE_EMPTY_FILE_DONE:
    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

  CREATE_EMPTY_FILE_ALLOC_ERROR:
    or al,0xff      ; sf = true (error)
    jmp CREATE_EMPTY_FILE_DONE

  CREATE_EMPTY_FILE_SAVE_ERROR:
    or al,0xff      ; sf = true (error)
    jmp CREATE_EMPTY_FILE_FREE


include "../common/strcpy.asm"
include "../common/loadfile.asm"
include "../common/savefile.asm"