unit mysound;
interface
uses crt;
procedure tsound;

implementation

  procedure tsound;
   begin
     sound(345);
     delay(100);
     nosound;
     sound(355);
     delay(100);
     nosound;
   end;
end.

