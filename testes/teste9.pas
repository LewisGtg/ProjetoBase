program cmdIf (input, output);
var 
  i, j: integer;
begin
  if (i div 2 * 2 = i) then
  begin
    if (i > 2) then
      j := 1
    else
      j := 2;
  end;
  i := i + 1;
end.