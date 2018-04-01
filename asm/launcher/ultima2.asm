; ULTIMA2.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade wrapper program used to load drivers and launch the game.

jmp START

;===========DATA===========

u2cfg		    db	"U2.CFG",0
midpak		    db	"MIDPAK.COM",0
midpak_start	db	0x02," 8",0x0d,0
midpak_stop	    db	0x02," u",0x0d,0
u2ega		    db	"ULTIMAII.EXE",0
u2vga		    db	"U2VGA.EXE",0
u2_params	    db	0x03,0x20,0xff,0xff,0x0d,0
file_error	    db	"Error reading U2.CFG",0x0a,0x0d,"$"
midpak_error	db	"Error loading MIDPAK MIDI Driver",0x0a,0x0d,"$"
launch_error	db	"Error launching Ultima II",0x0a,0x0d,"$"
i_data		    db	0x0c dup 0
i_flag		    db	0
cfgdata		    db	0x04 dup 0
prm_block	    db	0x16 dup 0
fcb		        db	0x20 dup 0

;===========CODE===========

START:
  ; resize memory block to 0x500 bytes
  mov ah,0x4a
  mov bx,0x0500
  int 0x21		; resize

  ; move stack to end of memory block
  mov ax,cs
  mov ss,ax
  mov sp,0x04fe

  ; set ds = cs + 0x10
  mov ax,cs
  add ax,0x0010
  mov ds,ax
  mov es,ax

  ; open u2.cfg file
  mov ah,0x3d
  mov al,0x00
  mov dx,u2cfg
  int 0x21		; OPEN
  jc LOAD_FAILURE	; go here on error

  ; save file handle
  mov bx,ax

  ; read u2.cfg file
  mov ah,0x3f
  mov cx,0x04
  mov dx,cfgdata
  int 0x21		; READ
  jc LOAD_FAILURE	; go here on error

  ; close file
  mov ah,0x3e
  int 0x21		; CLOSE
  jnc LOAD_SUCCESS	; go here on success

LOAD_FAILURE:
  ; print error message
  mov dx,file_error
  call ERROR

LOAD_SUCCESS:
  ; set new interrupt vectors
  call SET_VECTORS

  ; set i_flag to 01 (indicates we have set new interrupts)
  mov byte [i_flag],0x01

  ; save offset to parameter block in bx
  mov bp,prm_block

  ; save offset to cfgdata in bx
  mov bx,cfgdata
  push bx

  ; if 1st byte != 01, jump to autosave
  cmp byte [bx],0x01
  jnz GRAPHIC_MODE

  ; fill parameter block
  mov bx,bp		; set parameter block
  mov word [bx],0x0000
  mov word [bx+0x02],midpak_start
  mov [bx+0x04],ds
  mov word [bx+0x06],fcb
  mov [bx+0x08],ds
  mov word [bx+0x0a],fcb
  mov [bx+0x0c],ds

  ; run midpak program
  mov ax,0x4b00
  xor cx,cx		; clear cx
  mov dx,midpak
  int 0x21		; execute

  jnz GRAPHIC_MODE	; jump here on success

  ; print midpak error & exit
  mov dx,midpak_error
  call ERROR

GRAPHIC_MODE:
  pop bx

  ; if 4th byte == 01, jump to vga
  cmp byte [bx+0x03],0x03
  jz VGA

  ; set dx = offset of "u2ega.com"
  mov dx,u2ega
  jmp LAUNCH_PROGRAM

VGA:
  ; set dx = offset of "u2vga.com"
  mov dx,u2vga

LAUNCH_PROGRAM:
  push bx

  ; fill parameter block
  mov bx,bp		; set parameter block
  mov word [bx],0x0000
  mov word [bx+0x02],u2_params
  mov [bx+0x04],ds
  mov word [bx+0x06],fcb
  mov [bx+0x08],ds
  mov word [bx+0x0a],fcb
  mov [bx+0x0c],ds

  ; launch Ultima 2
  mov ax,0x4b00
  xor cx,cx		; clear cx
  int 0x21		; execute
  jnz STOP_MIDPAK	; jump here on success

  ; print launch error & exit
  mov dx,launch_error
  call U2_ERROR

STOP_MIDPAK:
  pop bx

  ; if 1st byte != 01, jump to exit
  cmp byte [bx],0x01
  jnz EXIT

  ; fill parameter block
  mov bx,bp		; set parameter block
  mov word [bx],0x0000
  mov word [bx+0x02],midpak_stop
  mov [bx+0x04],ds
  mov word [bx+0x06],fcb
  mov [bx+0x08],ds
  mov word [bx+0x0a],fcb
  mov [bx+0x0c],ds

  ; run midpak program
  mov ax,0x4b00
  xor cx,cx		; clear cx
  mov dx,midpak
  int 0x21		; execute

  jnz EXIT		; jump here on success

  ; print midpak error & exit
  mov dx,midpak_error
  call ERROR

EXIT:
  ; set errorlevel for exit
  mov al,0x00

  ; i_flag will be set to 01 if interrupt vectors have been set
  cmp byte [i_flag],0x01
  jnz TERMINATE

  ; reset the interrupt vectors
  call RESET_VECTORS

TERMINATE:
  ; exit with errorlevel al
  mov ah,0x4c
  int 0x21		; exit


;===========FCNS===========

WRAPPER:
  ; wrapper fcn (does nothing)
  iret


ULTIMA2_INT:
  push bx

  ; set bx as offset to config data
  mov bx,cfgdata

  ; fcn 00 = autosave check
  cmp ah,0x00
  jz AUTOSAVE

  ; fcn 01 = frame limiter check
  cmp ah,0x01
  jz FRAMELIMITER

  jmp RETURN

AUTOSAVE:
  ; returns al=01 if autosave enabled
  mov al,[cs:bx+0x01]
  jmp RETURN

FRAMELIMITER:
  ; returns al=01 if frame limiter enabled
  mov al,[cs:bx+0x02]

RETURN:
  pop bx
  iret


SET_VECTORS:
  pushf
  push ax
  push cx
  push si
  push di
  push ds
  push es

  cli			; clear interrupt flag
  cld			; clear direction flag

  push ds
  pop es		; copy ds into es
  xor ax,ax		; clear ax
  mov ds,ax		; clear ds

  ; set source/dest index
  mov si,0x0194		; offset of int vect 65
  mov di,i_data	    ; offset of backup int table

  ; move 4 words
  mov cx,0x0004
  rep
  movsw			; move a word from ds:si to es:di

  ; set default values for new vectors
  mov ax,cs
  add ax,0x0010
  mov word [0x0194],ULTIMA2_INT
  mov [0x0196],ax
  mov word [0x0198],WRAPPER
  mov [0x019a],ax

  sti			; set interrupt flag

  ; return
  pop es
  pop ds		; restore ds
  pop di
  pop si
  pop cx
  pop ax
  popf
  ret


RESET_VECTORS:
  pushf
  push ax
  push cx
  push si
  push di
  push es

  cli			; clear interrupt flag

  ; set es to interrupt vector table
  xor ax,ax		; clear ax
  mov es,ax		; clear es

  ; set source/dest index
  mov si,i_data	    ; offset of backup int table
  mov di,0x0194		; offset of int vect 64

  ; move 4 words
  mov cx,0x0004
  rep
  movsw			; move a word from ds:si to es:di

  sti			; set interrupt flag

  ; return
  pop es
  pop di
  pop si
  pop cx
  pop ax
  popf
  ret


ERROR:
  ; print error message
  mov ah,0x09
  int 0x21		; print string

  ; exit with errorlevel 1
  mov al,0x01
  jmp EXIT


U2_ERROR:
  ; print error message
  mov ah,0x09
  int 0x21		; print string

  ; return to unload the midpak driver first before quitting
  ret
