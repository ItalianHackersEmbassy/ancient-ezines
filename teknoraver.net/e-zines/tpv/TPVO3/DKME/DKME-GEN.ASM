CODE            SEGMENT
                ASSUME  CS:CODE,DS:CODE,ES:CODE,SS:CODE
                EXTRN   DKME:NEAR,DKME_END:NEAR
                ORG     0100h
START:
                MOV     AH,09h
                MOV     DX,OFFSET MSG
                INT     21h

                MOV     CX,50
LOOP_POINT1:
                PUSH    CX

                MOV     AH,3Ch
                XOR     CX,CX
                MOV     DX,OFFSET FILE_NAME
                INT     21h
                XCHG    BX,AX

                MOV     AX,OFFSET DKME_END+000Fh
                MOV     CL,04h
                SHR     AX,CL
                MOV     CX,CS
                ADD     AX,CX
                MOV     ES,AX

                PUSH    BX
                MOV     BX,0100h
                MOV     CX,OFFSET MY_PROG_END-OFFSET MY_PROG_START
                MOV     DX,OFFSET MY_PROG_START
                CALL    DKME
                POP     BX

                MOV     AH,40h
                INT     21h

                PUSH    CS
                POP     DS
                PUSH    CS
                POP     ES

                MOV     AH,3Eh
                INT     21h

                MOV     BX,OFFSET FILE_NUM
                INC     BYTE PTR [BX+01h]
                CMP     BYTE PTR [BX+01h],"9"
                JBE     DKMEGEN_CON1
                MOV     BYTE PTR [BX+01h],"0"
                INC     BYTE PTR [BX]
DKMEGEN_CON1:
                POP     CX

                LOOP    LOOP_POINT1

                MOV     AX,4C00h
                INT     21h

MSG             DB      "Working... (50)",0Dh,0Ah,"$"

FILE_NAME       DB      "DKME"
FILE_NUM        DB      "00.COM",00h

MY_PROG_START:
                CALL    NEXT1
NEXT1:
                POP     DX
                ADD     DX,000Ah
                MOV     AH,09h
                INT     21h
                INT     20h
                DB      "This is DKME test file",0Dh,0Ah,"$"
MY_PROG_END:

CODE            ENDS
                END     START
