
include         badasm.inc

include         rulez.inc

                org     100h
start:
                _movC    di, 8000h
                _mov     dx, di
                _movC    ax, '.*'
                _stosw
                _movC    ax, '*'
                _stosw

                _movC   ax, 4e00h
                _movC   cx, 0ffh
xx2:            _int    21h
                jc      xx1

                q       = 0080h
                rept    8+1+3+1
                _mov    ax, (ds:[q].dta_name.w)
                _int    29h
                or      al, al
                jz      xx3
                q       = q + 1
                endm

xx3:            _movC   ax, 13
                _int    29h
                _movC   ax, 10
                _int    29h

                _movC   ax, 4f00h
                jmp     xx2

xx1:            _movC   ax, 4c00h
                _int    21h

                end     start
