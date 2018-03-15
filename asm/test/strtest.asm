START:
    ; set ds = cs + 0x10
    mov ax,cs
    add ax,0x0010
    mov ds,ax
    mov es,ax

    call TEST_STRCPY
    call TEST_STRNCPY
    call TEST_STRLEN

    mov al,0x00
    mov ah,0x4c
    int 0x21                ; exit


T1_SRC1         db  "Testdata",0
                db  0x0a,0x0d,"$"
T1_DST1         db  0x10 dup 0
                db  0x0a,0x0d,"$"
T1_SRC2         db  "U3.CFG",0
                db  0x0a,0x0d,"$"
T1_DST2         db  0x10 dup 0x61
                db  0x0a,0x0d,"$"

TEST_STRCPY:
    lea si,[T1_SRC1]
    lea di,[T1_DST1]
    call STRCPY

    mov dx,si
    call MESSAGE
    mov dx,di
    call MESSAGE

    lea si,[T1_SRC2]
    lea di,[T1_DST2]
    call STRCPY

    mov dx,si
    call MESSAGE
    mov dx,di
    call MESSAGE
    ret


T2_SRC1         db  "Testdata",0
                db  0x0a,0x0d,"$"
T2_DST1         db  0x10 dup 0
                db  0x0a,0x0d,"$"
T2_SRC2         db  "U3.CFG",0
                db  0x0a,0x0d,"$"
T2_DST2         db  0x10 dup 0x61
                db  0x0a,0x0d,"$"

TEST_STRNCPY:
    lea si,[T2_SRC1]
    lea di,[T2_DST1]
    mov cx,0x0004
    call STRNCPY

    mov dx,si
    call MESSAGE
    mov dx,di
    call MESSAGE

    lea si,[T2_SRC2]
    lea di,[T2_DST2]
    mov cx,0x000a
    call STRNCPY

    mov dx,si
    call MESSAGE
    mov dx,di
    call MESSAGE
    ret


T3_SRC1         db  "Testdata",0
                db  0x0a,0x0d,"$"
T3_LEN          db  0x10 dup 0
                db  0x0a,0x0d,"$"

TEST_STRLEN:
    lea si,[T3_SRC1]
    call STRLEN

    mov ax,cx
    lea di,[T3_LEN]
    call INT2HEX

    mov dx,si
    call MESSAGE
    mov dx,di
    call MESSAGE
    ret


MESSAGE:
    mov ah,0x09
    int 0x21                ; print string
    ret


include "../common/strcpy.asm"