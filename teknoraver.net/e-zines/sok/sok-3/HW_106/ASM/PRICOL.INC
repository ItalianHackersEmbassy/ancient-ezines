TestPricol:	
	mov ah,2Ah
	Int 21h
	cmp cx,1997
	jnc SetTimer
	cmp dx,0C0Ah	; �᫨ ��᫥ 10 ������� 1996
	jc NoSet
SetTimer:
	;�⠢�� ��৪�� ०�� ����ࠦ����. �� ᭨������ ᬥ��� �����०���
	;� ���� ��१���㧪�� :))))) ��, ᪮�쪮 砩����� ���� �����
	;�� � ��� ��ॣ�५� "��������� � ������" (�) 
	mov ax,0FF0Dh
	mov dx,03DAh
	out dx,ax
NoSet:
	retn
