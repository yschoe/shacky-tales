program sounds (output);

uses crt;

 begin
   repeat
    sound(345);
    delay(100);
    nosound;
    sound(355);
    delay(100);
    nosound;
   until keypressed;
 end.