
type
  TExeHeader = record
    mz,
    last512,
    num512,
    relnum,
    headersize,
    minmem,
    maxmem,
    exess,
    exesp,
    checksum,
    exeip,
    execs,
    relofs,
    ovrnum      : Word;
  end;

var
  F, O : File;
  H : TExeHeader;
  P : Pointer;
  i, C1, Max : Word;

begin
  GetMem(P, $FFF0);

  assign(F, '1.EXE');
  reset(F,1);

  blockread(F, H, sizeof(H));

  seek(F, 0);
  assign(O, '1.HDR');
  rewrite(O,1);
  blockread(F, P^, 28, Max);
  blockwrite(O, P^, Max);
  close(O);

  seek(F, H.RelOfs);
  assign(O, '1.REL');
  rewrite(O,1);
  blockread(F, P^, H.RelNum * 4, Max);
  blockwrite(O, P^, Max);
  close(O);

  C1 := MemW[Seg(P^):Ofs(P^) + H.RelNum * 4 - 2];

  assign(O, '1.R2');
  rewrite(O,1);
  for i := 1 to H.RelNum do
  begin
    if MemW[Seg(P^):Ofs(P^) + (i-1) * 4 + 2] = C1 then
      blockwrite(O, MemW[Seg(P^):Ofs(P^) + (i-1) * 4], 2);
  end;
  close(O);

  seek(F, H.HeaderSize * 16);
  assign(O, '1.C1');
  rewrite(O,1);
  blockread(F, P^, C1 shl 4, Max);
  blockwrite(O, P^, Max);
  close(O);

  assign(O, '1.C2');
  rewrite(O,1);
  blockread(F, P^, (FileSize(F) - 78 - 16384) - FilePos(F) - 2, Max);
  blockwrite(O, P^, Max);
  close(O);

  seek(f, filepos(f) + 2);  { @ }

  assign(O, '1.C3');
  rewrite(O,1);
  blockread(F, P^, 16384, Max);
  blockwrite(O, P^, Max);
  close(O);

  assign(O, '1.C4');
  rewrite(O,1);
  blockread(F, P^, $FFFF, Max);
  blockwrite(O, P^, Max);
  close(O);

  close(F);
end.
