; CORE.ASM
; Author: Michael C. Maggio
;
; Core routines used by the Ultima Upgrade launchers.


; Loads the launcher config file.
LOAD_CFG:
	; params:
	;  cx = cfg file size

    ; read u3.cfg into cfgdata location
    mov al,0x00
    lea bx,[CFGDATA]
    lea dx,[CFG_FILE]
    call LOAD_FILE

    ; handle failure
    cmp ax,0xffff
    jnz LOAD_CFG_SUCCESS

    ; copy filename to error msg
    mov si,dx
    lea di,[FILE_ERROR_NAME]
    call STRCPY

    ; print error message
    mov dx,FILE_ERROR
    call ERROR

  LOAD_CFG_SUCCESS:
	ret


; Loads the game mod
LOAD_MOD:
    push ds

    ; save offset to cfgdata in bx
    lea bx,[CFGDATA]

    ; read cmd line param length at cs-0010:0080
    mov ax,cs
    mov ds,ax
    lea si,[0x0080]
    lodsb

    ; if none provided, use default mod name
    and al,al
    jz LOAD_MOD_COPY_DEFAULT

    ; otherwise, skip first space
    cbw
    mov cx,ax
    inc si
    dec cx

    ; ensure cx is capped at 8 characters
    cmp cx,0x08
    jbe LOAD_MOD_COPY_CMDLINE
    mov cx,0x08

  LOAD_MOD_COPY_CMDLINE:
    ; get mod name from command line
    lea di,[MOD_FILENAME]
    call STRNCPY
    pop ds
    jmp LOAD_MOD_COPY_SUFFIX

  LOAD_MOD_COPY_DEFAULT:
    pop ds

    ; get mod id from config
    mov si,[bx+0x07]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[MOD_LIST+si]

    ; use default mod name
    mov si,dx
    lea di,[MOD_FILENAME]
    call STRCPY

	; set cx = length of mod name
    call STRLEN

  LOAD_MOD_COPY_SUFFIX:
    ; append .mod suffix
    lea si,[MOD_SUFFIX]
    add di,cx
    call STRCPY

    ; load mod
    lea dx,[MOD_FILENAME]
    call LOAD_DRIVER
    lea bp,[MOD_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize mod
    call far [ds:bp]
    jns LOAD_MOD_DONE

    ; print error & exit
    lea dx,[MOD_ERROR]
    call ERROR

  LOAD_MOD_DONE:
	ret


LOAD_SFX_DRV:
    ; save offset to cfgdata in bx
    lea bx,[CFGDATA]

    ; get sfx driver id from config
    mov si,[bx+0x06]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[SFX_DRV_LIST+si]

    ; load sfx driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[SFX_DRV_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize sfx driver
    call far [ds:bp]

	ret


LOAD_MUSIC_DRV:
    ; save offset to cfgdata in bx
    lea bx,[CFGDATA]

    ; get music driver id from config
    mov si,[bx]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[MUSIC_DRV_LIST+si]

    ; load music driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[MUSIC_DRV_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize music driver
    call far [ds:bp]

    cmp ax,0x0001
    jnz LOAD_MUSIC_DRV_SUCCESS        ; jump here on success

    ; print error & exit
    lea dx,[MUSIC_ERROR]
    call ERROR

  LOAD_MUSIC_DRV_SUCCESS:
	ret


LOAD_VIDEO_DRV:
    ; save offset to cfgdata in bx
    lea bx,[CFGDATA]

    ; get graphic driver id from config
    mov si,[bx+0x03]
    and si,0x00ff

    ; lookup driver in table
    shl si,1
    mov dx,[VIDEO_DRV_LIST+si]

    ; load video driver and store segment address in memory
    call LOAD_DRIVER
    lea bp,[VIDEO_DRV_ADDR]
    mov [ds:bp+0x02],ax

    ; initialize video driver
    call far [ds:bp]

	ret


LAUNCH_PROGRAM:
    ; set dx = offset of executable
    lea dx,[ULTIMA_EXE]

    ; fill parameter block
    lea bx,[PRM_BLOCK]
    mov word [bx],0x0000
    mov word [bx+0x02],EXE_PARAMS
    mov [bx+0x04],ds
    mov word [bx+0x06],FCB
    mov [bx+0x08],ds
    mov word [bx+0x0a],FCB
    mov [bx+0x0c],ds

    ; launch Ultima game
    mov ax,0x4b00
    xor cx,cx               ; clear cx
    int 0x21                ; execute

    jnc LAUNCH_PROGRAM_DONE ; jump here on success

    ; print launch error & exit
    lea dx,[LAUNCH_ERROR]
    call MESSAGE

  LAUNCH_PROGRAM_DONE:
	ret


FREE_SFX_DRV:
    ; check if sfx driver was loaded
    lea bx,[SFX_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_SFX_DRV_DONE

    ; close sfx driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free sfx driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_SFX_DRV_DONE

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  FREE_SFX_DRV_DONE:
	ret


FREE_MUSIC_DRV:
    ; check if music driver was loaded
    lea bx,[MUSIC_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_MUSIC_DRV_DONE

    ; close music driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free music driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_MUSIC_DRV_DONE

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  FREE_MUSIC_DRV_DONE:
	ret


FREE_VIDEO_DRV:
    ; check if video driver was loaded
    lea bx,[VIDEO_DRV_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_VIDEO_DRV_DONE

    ; close video driver's resources
    mov word [bx],0x0003
    call far [bx]

    ; free video driver (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_VIDEO_DRV_DONE

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  FREE_VIDEO_DRV_DONE:
	ret


FREE_MOD:
    ; check if mod was loaded
    lea bx,[MOD_ADDR]
    mov ax,[bx+0x02]
    and ax,ax
    jz FREE_MOD_DONE

    ; close mod's resources
    mov word [bx],0x0003
    call far [bx]

    ; free mod (ax = segment address)
    call FREE_MEMORY

    ; check for errors
    and ax,ax
    jz FREE_MOD_DONE

    ; print free error & exit
    lea dx,[FREE_ERROR]
    call MESSAGE

  FREE_MOD_DONE:
	ret


MESSAGE:
    ; parameters:
    ;  dx = address of message text

    pushf
    push ax

    ; print message
    mov ah,0x09
    int 0x21                ; print string

    pop ax
    popf
    ret


ERROR:
    call MESSAGE

    ; exit with errorlevel 1
    mov al,0x01
    jmp ERROR_EXIT


EXIT:
    ; set errorlevel for exit
    mov al,0x00

  ERROR_EXIT:
    ; I_FLAG will be set to 01 if interrupt vectors have been set
    cmp byte [I_FLAG],0x01
    jnz TERMINATE

    ; reset the interrupt vectors
    call RESET_VECTORS

  TERMINATE:
    ; exit with errorlevel al
    mov ah,0x4c
    int 0x21                ; exit


LOAD_DRIVER:
    ; parameters:
    ;  ds:dx = offset to driver name
    ; returns:
    ;  ax:0000 = segment:offset of loaded driver

    pushf
    push cx
    push dx
    push si
    push di

    ; load driver
    mov al,0x01
    xor cx,cx
    call LOAD_FILE

    ; handle failure
    cmp ax,0xffff
    jnz LOAD_DRIVER_SUCCESS

    ; copy filename to error msg
    mov si,dx
    lea di,[FILE_ERROR_NAME]
    call STRCPY

    ; print error message
    mov dx,FILE_ERROR
    call ERROR

  LOAD_DRIVER_SUCCESS:
    pop di
    pop si
    pop dx
    pop cx
    popf
    ret


; include supporting files
include '../common/strcpy.asm'
include '../common/loadfile.asm'