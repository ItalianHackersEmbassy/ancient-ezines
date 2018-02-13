
; пересчёт CRC после изменения файла-куска данных с кодом/обжАми

MAX             EQU 32768

                .model tiny
                .386p
                .code

                org 100h
start:
                jmp init

filename        db 'output_0',0

changebyte      equ byte ptr $-2

fsize           dw ?

init:           cmp changebyte, '9'
                je quit
                inc changebyte

                mov ax, 3d02h
                lea dx, filename
                int 21h
                jc init

                xchg bx, ax

                mov ah, 3fh
                lea dx, eof
                mov cx, MAX
                int 21h
                mov fsize, ax

                push bx
                call recalc
                pop  bx

                mov ax, 4200h
                cwd
                xor cx, cx
                int 21h

                mov ah, 40h
                lea dx, eof
                mov cx, fsize
                int 21h

                mov ah, 3eh
                int 21h

                jmp init

quit:           mov ax, 4c00h
                int 21h

                ; короче, походу так:
                ;  8 байт: WORD     длина всего куска данных
                ;          6 bytes  всякий SUX
                ;  линки .obj файла:
                ;  byte    тип линка
                ;  word    ? длина последующих данных
                ;  ? bytes данные

recalc:         lea si, eof
                cld

@@0:            mov bp, [si]
                add bp, si
                add si, 8

@@2:            xor dx, dx

                lodsb           ; тип линка
                mov dh, al

                call hexbyte
                call space

                add dl, al
                lodsw           ; длина линка

; *************************************************************************
               ; CMP AX, 2405H
               ; JAE @@SKIP
; *************************************************************************

                call hexword
                call space

                xchg cx, ax
                add dl, cl
                add dl, ch
@@1:            lodsb           ; код
                add dl, al
                loop @@1
                sub dl, al      ; последний байт такой, чтобы сумма всего
                neg dl          ; была равна нулю
                mov [si-1], dl
                cmp dl, al
                je @@3

                call space
                call id

@@skip:

@@3:            cmp dh, 8ah
                jne @@4
                ; **************
                jmp @@exit

@@4:            call crlf

                cmp si, bp
                jb @@2

@@exit:         ret





HEXWORD:        push ax
                XCHG AL, AH
                CALL HEXBYTE
                XCHG AL, AH
                call hexbyte
                pop ax
                ret

HEXBYTE:        push ax
                SHR AL, 4
                CALL HEXCHAR
                pop ax
                push ax
                call hexchar
                pop ax
                ret

HEXCHAR:        pusha
                AND AL, 15
                ADD AL, -('0'+'A'-1)
                DAA
                ADC AL, 'A'-1
                DAA
                call putchar
                popa
                RET

id:             push ax
                mov al, '$'
                call putchar
                pop ax

space:          push ax
                mov al, 32
                call putchar
                pop ax
                ret

crlf:           push ax
                mov al, 13
                call putchar
                mov al, 10
                call putchar
                pop ax
                ret

putchar:        pusha
                mov ah, 2
                mov dl, al
                int 21h
                popa
                ret


eof             DB MAX DUP (?)

                end start

