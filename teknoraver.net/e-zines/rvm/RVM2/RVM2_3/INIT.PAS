program Init;

{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M 16384,0,655360}

const
  csize = 1024;

  cs_size = 3000;

function Hex : Word; assembler;
  asm
    AAM 16
    ADD AL, 90H
    DAA
    ADC AL, 40H
    DAA
    XCHG AL, AH
    ADD AL, 90H
    DAA
    ADC AL, 40H
    DAA
  end;

function HexWord(W : Word) : String; assembler;
  asm
    LES DI, @RESULT
    CLD
    MOV AL, 4
    STOSB
    MOV AL, BYTE PTR W + 1
    CALL Hex
    STOSW
    MOV AL, BYTE PTR W + 0
    CALL Hex
    STOSW
  end;

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

var
  f, o : file;
  t : text;
  h : texeheader;
  x : array[1..32768] of byte;
  i,j, w : word;
  virsize : longint;

  ch : array[1..1000] of byte;
  cv : array[1..csize] of byte;

begin
  assign(f, '1.exe');
  reset(f,1);
  if ioresult <> 0 then begin
    writeln(#7'1.EXE not found');
    halt;
  end;

  blockread(f, h, sizeof(h));
  seek(f, h.relofs);
  blockread(f, x, h.relnum * 4, w);

  assign(o, 'relo');
  rewrite(o,1);
  blockwrite(o, x, w);
  close(o);

  virsize := longint(h.num512-1)*512+h.last512 - h.headersize*16;

  seek(f, h.headersize * 16);
  fillchar(x, sizeof(x), 0);
  blockread(f, x, virsize);

  close(f);

  assign(o, '__1');
  rewrite(o,1);
  blockwrite(o, x, cs_size);
  close(o);

  fillchar(ch, sizeof(ch), 0);
  fillchar(cv, sizeof(cv), 0);
  for i := 1 to cs_size do
  begin
    inc(ch[1+(i-1) div csize], x[i]);
    inc(cv[1+(i-1) mod csize], x[i]);
  end;

  assign(o, 'ch');
  rewrite(o,1);
  blockwrite(o, ch, (cs_size + csize-1) div csize);
  close(o);

  assign(o, 'cv');
  rewrite(o,1);
  blockwrite(o, cv, csize);
  close(o);

  assign(t, 'csipsssp.inc');
  rewrite(t);
  writeln(t);
  writeln(t, 'const');
  writeln(t, '  virsize = ', virsize,';');
  writeln(t);
  writeln(t, 'const');
  writeln(t, '  mycs = $',hexword(h.cs),';');
  writeln(t, '  myip = $',hexword(h.ip),';');
  writeln(t, '  myss = $',hexword(h.ss),';');
  writeln(t, '  mysp = $',hexword(h.sp),';');
  writeln(t);
  close(t);

end.
