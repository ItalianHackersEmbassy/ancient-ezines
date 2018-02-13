uses TPU;
const
  SOURCE_FILE  = 'fuck.com';
  PRODUCT      = 'output_1';
var
  f : file;
  h : record
        filesize : longint;
        mustdie  : array[1..256] of byte;
      end;
  i,hsize : word;
  b: byte;
  data : record
    id        : byte;  { A0=code }
    codesize  : word;  { max 1024 ? bytes }
    code      : record
                  id    : byte;  { 01 }
                  offs  : word;  { offset }
                  code  : array[1..500] of byte;
                  cs    : byte;
                end;
  end;

begin
  load('HEADER', 0, h, sizeof(h), @hsize);
  save(PRODUCT, -1, h, hsize);
  assign(f, SOURCE_FILE);
  reset(f,1);

  (* seek(f, 512);         { exe-header }   *)

  data.id := $A0;
  data.code.id := 1;
  data.code.offs := 0;
  while not eof(f) do
  begin
    blockread(f, data.code.code, sizeof(data.code.code), data.codesize);
    inc(data.codesize, 4);                          {}
    save(PRODUCT, -2, data, 3 + data.codesize);
    inc(data.code.offs, data.codesize - 4);         {}
  end;
  close(f);

  load('header_e', 0, h, sizeof(h), @hsize);
  save(PRODUCT, -2, h, hsize);

  h.filesize := fsize(PRODUCT);
  save(PRODUCT, 0, h.filesize, 4);
end.
