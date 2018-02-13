{$A+,B-,D+,E-,F-,G+,I-,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}

{$I VIRUS.INC}

var
  b : array[0..255] of byte;
  w : array[0..255] of word;

begin

  for w[0] := 1 to virus_size do
  begin

    b[0] := virus[w[0]];

    b[0] := b[0] +   1;
    b[0] := b[0] xor 2;
    b[0] := b[0] -   3;
    b[0] := b[0] div 4;
    b[0] := b[0] mod 5;

    virus[w[0]] := b[0];

  end;

end.
