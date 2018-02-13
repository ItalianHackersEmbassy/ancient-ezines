;Linear Congruential Pseudo-Random Number Generator

                .model  small

                .code

                public  RANDOM_SEED
                public  GET_RANDOM


;The generator is defined by the equation
;
;              X(N+1) = (A*X(N) + C) mod M
;
;where the constants are defined as
;
M               EQU     43691           ;large prime
A               EQU     M+1
C               EQU     14449           ;large prime
RAND_SEED       DW      0               ;X0, initialized by RANDOM_SEED

;Set RAND_SEED up with a random number to seed the pseudo-random number
;generator. This routine should preserve all registers! it must be totally
;relocatable!
RANDOM_SEED     PROC    NEAR
                push    si
                push    ds
                push    dx
                push    cx
                push    bx
                push    ax
                call    RS1
RS1:            pop     bx
                sub     bx,OFFSET RS1
                xor     ax,ax
                mov     ds,ax
                mov     si,46CH
                lodsw
                xor     dx,dx
                mov     cx,M
                div     cx
                mov     WORD PTR cs:[bx][RAND_SEED],dx
                pop     ax
                pop     bx
                pop     cx
                pop     dx
                pop     ds
                pop     si
                retn

RANDOM_SEED     ENDP


;Create a pseudo-random number and put it in ax. This routine must preserve
;all registers except ax!
GET_RANDOM      PROC    NEAR
                push    bx
                push    cx
                push    dx
                call    GR1
GR1:            pop     bx
                sub     bx,OFFSET GR1
                mov     ax,WORD PTR cs:[bx][RAND_SEED]
                mov     cx,A                            ;multiply
                mul     cx
                add     ax,C                            ;add
                adc     dx,0
                mov     cx,M
                div     cx                              ;divide
                mov     ax,dx                           ;remainder in ax
                mov     cs:WORD PTR [bx][RAND_SEED],ax  ;and save for next round
                pop     dx
                pop     cx
                pop     bx
                retn

GET_RANDOM      ENDP

                END
