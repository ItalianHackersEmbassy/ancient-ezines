program gen_1000_bat_file; {Generate batch file to create 1000 hosts and infect them}

var
  s,n:string;
  bf:text;
  j:word;

begin
  assign(bf,'gen1000.bat');
  rewrite(bf);
  writeln(bf,'md 1000');
  writeln(bf,'cd 1000');
  for j:=1 to 1000 do
    begin
      str(j,n);
      while length(n)<4 do n:='0'+n;
      writeln(bf,'copy ..\test.com ',n,'.com');
    end;
  writeln(bf,'md inf');
  writeln(bf,'..\vmedemo');
  for j:=2 to 1000 do
    begin
      str(j-1,n);
      while length(n)<4 do n:='0'+n;
      writeln(bf,n);
      writeln(bf,'copy ',n,'.com inf');
      writeln(bf,'del ',n,'.com');
    end;
  writeln(bf,'copy 1000.com inf');
  writeln(bf,'del 1000.com');
  close(bf);
end.