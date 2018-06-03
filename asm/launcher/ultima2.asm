; ULTIMA2.ASM
; Author: Michael C. Maggio
;
; Ultima 2 Upgrade wrapper program used to load drivers and launch the game.

jmp START

;===========DATA===========

CFG_FILE        db  "U2.CFG",0
ULTIMA_EXE      db  "ULTIMAII.EXE",0
VIDEO_DRV_LIST  dw  CGA_DRV,CGA_COMP_DRV,EGA_DRV,VGA_DRV
CGA_DRV         db  "CGA.DRV",0
CGA_COMP_DRV    db  "CGACOMP.DRV",0
EGA_DRV         db  "EGA.DRV",0
VGA_DRV         db  "VGA.DRV",0
MUSIC_DRV_LIST  dw  NOMIDI_DRV,MIDPAK_DRV
NOMIDI_DRV      db  "NOMIDI.DRV",0
MIDPAK_DRV      db  "MIDPAK.DRV",0
SFX_DRV_LIST    dw  SFX_DRV,SFXTIMED_DRV
SFX_DRV         db  "SFX.DRV",0
SFXTIMED_DRV    db  "SFXTIMED.DRV",0
MOD_LIST        dw  ULTIMA2_MOD,SOSARIA_MOD
ULTIMA2_MOD     db  "ULTIMA2",0
SOSARIA_MOD     db  "SOSARIA",0
MOD_SUFFIX      db  ".MOD",0
MOD_FILENAME    db  0x0d dup 0
EXE_PARAMS      db  0x03,0x20,0xff,0xff,0x0d,0
FILE_ERROR      db  "Error reading "
FILE_ERROR_NAME db  "            ",0x0a,0x0d,"$"
MOD_ERROR       db  "Error initializing mod",0x0a,0x0d,"$"
MUSIC_ERROR     db  "Error initializing Music Driver",0x0a,0x0d,"$"
LAUNCH_ERROR    db  "Error launching Ultima II",0x0a,0x0d,"$"
FREE_ERROR      db  "Error releasing memory for driver",0x0a,0x0d,"$"
OLD_CONFIG_INT  dd  0
OLD_MIDPAK_INT  dd  0
I_FLAG          db  0
CFGDATA         db  0x0b dup 0        ; index: 00 = midi driver, 01 = autosave, 02 = framelimiter, 03 = video driver
                                      ;        04 = enhanced ui, 05 = gameplay fixes, 06 = sfx driver, 07 = mod, 08-0a = theme id
PRM_BLOCK       db  0x16 dup 0
FCB             db  0x20 dup 0
VIDEO_DRV_ADDR  dd  0
MUSIC_DRV_ADDR  dd  0
SFX_DRV_ADDR	dd  0
MOD_ADDR    	dd  0


;===========CODE===========

START:
	; resize memory block to 0xa00 (2560) bytes
	mov ah,0x4a
	mov bx,0x00a0
	int 0x21		; resize

	; move stack to end of memory block
	mov ax,cs
	mov ss,ax
	mov sp,0x09fe

	; set ds = cs + 0x10
	mov ax,cs
	add ax,0x0010
	mov ds,ax
	mov es,ax

	; read u2.cfg into cfgdata location
	mov cx,0x000b
	call LOAD_CFG

	; set new interrupt vectors
	call SET_VECTORS

	; set I_FLAG to 01 (indicates we have set new interrupts)
	mov byte [I_FLAG],0x01

	; load mods & drivers
	call LOAD_VIDEO_DRV

	; launch
	call LAUNCH_PROGRAM

    ; reset segment registers and stack
    mov ax,cs
    mov ss,ax
    add ax,0x0010
    mov ds,ax
    mov es,ax
    mov sp,0x09fe

	; free mods & drivers
	call FREE_VIDEO_DRV

	; exit
	call EXIT

; include supporting files
include 'core.asm'
include 'interrupts.asm'