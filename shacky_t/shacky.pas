
{============================================================================}
{                                                                            }
{                                                                            }
{                          SHACKY TALE    V 0.3                              }
{                                                                            }
{                                       by YSC, LAR, KAY                     }
{============================================================================}



program Shackytale ( input,output);

uses mygraph,graph,crt,sounds,mymessage;

label endpoint,first;

const
  hp_uprate=50;        { Hitpoint up rate }
  mytype: fillpatterntype=($7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f);
  exprate = 24;


type
  fillpatterntype=array[1..8] of byte;
  mon_type = record
                who  : char;
                corx : integer;
                cory : integer;
                hits : integer;
             end;
  mon_array=array[1..100] of mon_type;

var
  ch:char;             { Input commands }
  x,y : integer;       { Coordinate of upperleft corner of window }
  inx,iny : integer;   { Iteration index }
  exp,hp : integer;    { Experience and Hitpoint }
  corx,cory : integer;
  monsnum   : integer; { Number of monsters in scroll window }
  monster   : mon_array; { Array to store current monsters }
  killed    : integer; { Number of monsters killed }
  choco_num : integer;
  mes_num   : integer;
  shoes_num : integer;
  gem_num   : integer;

  loops     : integer;
  break     : boolean;
  any_message : boolean;




{=============================================BOOP SOUND====================}
procedure boop;
  begin
    sound(800);
    delay(50);
    nosound;
  end;

{=============================================MOVE SOUND====================}
procedure movesound;
  begin
    sound(340);
    delay(50);
    nosound;
  end;
{=============================================SMASH SOUND===================}
procedure smash;
  var
    count : integer;
  begin
   for count:=1 to 5 do
      begin
         sound(600);
         delay(10);
         nosound;
         sound(500);
         delay(10);
         nosound;
      end;
  end;


{============================================ LOAD ALL FONTS NEEDED ========}
procedure getfonts;

  begin
   loadcharacterfile(0,0,'prince.fon');
   loadcharacterfile(50,0,'princess.fon');
   loadcharacterfile(100,0,'skeleton.fon');
   loadcharacterfile(150,0,'fox.fon');
   loadcharacterfile(200,0,'bat.fon');
   loadcharacterfile(250,0,'mount.fon');
   loadcharacterfile(300,0,'tree.fon');
   loadcharacterfile(350,0,'water.fon');
   loadcharacterfile(400,0,'blank.fon');
   loadcharacterfile(450,0,'anya.fon');
   loadcharacterfile(500,0,'slime.fon');
   loadcharacterfile(0,50,'pr2.fon');
   loadcharacterfile(50,50,'pru.fon');
   loadcharacterfile(100,50,'prd.fon');
   loadcharacterfile(150,50,'choco.fon');
   loadcharacterfile(200,50,'tomb.fon');
   loadcharacterfile(250,50,'shoem.fon');
   loadcharacterfile(300,50,'cave.fon');
   loadcharacterfile(350,50,'vend.fon');
   loadcharacterfile(400,50,'house.fon');
   loadcharacterfile(0,100,'shswd.fon');
   loadcharacterfile(50,100,'lgswd.fon');
   loadcharacterfile(100,100,'saber.fon');
   loadcharacterfile(150,100,'anhome.fon');
   loadcharacterfile(200,100,'shoes.fon');
   loadcharacterfile(250,100,'wall.fon');
   loadcharacterfile(300,100,'gem.fon');
   loadcharacterfile(350,100,'caveend.fon');
   loadcharacterfile(400,100,'smash.fon');
   loadcharacterfile(450,100,'heart.fon');
   loadcharacterfile(500,100,'smack.fon');

   loadcharacterfile(400,150,'map.fon');



   loadimage(1,1,50,50,shakrt_p);
   loadimage(51,1,100,50,prin_p);
   loadimage(101,1,150,50,skel_p);
   loadimage(151,1,200,50,foxy_p);
   loadimage(201,1,250,50,bat_p);
   loadimage(251,1,300,50,mount_p);
   loadimage(301,1,350,50,tree_p);
   loadimage(351,1,400,50,water_p);
   loadimage(401,1,450,50,blank_p);
   loadimage(451,1,500,50,anya_p);
   loadimage(501,1,550,50,slime_p);
   loadimage(1,51,50,100,shaklf_p);
   loadimage(51,51,100,100,shakup_p);
   loadimage(101,51,150,100,shakdn_p);
   loadimage(151,51,200,100,choco_p);
   loadimage(201,51,250,100,tomb_p);
   loadimage(251,51,300,100,shoem_p);
   loadimage(301,51,350,100,cave_p);
   loadimage(351,51,400,100,vend_p);
   loadimage(401,51,450,100,house_p);
   loadimage(1,101,50,148,shswd_p);
   loadimage(51,101,100,148,lgswd_p);
   loadimage(101,101,150,148,saber_p);
   loadimage(151,101,200,150,anhome_p);
   loadimage(201,101,250,150,shoes_p);
   loadimage(251,101,300,150,wall_p);
   loadimage(301,101,350,150,gem_p);
   loadimage(351,101,400,150,caveend_p);
   loadimage(401,101,450,150,smash_p);
   loadimage(451,101,500,150,heart_p);
   loadimage(501,101,550,150,smack_p);

   loadimage(401,151,405,155,b_p);
   loadimage(406,151,410,155,t_p);
   loadimage(411,151,416,155,m_p);
   loadimage(416,151,421,155,w_p);
   loadimage(421,151,426,155,c_p);
   loadimage(426,151,431,155,h_p);
   loadimage(431,151,436,155,v_p);
   loadimage(436,151,440,155,a_p);
   loadimage(441,151,446,155,s_p);
   loadimage(446,151,451,155,wl_p);

 end;


{============================================ PLACESHACKY LOOKING RIGHT ====}
procedure placeRshacky;
  begin
    putimage(30+50*5,20+50*2,shakrt_p^,0);
  end;


{============================================ PLACESHACKY LOOKING LEFT =====}
procedure placeLshacky;
  begin
    putimage(30+50*5,20+50*2,shaklf_p^,0);
  end;


{============================================ PLACESHACKY LOOKING UP =======}
procedure placeUShacky;
  begin
    putimage(30+50*5,20+50*2,shakup_p^,0);
  end;


{============================================ PLACESHACKY LOOKING DOWN =====}
procedure placeDshacky;
  begin
    putimage(30+50*5,20+50*2,shakdn_p^,0);
  end;
{==========================================================================}
procedure check(x1,y1 : integer; var cox, coy : integer);
  begin
    cox := x1 mod 110;
    coy := y1 mod 50;
    if ( x1 <= 0)
       then  cox := cox + 110
       else if ( x1 = 110)
              then cox := 110;
    if (y1 <= 0)
       then coy := coy + 50
       else if ( y1 = 50)
           then coy := 50
   end;


{=========================================== DRAWS MAP upper left's cordn===}
procedure drawmap(x,y:integer);
  var
    xx,yy : integer;
    cox,coy:integer;
    what : char;
  begin
      for yy:=0 to 4 do
       for xx:=0 to 10 do
          begin
             check(xx + x,yy + y,cox,coy);
                 if  (xx<>5) or (yy<>2) then
                 begin
                    what:=map[cox,coy];
                    case what of
                     '0':putimage(30+50*xx, 20+50*yy, blank_p^,0);
                     '1':putimage(30+50*xx, 20+50*yy, tree_p^,0);
                     '2':putimage(30+50*xx, 20+50*yy, mount_p^,0);
                     '3':putimage(30+50*xx, 20+50*yy, water_p^,0);
                     'f':putimage(30+50*xx, 20+50*yy, foxy_p^,0);
                     's':putimage(30+50*xx, 20+50*yy, skel_p^,0);
                     'b':putimage(30+50*xx, 20+50*yy, bat_p^,0);
                     'c':putimage(30+50*xx, 20+50*yy, cave_p^,0);
                     'h':putimage(30+50*xx, 20+50*yy, house_p^,0);
                     'v':putimage(30+50*xx, 20+50*yy, vend_p^,0);
                     'w':putimage(30+50*xx, 20+50*yy, wall_p^,0);
                     'A':putimage(30+50*xx, 20+50*yy, anhome_p^,0);
                     'S':putimage(30+50*xx, 20+50*yy, slime_p^,0);
                     'C':putimage(30+50*xx, 20+50*yy, caveend_p^,0);
                    end;
                 end;
          end;
  end;

{========================================== COORDINATION OF SHACKY =========}
procedure cordshacky(cox,coy:integer);
  var
    sx,sy: string[3];
    outtex:string[9];
  begin
    settextstyle(defaultfont,horizdir,1);
    str(cox,sx);
    str(coy,sy);
    outtex:=concat('(',sx,',',sy,')');
    outtextxy(590,30,outtex);
  end;



{===========================================LEVEL OF MONSTER=============}
function level(what:char) :integer;
  begin
    case what of
         'f': level:=1;
         's': level:=2;
         'b': level:=3;
         'S': level:=4;
    end;
  end;
{===========================================INIT HIT POINT===============}
procedure init_hp(var hit:integer);
  begin
     hit:=200;
     setfillpattern(mytype,1);
     bar(101,281,101+hit,299)
  end;

{===========================================INIT EXPERIENCE==============}
procedure init_exp(var exps:integer);
  begin
     exps:=0;
  end;
{===========================================DECREASE HITPOINT============}
procedure dec_hp(var hit:integer; rate:integer);
  begin
    hit:=hit-rate;
    setfillstyle(solidfill,0);
    bar(hit+101,281,578,299)
  end;

{===========================================INCREASE EXPERIENCE==========}
procedure inc_exp(var exps:integer);

  begin

    exps:=killed*exprate;
    if (exps<=480-exprate) then
       begin
          setfillpattern(mytype,1);
          bar(101,311,exps+100,329);
       end
    else if (exps>480-exprate)  then
       begin
         setfillstyle(solidfill,0);   { experience to 0 }
         bar(101,311,580,329);

         hp:=hp+hp_uprate;
         if (hp<=480) and (hp>=0) then   { increase hitpoint }
            begin
              setfillpattern(mytype,1);
              bar(101,281,hp+100-1,299);
            end
         else if (hp>480) then
              begin
                setfillpattern(mytype,1);
                bar(101,281,580,299);
                hp:=480;
              end;
         exps:=0;
         killed:=0;
       end;
  end;

{=========================================INIT MONSTER ARRAY=============}
procedure init_monsterarray(var mon:mon_array);
  var
    count : integer;
  begin
    for count:= 1 to 30 do
        begin
           mon[count].who:='*';
           mon[count].corx:=0;
           mon[count].cory:=0;
           mon[count].hits:=5;
        end;
  end;

{=========================================APPEAR MONSTERS================}
procedure appear_monster(cox,coy:integer; what:char; var mon:mon_array);
  var
    choice: integer;
    count : integer;
    x_count,y_count: integer;
    tempx,tempy : integer;

  begin
    choice:=random(3);
    case choice of
         0:begin
             tempx:=cox-1;
             tempy:=random(4)+coy;
             if map[tempx,tempy]='0' then
                begin
                  monsnum:=monsnum+1;
                  map[tempx,tempy]:=what;
                  mon[monsnum].who:=what;
                  mon[monsnum].corx:=tempx;
                  mon[monsnum].cory:=tempy;
                  mon[monsnum].hits:=level(what);
                end;
           end;


         1:begin
             tempx:=random(10)+cox;
             tempy:=coy-1;
             if map[tempx,tempy]='0' then
                begin
                  monsnum:=monsnum+1;
                  map[tempx,tempy]:=what;
                  mon[monsnum].who:=what;
                  mon[monsnum].corx:=tempx;
                  mon[monsnum].cory:=tempy;
                  mon[monsnum].hits:=level(what);
                end;
           end;
         2:begin
             tempx:=cox+10;
             tempy:=random(4)+coy;
             if map[tempx,tempy]='0' then
                begin
                  monsnum:=monsnum+1;
                  map[tempx,tempy]:=what;
                  mon[monsnum].who:=what;
                  mon[monsnum].corx:=tempx;
                  mon[monsnum].cory:=tempy;
                  mon[monsnum].hits:=level(what);
                end;
           end;
         3:begin
             tempx:=random(10)+cox;
             tempy:=coy+4;
             if map[tempx,tempy]='0' then
                begin
                  monsnum:=monsnum+1;
                  map[tempx,tempy]:=what;
                  mon[monsnum].who:=what;
                  mon[monsnum].corx:=tempx;
                  mon[monsnum].cory:=tempy;
                  mon[monsnum].hits:=level(what);
                end;
           end;
     end; {case}




  end;
{=========================================MOVE MONSTERS IN ARRAY=========}
procedure movemonster(var mon:mon_array);

  var
    cur_m      : char;
    sha_x,sha_y: integer;  { shacky's current coodination   }
    cur_x,cur_y: integer;  { monster's current coordination }
    mov_x,mov_y: integer;  { monster's next coordination }
    dif_x,dif_y: integer;  { difference }
    count      : integer;

  begin
    sha_x:=x+5;
    sha_y:=y+2;
    for count:=1 to monsnum do
        begin
          cur_m:=mon[count].who;
          cur_x:=mon[count].corx;
          cur_y:=mon[count].cory;
          dif_x:=sha_x - cur_x;
          dif_y:=sha_y - cur_y;


          if dif_x>0 then mov_x:=cur_x+1
          else if dif_x<0 then mov_x:=cur_x-1
          else mov_x:=cur_x;

          if dif_y>0 then mov_y:=cur_y+1
          else if dif_y<0 then mov_y:=cur_y-1
          else mov_y:=cur_y;
          if not ((mov_x=sha_x) and (mov_y=sha_y))
          then
          if (map[mov_x,mov_y]='0') then
             begin
               map[mov_x,mov_y]:=cur_m;
               mon[count].corx:=mov_x;
               mon[count].cory:=mov_y;
               map[cur_x,cur_y]:='0';
             end
          else if map[mov_x,cur_y]='0' then
             begin
               map[mov_x,cur_y]:=cur_m;
               mon[count].corx:=mov_x;
               mon[count].cory:=cur_y;
               map[cur_x,cur_y]:='0';
             end
          else if map[cur_x,mov_y]='0' then
             begin
               map[cur_x,mov_y]:=cur_m;
               mon[count].corx:=cur_x;
               mon[count].cory:=mov_y;
               map[cur_x,cur_y]:='0';
             end
       end; { of for loop }
       drawmap(x,y);
  end;
{=============================================MONSTER'S ATTACK===========}
procedure mon_attack(m_num:integer);
  begin
    break:=false;
    if (abs(monster[m_num].corx-(x+5))<=1) and
       (abs(monster[m_num].cory-(y+2))<=1)
    then begin
           dec_hp(hp,1);
           if (hp<=0) then break:=true;
           boop;
           putimage(30*50*5,20+50*2,blank_p^,0);
           putimage(30+50*5,20+50*2,smack_p^,0);
           delay(50);
           putimage(280,120,blank_p^,0);
         end;
  end;
{=============================================SHACKY'S ATTACK============}
procedure shacky_attack(direction:char);
  var
    count : integer;
    sha_x,sha_y : integer;
    mo_no : integer;
  begin
    sha_x:=x+5;
    sha_y:=y+2;
    mo_no:=10000;
    smash;
     case direction of
        'n':begin
              for count:=1 to monsnum do
                  begin
                    if (monster[count].corx=sha_x)
                       and (monster[count].cory=sha_y-1)
                    then
                         begin
                           mo_no:=count;
                           putimage(30+50*5,20+50*1,smash_p^,0);
                         end;
                  end;
            end;
        'w':begin
              for count:=1 to monsnum do
                  begin
                    if (monster[count].corx=sha_x-1)
                       and (monster[count].cory=sha_y)
                    then
                         begin
                           mo_no:=count;
                           putimage(30+50*4,20+50*2,smash_p^,0);
                         end;
                  end;
            end;
        'e':begin
              for count:=1 to monsnum do
                  begin
                    if (monster[count].corx=sha_x+1)
                       and (monster[count].cory=sha_y)
                    then

                         begin
                           mo_no:=count;
                           putimage(30+50*6,20+50*2,smash_p^,0);
                         end;
                  end;
            end;
        's':begin
              for count:=1 to monsnum do
                  begin
                    if (monster[count].corx=sha_x)
                       and (monster[count].cory=sha_y+1)
                    then
                         begin
                           mo_no:=count;
                           putimage(30+50*5,20+50*3,smash_p^,0);
                         end;
                  end;
            end;
    end;{ of case }

    if  mo_no<>10000 then
        begin
          monster[mo_no].hits := monster[mo_no].hits - 1 ;
          if monster[mo_no].hits=0 then
             begin
                if mo_no<>monsnum then
                   begin
                     map[monster[mo_no].corx,monster[mo_no].cory]:='0';
                     monster[mo_no].who:=monster[monsnum].who;
                     monster[mo_no].corx:=monster[monsnum].corx;
                     monster[mo_no].cory:=monster[monsnum].cory;
                     monster[mo_no].hits:=monster[monsnum].hits;
                     monsnum:=monsnum-1;
                     killed:=killed+1;
                   end
                else if (mo_no=monsnum) then
                        begin
                           map[monster[mo_no].corx,monster[mo_no].cory]:='0';
                           monsnum:=monsnum-1;
                           killed:=killed+1;
                         end;
             end;
        end;

    drawmap(x,y);



  end;

{=========================================CLEAR MES_WINDOW===============}
procedure clearmeswin;
  begin
     setfillstyle(solidfill,0);
     bar(591,71,709,269);
     settextstyle(defaultfont,0,1);
     outtextxy(600,72,'  MESSAGES');
  end;

{=========================================CHECK MESSAGE==================}
procedure check_message(cox,coy:integer);
  begin
     any_message:=false;
     if (cox=13) and (coy=6)
        then begin
                mes_num:=1;  {cave}
                choco_num:=1;
                any_message:=true;
                putimage(655,280,choco_p^,0);
             end;
     if (cox=17) and (coy=41)
        then begin
                mes_num:=0;  {tomb}
                any_message:=true;
             end;
     if (cox=96) and (coy=43)
        then begin
                any_message:=true;
                case choco_num of
                     0: mes_num:=2;  {anya}
                     1: begin
                           mes_num:=3;
                           setfillstyle(solidfill,0);
                           bar(655,280,704,329);
                           gem_num:=1;
                           putimage(655,280,gem_p^,0);
                        end;
                end;
             end;
     if (cox=89) and (coy=8)
        then begin                     {shoes}
                any_message:=true;
                if gem_num=1 then
                   begin
                      mes_num:=5;
                      shoes_num:=1;
                      putimage(655,280,shoes_p^,0);
                   end
                else
                   mes_num:=4;
             end;
     if (cox=102) and (coy=29)
        then  begin
                any_message:=true;
                mes_num:=6;
                putimage(590,280,saber_p^,0);
              end;
  end;

{=============================================NOT NEAR===================}
function notnear : boolean;
   var
     count : integer;
   begin
   for count := 1 to monsnum do
       begin
         if  (abs(monster[count].corx-x+5) + abs(monster[count].cory-y+2))
             >13
         then notnear:=true
         else notnear:=false;
       end;
   end;

{===============================================VIEW MAP=================}
procedure viewmap;

var
    x_count,y_count : integer;

begin
    for y_count:=1 to 50 do
        for x_count:=1 to 110 do
            case map[x_count,y_count] of
               '0','f','b','s','S'
                  :putimage(30+(x_count-1)*5,20+(y_count-1)*5,b_p^,0);
               '1':putimage(30+(x_count-1)*5,20+(y_count-1)*5,t_p^,0);
               '2':putimage(30+(x_count-1)*5,20+(y_count-1)*5,m_p^,0);
               '3':putimage(30+(x_count-1)*5,20+(y_count-1)*5,w_p^,0);
               'c','C'
                  :putimage(30+(x_count-1)*5,20+(y_count-1)*5,c_p^,0);
               'h':putimage(30+(x_count-1)*5,20+(y_count-1)*5,h_p^,0);
               'v':putimage(30+(x_count-1)*5,20+(y_count-1)*5,v_p^,0);
               'A':putimage(30+(x_count-1)*5,20+(y_count-1)*5,a_p^,0);
               'w':putimage(30+(x_count-1)*5,20+(y_count-1)*5,b_p^,0);
             end;
     setfillstyle(solidfill,1);
     bar(590,71,709,269);
     setcolor(0);
     settextstyle(gothicfont,horizdir,3);
     outtextxy(595,90,'The MAP');
     putimage(595,125,t_p^,0);
     putimage(595,135,m_p^,0);
     putimage(595,145,w_p^,0);
     putimage(595,155,c_p^,0);
     putimage(595,165,h_p^,0);
     putimage(595,175,v_p^,0);
     putimage(595,185,a_p^,0);

     settextstyle(defaultfont,horizdir,0);
     outtextxy(604,125,':forest');
     outtextxy(604,135,':mountain');
     outtextxy(604,145,':river');
     outtextxy(604,155,':cave');
     outtextxy(604,165,':grave');
     outtextxy(604,175,':shop');
     outtextxy(604,185,':anya''s house');
     outtextxy(604,195,':shacky');
     settextstyle(gothicfont,horizdir,2);
     outtextxy(430,205,'MAZE');
     setcolor(1);
     line(600,125,600,200);

     repeat
       delay(50);
       putimage(30+(x+4)*5,20+(y+1)*5,b_p^,xorput);
       putimage(595,195,b_p^,xorput);

     until keypressed;
     clearmeswin;
     placeLshacky;
     drawmap(x,y);
     setcolor(1);
     line(580,19,580,270);
 end;


{========================================================================}
{                                    MAIN PROGRAM                        }
{========================================================================}
begin

first:
  initgr;

  break:=false;
  setvisualpage(0);
  setactivepage(0);

  setfillstyle(solidfill,1);
  bar(0,0,719,347);

  setfillstyle(solidfill,0);
  bar(38-10+5,13+5,602-10+5,92+5);


  settextstyle(gothicfont,horizdir,5);
  setfillstyle(solidfill,1);
  bar(40+5,15,600+5,90);

  setcolor(0);
  rectangle(39+5,14,601+5,91);


  setcolor(0);
  outtextxy(60+5,30,'Shacky Tale');
  setcolor(1);
  settextstyle(defaultfont,0,1);
  setcolor(0);
  outtextxy(50,310,'PATIENCE! Please Wait a moment.. loading characters');
  setactivepage(1);
  getfonts;
  setactivepage(0);


  putimage(380-120-70,200,prin_p^,0);
  putimage(470-120,200,shaklf_p^,0);

    for loops:=100 downto  1 do
      begin
         delay(13);
         putimage(380-120+5,100+loops,heart_p^,0);
      end;

  for loops:=1 to 669 do
      begin
         if loops=315 then putimage(380-120+5,101,smash_p^,0)
         else  putimage(loops,101,bat_p^,0);
      end;

  for loops:=1 to 100 do
      begin
         putimage(380-120+5,100+loops,smash_p^,0);
      end;
  putimage(380-120+5,200,blank_p^,0);
  for loops:=350 to 669 do
      begin
        putimage(loops,200,shakrt_p^,0);
        setcolor(1);
        line(loops-1,200,loops-1,250);
      end;

  putimage(669,200,shakup_p^,0);

  repeat
   for loops:=200 downto 170 do
       begin
         putimage(669,loops,shakup_p^,0);
         line(669,loops+1+50,719,loops+1+50);
         delay(3);
       end;
   for loops:=170 to 200 do
       begin
         putimage(669,loops,shakup_p^,0);
         line(669,loops-1,719,loops-1);
         delay(3);
       end;
  setcolor(0);
  outtextxy(50,325,' press any key to go on.......  ');
  setcolor(1);
  until keypressed;


  setcolor(0);
  ch:=readkey;
        setactivepage(1);
        setfillstyle(solidfill,1);
        bar(0,0,719,347);

        setfillstyle(solidfill,1);
        bar(10,10,709,337);
        settextstyle(gothicfont,0,5);
        setcolor(0);
        outtextxy(100,30,'Characters');
        rectangle(35,30,714-50,80);

        settextstyle(defaultfont,0,1);
        putimage(90,90,prin_p^,0);
        outtextxy(150,120,'princess ');
        putimage(300,90,shaklf_p^,0);
        outtextxy(360,120,'shacky');

        outtextxy(160-70,190-20,'MONSTERS');
        putimage(160-70,200-20,skel_p^,0);
        putimage(210-70,200-20,foxy_p^,0);
        putimage(260-70,200-20,bat_p^,0);
        putimage(310-70,200-20,slime_p^,0);

        outtextxy(160-70,290-10-20,'OTHERS');
        putimage(90,290-10,anya_p^,0);
        putimage(90+50,290-10,tomb_p^,0);
        putimage(90+100,290-10,shoem_p^,0);
        outtextxy(300,300,'        press any key to start game');
        setvisualpage(1);
        repeat until keypressed;

  cleardevice;
  setactivepage(0);
  setvisualpage(0);
  setcolor(1);


  frames;
  putimage(590,280,lgswd_p^,0);
  init_hp(hp);
  init_exp(exp);
  readmap('map2.map');


  init_monsterarray(monster);
  x:=15;y:=40;
  killed:=0;
  choco_num:=0;
  shoes_num:=0;
  gem_num:=0;
  monsnum:=0;
  mes_num:=0;
  drawmap(x,y);
  placeRshacky;


  repeat {============================= repeat whole routine ========}


  if keypressed then  {================ if 'command' is given =======}
       begin

          ch:=readkey;
          case ch of
      {up}     '8':begin

                    check(x+5,y+2-1,corx,cory);
                    if (map[corx,cory]='0') or
                       ((map[corx,cory]='3') and (shoes_num=1))
                       or (map[corx,cory]='C')
                       or (map[corx,cory]='h')
                       or (map[corx,cory]='c')
                       or (map[corx,cory]='A')
                       or (map[corx,cory]='s')
                    then
                      begin
                       check(x,y-1,corx,cory);
                       y:=cory
                      end;

                    placeUshacky;
                    drawmap(x,y);

                  end;
      {left}  '4':begin
                    check(x-1+5,y+2,corx,cory);
                    if (map[corx,cory]='0') or
                       ((map[corx,cory]='3') and (shoes_num=1))
                       or (map[corx,cory]='C')
                       or (map[corx,cory]='h')
                       or (map[corx,cory]='c')
                       or (map[corx,cory]='A')
                       or (map[corx,cory]='v')
                    then
                      begin
                        check(x-1,y,corx,cory);
                        x:=corx
                      end;
                    placeLshacky;
                    drawmap(x,y);

                  end;
      {right} '6':begin
                    check(x+1+5,y+2,corx,cory);
                    if (map[corx,cory]='0') or
                       ((map[corx,cory]='3') and (shoes_num=1))
                       or (map[corx,cory]='C')
                       or (map[corx,cory]='h')
                       or (map[corx,cory]='c')
                       or (map[corx,cory]='A')
                       or (map[corx,cory]='v')
                    then
                      begin
                        check(x+1,y,corx,cory);
                        x:=corx
                      end;
                    placeRshacky;
                    drawmap(x,y);
                 end;

      {down}  '2':begin
                    check(x+5,y+1+2,corx,cory);
                    if (map[corx,cory]='0') or
                       ((map[corx,cory]='3') and (shoes_num=1))
                       or (map[corx,cory]='C')
                       or (map[corx,cory]='h')
                       or (map[corx,cory]='c')
                       or (map[corx,cory]='A')
                       or (map[corx,cory]='v')
                    then
                      begin
                        check(x,y+1,corx,cory);
                        y:=cory
                      end;
                    placeDshacky;
                    drawmap(x,y);

                  end;
      {attack}'a',' ':begin
                     ch:=readkey;
                     case  ch of
                     '8': begin
                             placeUshacky;
                             shacky_attack('n');
                          end;
                     '4': begin
                             placeLshacky;
                             shacky_attack('w');
                          end;
                     '2': begin
                            placeDshacky;
                            shacky_attack('s');
                          end;
                     '6': begin
                            placeRshacky;
                            shacky_attack('e');
                          end;
                       end;{case}
                       inc_exp(exp);
                     end;

{map}         'M','m':begin
                    viewmap;
                  end;


          end;{of case}

          check_message(x+5,y+2);
          if any_message then
             begin
                clearmeswin;
                talk(mes_num);
                case mes_num of
                    0:music('TOMB.SD');{tomb}
                    1:music('stin.sd');{choco}
                    2,3:music('ANYA.SD');{anya}
                    4:music('STIN.SD');{shoes}
                    5:music('stin.sd');
                    6:music('sayo2.sd');
                END;
                clearmeswin;
                if mes_num=6 then goto endpoint;
                any_message:=false;

             end;
        movesound;
      end{of if}

   else {============== when no command.. delay a moment and move enemy=}
      begin
        if ((monsnum<6) or notnear) and (monsnum<100) then
           begin
            appear_monster(x,y,'f',monster);
            appear_monster(x,y,'s',monster);
            appear_monster(x,y,'b',monster);
            appear_monster(x,y,'S',monster);
           end;
        if (monsnum>0) then
           begin
             movemonster(monster);
             for loops:=1 to monsnum do
                 begin
                   if break then goto endpoint;
                   mon_attack(loops);
                 end;
           end;
      end;

  any_message:=false;
  until (ch=chr(27)) or break;{=========================== end session when ESC ===}
endpoint:

  delay(50);
  cleardevice;
  if (hp=0) then
             begin
               setfillstyle(solidfill,1);
               rectangle(238,108,502,202);
               bar(240,110,500,200);
               putimage(240+10,110+10,house_p^,0);
               putimage(240+10+50,110+10,tomb_p^,0);
               settextstyle(gothicfont,horizdir,3);
               outtextxy(230,70,'You are DEAD!');
               setcolor(0);
               settextstyle(3,horizdir,1);
               outtextxy(240+61+55,130,'Rest In Peace..');
               outtextxy(240+61+55,150,'May GOD bless you.');
             end;

  if (mes_num=6) then
             begin
               ch:=readkey;
               setfillstyle(solidfill,1);
               rectangle(238,108,502,202);
               bar(240,110,500,200);
               putimage(240+10,110+10,prin_p^,0);
               putimage(240+10+50,110+10,heart_p^,0);
               settextstyle(gothicfont,horizdir,3);
               outtextxy(230,70,'CONGRATULATIONS!');
               setcolor(0);
               settextstyle(3,horizdir,1);
               outtextxy(240+61+55,130,' Thank you....');
               outtextxy(240+61+55,150,' smack! smack!');
             end;
  setcolor(1);
  settextstyle(3,horizdir,1);
  outtextxy(240,300,'Do you wish to play again(y/n)?');
  music('sayo.sd');
  ch:=readkey;
  if (ch<>'N') and (ch<>'n')
     then begin
             closegraph;
             goto first;
         end;

  closegraph;
  writeln('***********************************************');
  writeln('*    Thanks ! PLAY AGAIN                      *');
  writeln('*       next stages are still not completed   *');
  writeln('*                    -sorry-                  *');
  writeln('***********************************************');
  writeln;
  writeln(                'press anykey to return to DOS');
  writeln;
  writeln('      Type->   ''Shacky''  to play again');
  repeat until keypressed;

end.







