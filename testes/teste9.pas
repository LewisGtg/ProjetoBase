program cmdIf (input, output);
var 
  i, j: integer;
begin
  if (i div 2 * 2 = i) then
  begin
    if (i > 2) then
      j := 1
  end
  else
      j := 2;
  i := i + 1;
end.