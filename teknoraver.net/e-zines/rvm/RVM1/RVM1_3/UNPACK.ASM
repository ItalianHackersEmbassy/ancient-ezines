
MAX_packed      EQU 20000
MAX_unpacked    EQU 32000

; распаковываем файлы: 1 в _1,
;                      2 в _2
;                      ...
;                      9 в _9

                .model tiny
                .code

                org 100h
start:
                jmp init

outfile         db '_'
infile          db '0',0

changebyte      equ byte ptr $-2

init:           cmp changebyte, '9'
                je quit
                inc changebyte

                mov ax, 3d02h
                lea dx, infile
                int 21h
                jc init

                xchg bx, ax

                mov ah, 3fh
                lea dx, inbuf
                mov cx, MAX_packed
                int 21h

                mov ah, 3eh
                int 21h

                mov next_byte_ptr, offset inbuf
                lea di, outbuf
                call unpack

                mov ah, 3ch
                lea dx, outfile
                xor cx ,cx
                int 21h
                xchg bx, ax
                mov ah, 40h
                lea dx, outbuf
                lea cx, [di + -(offset outbuf)]
                int 21h
                mov ah, 3eh
                int 21h

                jmp init

quit:           mov ax, 4c00h
                int 21h

getbyte:        mov     bx, next_byte_ptr; CODE XREF: 0000:0C8Cj
                mov     al, [bx]        ; CODE XREF: 0000:0CDEj
                inc     next_byte_ptr
                ret

unpack:         call    getbyte
                push    ax              ; CODE XREF: 0000:0CE3j
                call    getbyte
                pop     bx              ; CODE XREF: 0000:0D02j
                mov     ah, bl
                xchg    ah, al
                mov     bits, ax
                mov     len, 16

loc_0_D20:      call    get_bit     ; CODE XREF: 0000:0D4Cj 0000:0D51j 0000:0E15j 0000:0E37j
                or      ax, ax
                jz      loc_0_D53
                call    getbyte
                mov     [di], al        ; CODE XREF: 0000:0D36j
                inc     di
                cmp     di, offset outbuf + MAX_unpacked
                jne loc_0_d20
                jmp exit

loc_0_D53:      call    get_bit     ; CODE XREF: 0000:0D25j
                or      ax, ax
                jnz     loc_0_D8F
                call    get_bit
                shl     ax, 1
                mov     si, ax
                call    get_bit
                or      si, ax
                add     si, 2
                call    getbyte
                or      ax, 0FF00h      ; CODE XREF: 0000:0D78j
                mov     dx, ax
                jmp     loc_0_E19

loc_0_D8F:      call    getbyte

loc_0_DAD:      mov     ah, 0           ; CODE XREF: 0000:0D9Ej
                mov     dx, ax
                call    getbyte

                mov     ah, 0           ; CODE XREF: 0000:0DC0j
                mov     si, ax
                and     ax, 0FFF8h
                mov     cl, 5
                shl     ax, cl
                or      ax, 0E000h
                or      dx, ax
                and     si, 7
                add     si, 2
                cmp     si, 2
                jnz     loc_0_E19
                call    getbyte

loc_0_E08:
                mov     ah, 0           ; CODE XREF: 0000:0DF9j
                mov     si, ax
                or      si, si
                jz      exit
                cmp     si, 1
                jnz     loc_0_E18
                jmp     loc_0_D20

loc_0_E18:
                inc     si              ; CODE XREF: 0000:0E13j

loc_0_E19:
                mov     ax, di          ; CODE XREF: 0000:0D8Cj 0000:0DE8j
                add     ax, dx
                mov     dx, ax
                jmp short loc_0_E33

loc_0_E21:
                mov     bx, dx          ; CODE XREF: 0000:0E35j
                mov     al, [bx]
                mov     [di], al
                inc     di
                dec     si
                inc     dx
                cmp     di, offset outbuf + MAX_unpacked
                ja     exit

loc_0_E33:
                or      si, si          ; CODE XREF: 0000:0E1Fj 0000:0E2Ej
                jg      loc_0_E21
                jmp     loc_0_D20

exit:
                ret

get_bit:        mov     dx, bits; CODE XREF: 0000:0D20p 0000:0D53p 0000:0D5Ap 0000:0D61p
                and     dx, 1
                mov     al, len
                add     al, -1
                mov     len, al
                jnz     shr_XXX

                call    getbyte
                push    ax              ; CODE XREF: 0000:0E66j
                call    getbyte
                pop     bx              ; CODE XREF: 0000:0E85j
                mov     ah, bl
                xchg    ah, al
                mov     bits, ax
                mov     len, 16
                jmp     @@1

shr_XXX:
                shr     bits, 1 ; CODE XREF: 0000:0E55j
@@1:
                mov     ax, dx          ; CODE XREF: 0000:0EA3j
                retn

bits            dw ?
len             db ?

next_byte_ptr   dw ?

inbuf           db MAX_packed dup (?)
outbuf          db MAX_unpacked dup (?)

                end start
