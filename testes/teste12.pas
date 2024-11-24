program passRef(input, output);
var 
  k: integer;

procedure p(n: integer; var g: integer);
var 
  h: integer;
begin
  if (n < 2) then
    g := g + 1
  else
  begin
    h := 0;           
    p(n - 1, h);    
    g := h;           
    p(n - 2, g);
  end;
end    
begin
  k := 1;           
  p(3, k);     
  write(k);     
end.
