
                .model tiny
                .code
                .486p
                locals @@

                org 100h
start:
                jmp begin

cf8_read:       mov     ax, 8000h       ; чтение PCI-регистров
                shl     eax, 10h
                mov     ax, cx
                and     al, 0fch
                mov     dx, 0cf8h
                out     dx, eax
                add     dl, 4
                mov     al, cl
                and     al, 3
                add     dl, al
                in      al, dx
                ret

cf8_write:      xchg    ax, cx          ; запись PCI-регистров
                shl     ecx, 10h
                xchg    ax, cx
                mov     ax, 8000h
                shl     eax, 10h
                mov     ax, cx
                and     al, 0fch
                mov     dx, 0cf8h
                out     dx, eax
                add     dl, 4
                mov     al, cl
                and     al, 3
                add     dl, al
                shr     ecx, 10h
                mov     ax, cx
                out     dx, al
                ret

begin:          cli
                cli

                push es
                xor ax, ax
@@2:            mov es, ax
                xor bx, bx
@@1:            add cl, es:[bx]
                inc bx
                jnz @@1
                add ah, 10h
                jnz @@2
                pop es

                ;;;

                mov al, 90h  ; заполняем наёбку NOPами, они попадают в кеш
                lea di, naebka           ; nops -> cache
                mov cx, naebka_size
                cld
                rep stosb

                mov cx, 0052h   ; отключаем кеш/*** disable CACHE ***
                call cf8_read
                mov bp, ax
                and al, 00111100b
                call cf8_write

                ; теперь в наёбке ЧАСТИЧНО то, что было раньше

                xor ax, ax

naebka:         rept 1000
                inc ax
                endm

naebka_size     equ $-naebka

                mov di, ax

                mov cx, 0052h   ; включаем кеш обратно - в наёбке RETы
                mov ax, bp
                call cf8_write

                mov ax, di
                call decword    ; must be 1000 ;)

                mov ax, 4c00h
                int 21h

decword:        xor dx, dx
                mov bx, 10
                div bx
                push dx
                or ax, ax
                jz @@1
                call decword
@@1:            pop ax
                add al, '0'
                int 29h
                ret

                end start
