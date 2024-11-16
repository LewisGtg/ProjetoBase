program cmdIf (input, output);
var i, j: integer;
begin
    j:=5;
    i:=0;
    while (i < j) do
    begin
        if (i div 2 * 2 = i)
            then j:=2
        i := i+1;
    end;
end.