TITLE    Programme DesActivant le r‚sident RingFence ### Basic version ###
.model Small
.code
dosseg
org     100h

start:
         mov di,5349h
         mov si,4e47h
         mov ax,3000h
         int 13h

         mov ah,09h
         mov dx,offset TEXT
         int 21h

         mov ax,4c00h
         int 21h

TEXT     db "Le module r‚sident RF.COM est Desactiv‚.$"

end start





