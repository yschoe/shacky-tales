unit sounds;
interface
  uses crt;
  type
    data = record
             chr : char;
             hz : integer;
             dl : integer
           end;

  var
    sd : text;
    tempar : array[1..200] of data;
    i : integer;


  procedure music(f_name:string);
implementation
  procedure music;
   begin
      assign(sd,f_name);
      repeat
      reset(sd);
      i := 0;
      repeat
       i := i + 1;
       readln(sd,tempar[i].chr,tempar[i].hz,tempar[i].dl)
      until tempar[i].chr = 'E';
      i := 1;
       while ((tempar[i].chr <> 'E') and not keypressed) do
        begin
         if (tempar[i].chr = 'S')
           then
             begin
               sound(tempar[i].hz);
               delay(tempar[i].dl);
               nosound;
             end
           else
               delay(tempar[i].dl);
         i := i + 1
        end; (* while *)
      until keypressed;
      close(sd);

    end;(* of procedure *)
  end.
