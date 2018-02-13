TITLE    Programme certifiant 1 hd au format RingFence ### Basic version ###
.model Small
.code
dosseg
org     100h

start:
         mov ah,09h
         mov dx,offset TEXT2
         int 21h
         xor ah,ah
         int 16h
         mov di,5349h
         mov si,4e47h
         mov ax,3009h
         xor dx,dx
         int 13h
         mov ah,09h
         mov dx,offset TEXT
         int 21h
         mov ax,4c00h
         int 21h
TEXT     db 13,10,"Voila la disquette est maintenant certifiee !!! $"
TEXT2    db 13,10,"Placer le disk a certifier et appueyr sur 1 touche (lec A:)$"
end start





