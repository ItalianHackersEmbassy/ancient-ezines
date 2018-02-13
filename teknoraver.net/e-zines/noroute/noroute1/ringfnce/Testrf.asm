TITLE    Programme qui regarde si le r‚sident RingFence
;            est installe   ### Basic version ###
.model Small
.code
dosseg
org     100h

start:
         mov di,5349h
         mov si,4e47h
         mov ax,3080h
         int 13h
         cmp al,0ffh
         je @inst
         mov ah,09h
         mov dx,offset TEXTnoninst
         int 21h
         jmp @fin
@inst:
         mov ah,09h
         mov dx,offset TEXTinst
         int 21h

@fin:
         mov ax,4c00h
         int 21h

TEXTnoninst  db "Le resident RF n'est pas installe !$"
TEXTinst db "Le resident RF est installe en memoire !$"

end start





