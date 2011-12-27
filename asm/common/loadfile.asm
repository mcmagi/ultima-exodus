; LOADFILE.ASM
; Author: Michael C. Maggio
;
; Utility functions for file input operations.

LOAD_FILE:
    ; parameters:
    ;  al = mode: 00 for fixed location, 01 for allocation (must be freed)
    ;  bx = if mode is 00, will load to ds:bx
    ;  cx = bytes to read, or 0 for entire file
    ;  ds:dx = ptr to filename
    ; return:
    ;  ax = mode 00: ds on success, mode 01: segment address, -1 on failure
    ;  cx = bytes read

    pushf
    push bx
    push dx
    push si
    push di
    push es

    ; set es:di = offset of read location (if mode 00)
    push ds
    pop es
    mov di,bx

    ; set si = mode
    xor ah,ah
    mov si,ax

    ; open file
    mov ah,0x3d
    mov al,0x00           ; open read-only
    int 0x21              ; OPEN
    jc LOAD_FAILURE

    ; save file handle
    mov bx,ax

    ; if read size specified, skip file size
    cmp cx,0x0000
    jnz LOAD_ALLOCATE

    ; cx = file size
    call FILE_SIZE
    mov cx,ax

    ; check for file size error
    cmp cx,0xffff
    jz LOAD_FAILURE

  LOAD_ALLOCATE:
    ; if mode == 0, skip allocation
    cmp si,0x0000
    jz LOAD_READ

    ; allocate memory with size specified in ax
    call ALLOCATE_MEMORY
    cmp ax,0xffff
    jz LOAD_FAILURE

    ; set es:di = segment:offset of new memory
    mov es,ax
    mov di,0x0000

  LOAD_READ:
    ; store ds before read
    push ds

    ; set ds:dx = es:di (read location)
    push es
    pop ds
    mov dx,di

    ; read file of size cx from FH bx to ds:dx
    ; bx = file handle, cx = file size, ds:dx = new memory
    mov ah,0x3f
    int 0x21              ; READ

    ; restore ds after read
    pop ds

    ; handle failure
    jc LOAD_FAILURE

    ; handle insufficient bytes read as failure
    cmp ax,cx
    jnz LOAD_FAILURE

    ; close the file
    mov ah,0x3e
    int 0x21              ; CLOSE
    jc LOAD_FAILURE

    ; set ax = location of new memory
    mov ax,es
    jmp LOAD_DONE

  LOAD_FAILURE:
    mov ax,0xffff

  LOAD_DONE:
    pop es
    pop di
    pop si
    pop dx
    pop bx
    popf
    ret


FILE_SIZE:
    ; parameters:
    ;  bx = file handle
    ; returns:
    ;  ax = file size or -01 on failure

    pushf
    push bx
    push cx
    push dx

    ; set cx:dx = 0
    xor cx,cx
    xor dx,dx

    ; get current position
    mov ah,0x42
    mov al,0x01
    int 0x21
    jc FILE_SIZE_ERROR

    ; save current position (dx:ax) in stack
    push ax
    push dx

    ; set position to end of file
    mov ah,0x42
    mov al,0x02
    int 0x21
    jc FILE_SIZE_ERROR

    ; file size should not be >= 64k
    cmp dx,0x0000
    jne FILE_SIZE_ERROR

    ; get current position from stack (cx:dx)
    pop cx
    pop dx

    ; save file size in stack
    push ax

    ; reset position from start of file
    mov ah,0x42
    mov al,0x00
    int 0x21
    jc FILE_SIZE_ERROR

    ; retrieve file size from stack
    pop ax
    jmp FILE_SIZE_DONE

  FILE_SIZE_ERROR:
    mov ax,0xffff

  FILE_SIZE_DONE:
    pop dx
    pop cx
    pop bx
    popf
    ret

include 'memory.asm'