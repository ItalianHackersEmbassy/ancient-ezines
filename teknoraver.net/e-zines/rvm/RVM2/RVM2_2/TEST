
                .model tpascal
                .code
                assume ds:code
                locals @@
                org 100h
start:
                lea si, infile
                lea di, outfile
                call packfile

                lea si, outfile
                lea di, newfile
                call unpackfile

                mov ax, 4c00h
                int 21h

packfile:       call openfiles

@@1:            mov ah, 3fh
                mov bx, inhandle
                lea dx, inbuf
                mov cx, maxinsize
                int 21h
                mov insize, ax

                or ax, ax
                jz @@2

                call packbuf

                mov ah, 40h
                mov bx, outhandle
                lea dx, outbuf
                mov cx, outsize
                int 21h

                jmp @@1

@@2:            call closefiles

                ret

unpackfile:     call openfiles

@@2:            mov ah, 3fh
                mov bx, inhandle
                lea dx, outsize
                mov cx, 2
                int 21h

                or ax, ax
                jz @@1

                cmp outsize, 0
                je @@3

                mov ah, 3fh
                mov bx, inhandle
                lea dx, outbuf
                mov cx, outsize
                int 21h

                mov ah, 40h
                mov bx, outhandle
                lea dx, outbuf
                mov cx, outsize
                int 21h

@@3:            mov ah, 3fh
                mov bx, inhandle
                lea dx, outsize
                mov cx, 2
                int 21h

                cmp outsize, 0
                je @@2

                mov ah, 3fh
                mov bx, inhandle
                lea dx, outbuf
                mov cx, 1
                int 21h

                mov cx, outsize
                lea di, outbuf
                mov al, [di]
                cld
                rep stosb

                mov ah, 40h
                mov bx, outhandle
                lea dx, outbuf
                mov cx, outsize
                int 21h

                jmp @@2

@@1:            call closefiles

                ret

openfiles:      mov ax, 3d00h
                mov dx, si
                int 21h
                mov inhandle, ax

                mov ah, 3ch
                xor cx, cx
                mov dx, di
                int 21h
                mov outhandle, ax

                ret

closefiles:     mov ah, 3eh
                mov bx, inhandle
                int 21h

                mov ah, 3eh
                mov bx, outhandle
                int 21h

                ret

packbuf:        lea si, inbuf
                lea di, outbuf

                mov bp, insize

                cld

@@0:            mov bx, si

                xor cx, cx
                xor dx, dx

@@1:            lodsb
                inc cx

                dec bp
                jz @@3

                cmp al, [si]
                jne @@1

                dec cx
                inc dx

@@2:            lodsb
                inc dx

                dec bp
                jz @@4

                cmp al, [si]
                je @@2

@@4:            cmp dx, 5
                jae @@3

                add cx, dx
                xor dx, dx

                or bp, bp
                jnz @@1

@@3:            mov si, bx

                mov ax, cx
                stosw
                rep movsb
                mov ax, dx
                stosw
                mov cx, dx
                jcxz @@5
                rep lodsb
                stosb

@@5:            or bp, bp
                jnz @@0

                xor ax, ax
                stosw
                stosw
                
                sub di, offset outbuf
                mov outsize, di

                ret

infile          db 'test',0
outfile         db 'output',0
newfile         db 'unpacked',0

inhandle        dw ?
outhandle       dw ?

maxinsize       equ 16384
maxoutsize      equ 32768

insize          dw ?
outsize         dw ?

inbuf           db maxinsize dup (?)
outbuf          db maxoutsize dup (?)

                end start
