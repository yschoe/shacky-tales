program font_editor (input,output);

uses crt,graph,myinit;

label jmp1,jmp2,endprog,jmp3;
var
    max : integer;
    rangex,rangey : integer;      {range}
    cox1,coy1,cox2,coy2 : integer;        {coordinate}
    x,y : integer;
    inx,iny:integer;
    buffer: array[1..50,1..50] of integer;
    ch: char;
    choice:integer;
    filename:string;
    infile: text;
    endchk: boolean;

procedure square(x,y,xx,yy: integer);
     begin
        line(x,y,xx,y);
        line(xx,y,xx,yy);
        line(xx,yy,x,yy);
        line(x,yy,x,y);
     end;

procedure mark(x,y:integer);
   begin
      square(x-1,y-1,x+1,y+1);
   end;

procedure mmark(x,y:integer);
   begin
     setcolor(1);
     square(x-2,y-2,x+2,y+2);
     setfillstyle(1,1);
     floodfill(x-1,y-1,1);
   end;

procedure unmark(x,y:integer);
   begin
      setcolor(0);
      square(x-1,y-1,x+1,y+1);
      setcolor(1);
   end;

procedure unmmark(x,y:integer);
     begin
      setcolor(0);
      square(x-2,y-2,x+2,y+2);
      setfillstyle(0,0);
      floodfill(x-1,y-1,0);
      setcolor(1);
   end;




begin
    clrscr;
    write('*************************** Font Editor V1.0');
    writeln(' ***************************');
    writeln;
jmp1:write('     Enter number of grids   (max:50):');
    read(max);
    if (max<1) or (max>60) then goto jmp1;
    writeln;
jmp2:writeln('     Which character will you choose?:');
    writeln('    1.prince   2.princess   3.skeleton   4.fox');
    writeln('    5.bat      6.slime      7.alien      8.alf');
    writeln('    9. 10.......22');
    gotoxy(39,5);
    read(choice);

    case choice of
         1: filename:='a:prince.fon';
         2: filename:='a:princess.fon';
         3: filename:='a:skeleton.fon';
         4: filename:='a:fox.fon';
         5: filename:='a:bat.fon';
         6: filename:='a:slime.fon';
         7: filename:='a:alien.fon';
         8: filename:='a:alf.fon';
         9: filename:='a:choco.fon';
         10:filename:='a:gem.fon';
         11:filename:='a:shswd.fon';
         12:filename:='a:lgswd.fon';
         13:filename:='a:saber.fon';
         14:filename:='a:mount.fon';
         15:filename:='a:tree.fon';
         16:filename:='a:water.fon';
         17:filename:='a:cave.fon';
         18:filename:='a:vend.fon';
         19:filename:='a:wall.fon';
         20:filename:='a:house.fon';
         21:filename:='a:blank.fon';
         22:filename:='a:rock.fon';
         23:filename:='a:anya.fon';
         24:filename:='a:pr2.fon';
         25:filename:='a:pru.fon';
         26:filename:='a:prd.fon';
         27:filename:='caveend.fon';
         28:filename:='smash.fon';
         29:filename:='map.fon';

    end;
   init_g;

   cox1:=5;
   coy1:=5;
   cox2:=max*6+1;
   coy2:=6;
   x:=1;
   y:=1;

   square(cox1-5,coy1-5,max*5+5,max*5+5);
   square(max*6,5,max*7+1,max+6);
   square(300,150,600,250);

    assign(infile,filename);
    reset(infile);
    for y:=1 to max do
        for x:=1 to max do
            begin
               read(infile,ch);
               buffer[x,y]:=ord(ch)-ord('0');
               if buffer[x,y]=1 then
                  begin
                      mmark(5*x,5*y);
                      putpixel(max*6+x,y+5,1)
                  end;
               if x= max then readln(infile);
            end;

    for y:=1 to max do
       for x:=1 to max do
           putpixel(x*5,y*5,1);

   settextstyle(4,0,4);
   outtextxy(305,160,'Font Editor V1.0');
   settextstyle(3,0,1);
   outtextxy(305,194,'  up:8 left:4 down:6 rght:2 ');
   outtextxy(305,210,'  D:plot,E:erase,C:clear,Q:quit');
   outtextxy(305,226,'  S:save,I:inverse       89 YSC');
   x:=1;
   y:=1;

endchk:=false;
repeat
   if buffer[x,y]=1 then setcolor(0);
   mark(cox1,coy1);
   setcolor(1);
   ch:=readkey;
   case ch of
      '8':if coy1<>5 then
             begin
                unmark(cox1,coy1);
                if buffer[x,y]=1 then mmark(cox1,coy1);
                coy1:=coy1-5;
                coy2:=coy2-1;
                if buffer[x,y-1]=1 then setcolor(0);
                mark(cox1,coy1);
                y:=y-1;
                setcolor(1);
             end;

      '4':if cox1<>5 then
             begin
                unmark(cox1,coy1);
                if buffer[x,y]=1 then mmark(cox1,coy1);
                cox1:=cox1-5;
                cox2:=cox2-1;
                if buffer[x-1,y]=1 then setcolor(0);
                mark(cox1,coy1);
                x:=x-1;
                setcolor(1);
             end;

      '6':if cox1<>(5*max) then
             begin
                unmark(cox1,coy1);
                if buffer[x,y]=1 then mmark(cox1,coy1);
                cox1:=cox1+5;
                cox2:=cox2+1;
                if buffer[x+1,y]=1 then setcolor(0);
                mark(cox1,coy1);
                x:=x+1;
                setcolor(1);
             end;

      '2':if coy1<>(5*max) then
             begin
                unmark(cox1,coy1);
                if buffer[x,y]=1 then mmark(cox1,coy1);
                coy1:=coy1+5;
                coy2:=coy2+1;
                if buffer[x,y+1]=1 then setcolor(0);
                mark(cox1,coy1);
                y:=y+1;
                setcolor(1);
             end;

      'd','D': begin
              mmark(cox1,coy1);
              putpixel(cox2,coy2,1);
              buffer[x,y]:=1
           end;

      'e','E': begin
              unmmark(cox1,coy1);
              putpixel(cox2,coy2,0);
              buffer[x,y]:=0;
              putpixel(cox1,coy1,1);
           end;
      'c','C': begin
              for x:=1 to max do
                  for y:=1 to max do
                    begin
                      unmmark(x*5,y*5);
                      putpixel(x*5,y*5,0);
                      buffer[x,y]:=0;
                      putpixel(x*5,y*5,1);
                      putpixel(6*max+x,5+y,0);
                    end;
            end;
      's','S':endchk:=true;
      'i','I':begin
                for inx:=1 to max do
                    for iny:=1 to max do
                        if buffer[inx,iny]=1 then
                           buffer[inx,iny]:=0
                        else buffer[inx,iny]:=1;
                for inx:=1 to max do
                for iny:=1 to max do
                if buffer[inx,iny]=1 then
                  begin
                      mmark(5*inx,5*iny);
                      putpixel(max*6+inx,iny+5,1)
                  end
                else begin
                       unmmark(5*inx,5*iny);
                       putpixel(max*6+inx,iny+5,0)
                     end;
              end;

      'q','Q':goto endprog;
    end;
until endchk;
   rewrite(infile);
   for y:=1 to max do
       for x:=1 to max do
           begin
              write(infile,buffer[x,y]);
              if x=max then writeln(infile)
           end;
   close(infile);
   closegraph;
   writeln('Image saved!!');
   goto jmp3;
endprog:closegraph;
   writeln('Image not saved');
jmp3:
end.