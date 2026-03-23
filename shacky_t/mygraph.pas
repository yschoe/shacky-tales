UNIT mygraph;

INTERFACE
uses graph,crt;

const
  xmax=110;
  ymax=50;
  up=8;
  down=2;
  left=4;
  right=6;

var
  map: array[1..xmax,1..ymax] of char;

  shakrt_p: pointer;
  shaklf_p: pointer;
  shakup_p: pointer;
  shakdn_p: pointer;

  prin_p : pointer;
  pr2_p  : pointer;
  foxy_p : pointer;
  skel_p : pointer;
  bat_p  : pointer;
  slime_p: pointer;
  alf_p  : pointer;
  alien_p: pointer;
  anya_p : pointer;
  anhome_p:pointer;

  choco_p: pointer;
  gem_p  : pointer;
  shswd_p: pointer;
  lgswd_p: pointer;
  saber_p: pointer;

  mount_p: pointer;
  tree_p : pointer;
  water_p: pointer;
  cave_p : pointer;
  caveend_p:pointer;
  vend_p : pointer;
  wall_p : pointer;
  house_p: pointer;

  blank_p: pointer;
  rock_p : pointer;
  tomb_p : pointer;
  shoem_p : pointer;
  shoes_p: pointer;

  smash_p: pointer;
  heart_p:pointer;
  smack_p:pointer;

  b_p,t_p,m_p,w_p,s_p,wl_p,
  c_p,h_p,v_p,a_p: pointer;

procedure initgr;
procedure frames;
procedure loadimage(x1,y1,x2,y2: integer; var p : pointer);
procedure loadcharacterfile(x1,y1:integer;name:string);
procedure readmap(name:string);

IMPLEMENTATION
{============================================== INITGRAPH ===========}
procedure initgr;
  var
    grdriver,grmode : integer;
  begin
    grdriver:=detect;
    initgraph(grdriver,grmode,'');
  end;


{==============================================DRAW FRAMES ==========}
procedure frames;
  begin
    rectangle(0,0,719,347);
    rectangle(29,19,580,270);
    rectangle(100,280,581,300);
    rectangle(100,310,581,330);
    rectangle(590,70,710,270);
    rectangle(589,279,641,331);
    rectangle(654,279,705,330);
    settextstyle(defaultfont,0,2);
    outtextxy(30,280,'H.P.');
    outtextxy(30,310,'EXP.');
    settextstyle(defaultfont,0,1);
    outtextxy(600,72,'  MESSAGES');
    settextstyle(defaultfont,0,1);
    outtextxy(592,272,'WEAPON');
    outtextxy(655,272,' ITEMS');
    settextstyle(gothicfont,horizdir,4);
    outtextxy(600,2,'Shacky');
    settextstyle(gothicfont,horizdir,6);
    outtextxy(600,20,'Tale ');
  end;

{==============================================GET IMAGE=============}
procedure loadimage;
  var
    size : word;
  begin
    size:=imagesize(x1,y1,x2,y2);
    getmem(p,size);
    getimage(x1,y1,x2,y2,p^);
  end;


{=========================================LOAD CHARACTER FILE========}
procedure loadcharacterfile;
var
  buffile:text;
  ch: char;
  x,y : integer;

 begin
    assign(buffile,name);
    reset(buffile);
    for y:=y1+1 to y1+50 do
        for x:=x1+1 to x1+50 do
            begin
               read(buffile,ch);
               if ch='1' then
                  putpixel(x,y,1);
               if x=x1+50 then readln(buffile);
            end;
    close(buffile);

 end;

{=========================================READ MAP FROM FILE ========}
procedure readmap;
 var
   x,y : integer;
   ch : char;

   infile : text;
 begin
   assign(infile,name);
   reset(infile);
   for y:=1 to ymax do
       for x:=1 to xmax do
          begin
             read(infile,ch);
             map[x,y]:=ch;
             if x=xmax then readln(infile);
          end;
 end;

{================================================SCROLL SCREEN=======}
END.{OF UNIT}