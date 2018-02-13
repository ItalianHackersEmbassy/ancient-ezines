;############################################################################
;#####                   By Blesk/SVL                                    ####
;############################################################################

;%%%%%%%%%%%%%%%%%%%%%%%% Utils to work with files %%%%%%%%%%%%%%%%%%%%%%%%%%

Begin_file:
             mov        ax,4200h
             push       cx
             push       bx
             mov        bx,[cs:((offset handle)-begin)]
             xor        cx,cx
             xor        dx,dx
             call       dos
             pop        bx
             pop        cx
             ret

End_file:
             mov        ax,4202h
             push       cx
             push       bx
             mov        bx,[cs:((offset handle)-begin)]
             xor        cx,cx
             xor        dx,dx
             call       dos
             pop        bx
             pop        cx
             ret

write_file:
             mov        ax,4000h
             push       cs
             pop        ds
             mov        bx,[cs:((offset handle)-begin)]
             call       dos
             ret

read_file:
             mov        ah,3fh
             push       cs
             pop        ds
             mov        bx,[cs:((offset handle)-begin)]
             call       dos
             ret

open_file:
             mov        ax,3d02h
             call       dos
             mov        [cs:((offset handle)-begin)],ax
             ret

close_file:
             mov        ah,3eh
             mov        bx,[cs:((offset handle)-begin)]
             call       dos
             ret


;############################################################################
;#####                   By Blesk/SVL                                    ####
;############################################################################
