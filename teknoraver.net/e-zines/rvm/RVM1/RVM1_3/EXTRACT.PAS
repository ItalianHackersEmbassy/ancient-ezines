uses crt, TPU, avp__;

const
  MAX          = 32000;
  MAX_unpacked = 32000;

{ выдираем из дополнения куски данных }
{ расXORиваем их                      }
{ кидаем в файлы '1','2'....          }

const
  SOURCE  = 'ca.avc';

var
  cpr : array[0..128-1] of byte;
  hdr : Tavc_header;
  sux : Tsux;
  i, j : integer;
  l : longint;

var
  fucksize : word;
  fuck     : array[1..max] of byte;
  fn : string;

begin
  inline($B8/$03/$00/$CD/$10);

  { проверки наших структур данных }
  if sizeof(Tavc_header) <> $46 then error('sizeof(Tavc_header) = $' + hexbyte(sizeof(Tavc_header)));
  if sizeof(Tsux)        <>  36 then error('sizeof(Tsux) = ' + fstr(sizeof(Tsux)));

  { загружаем копирайты и хеадер }
  load(source,   0, cpr, sizeof(cpr), nil);
  load(source, $80, hdr, sizeof(hdr), nil);

  for i := 1 to hdr.sux_count do
  begin
    { загружаем запись с информацией о куске данных }
    load(source, hdr.sux_offs + pred(i) * sizeof(Tsux), sux, sizeof(Tsux), nil);

    writeln(i,' -- ',sux.data_size,'/',sux.real_size);

    if (sux.data_size <= MAX) and (sux.real_size < max_unpacked) then
    begin

      load(source, sux.data_offs, fuck, sux.data_size, @fucksize);
      for j := 1 to fucksize do
        fuck[j] := fuck[j] xor pred(j);

      fn := fstr(i);
      save(fn, -1, fuck, fucksize);

    end else
      writeln('  ^^^^^^^^ incorrect size');

  end;

end.
