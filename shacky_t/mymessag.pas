unit mymessage;

interface
uses graph,crt,mygraph;
  procedure talk(pick : integer);

implementation

procedure talk;
begin
     case pick of
       0:begin
          putimage(600,100,tomb_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'The');
          outtextXY(660,110,'old');
          outtextXY(660,120,'grave');
          outtextXY(660,130,'watch');
          outtextXY(660,140,'man');
          outtextXY(660,150,'says:');
          outtextXY(595,160,'Please save us ');
          outtextXY(595,170,'from the fire-');
          outtextXY(595,180,'breath dragon.');
          outtextXY(595,190,'Goto wizardess');
          outtextXY(595,200,'Anya for help.');
          outtextXY(595,210,'Before you go');
          outtextXY(595,220,'you must..zzz.');
          outtextXY(595,240,'HE FELL ASLEEP');
          outtextXY(595,250,'BEFORE HE GAVE');
          outtextXY(595,260,'YOU THE CLUE!');
                   end;
       1:begin
          putimage(600,100,choco_p^ ,0);
          settextstyle(0,0,1);
          {outtextXY(660,100,'
          outtextXY(660,110,
          outtextXY(660,120,
          outtextXY(660,130,'
          outtextXY(660,140,'
          outtextXY(660,150,'}
          outtextXY(595,160,'Look! You have');
          outtextXY(595,170,'discovered');
          outtextXY(595,180,'something.');
          outtextXY(595,190,'Get a closer ');
          outtextXY(595,200,'look.');
          outtextXY(595,210,'You see it');
          outtextXY(595,220,'is a chocolate');
          outtextXY(595,230,'and put it in');
          outtextXY(595,240,'your pocket.');
          outtextXY(595,250,'" YUMMY " ');
                   end;

       2:begin
          putimage(600,100,anya_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'I know');
          outtextXY(660,110,'that');
          outtextXY(660,120,'you''ve');
          outtextXY(660,130,'come');
          outtextXY(660,140,'to ask');
          outtextXY(660,150,'help.');
          outtextXY(600,160,'But I won''t');
          outtextXY(600,170,'speak ,since');
          outtextXY(600,180,'you haven''t');
          outtextXY(600,190,'brought me a');
          outtextXY(600,200,'chocolate.');
          outtextXY(600,210,'So get me one');
          outtextXY(600,220,'and only then');
          outtextXY(600,230,'shall I give ');
          outtextXY(600,240,'you the infor-');
          outtextXY(600,250,'mation that');
          outtextXY(600,260,'you need.');
                   end;

       3:begin
          putimage(600,100,anya_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'Ah!');
          outtextXY(660,110,'Good!');
          outtextXY(660,120,'I see');
          outtextXY(660,130,'you''ve');
          outtextXY(660,140,'gotten');
          outtextXY(660,150,'it.');
          outtextXY(595,160,'Now,take this');
          outtextXY(595,170,'jewel and');
          outtextXY(595,180,'buy a pair of');
          outtextXY(595,190,'magic shoes.');
          outtextXY(595,200,'Use them to');
          outtextXY(595,210,'get into the');
          outtextXY(595,220,'cave.');
          outtextXY(595,230,'Now give me');
          outtextXY(595,240,'the chocolate.');
          outtextXY(595,250,'By the way ...');
          outtextXY(595,260,'GOOD LUCK !');
                   end;

       4:begin
          putimage(600,100,shoem_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'You');
          outtextXY(660,110,'must');
          outtextXY(660,120,'have');
          outtextXY(660,130,'Anya''s');
          outtextXY(660,140,'jewel');
          outtextXY(660,150,'with ');
          outtextXY(595,160,'you to buy one');
          outtextXY(595,170,'of my shoes.');
          outtextXY(595,180,'So come back');
          outtextXY(595,190,'later when you');
          outtextXY(595,200,'have the');
          outtextXY(595,210,'jewel with you.');
          outtextXY(595,220,'Okay ?');
                   end;

       5:begin
          putimage(600,100,shoem_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'SO!');
          outtextXY(660,110,'You''re');
          outtextXY(660,120,'back.');
          outtextXY(660,130,'again.');
          outtextXY(660,140,'I see');
          outtextXY(660,150,'you''ve');
          outtextXY(595,160,'got the jewel');
          outtextXY(595,170,'I asked for.');
          outtextXY(595,180,'I''ll give you');
          outtextXY(595,190,'winged shoes.');
          outtextXY(595,200,'Well, here you ');
          outtextXY(595,210,'are.Beware of');
          outtextXY(595,220,'creatures in');
          outtextXY(595,230,'the cave.');
          outtextXY(595,240,'GOODBYE.');
                   end;
       6:begin
          putimage(600,100,prin_p^ ,0);
          settextstyle(0,0,1);
          outtextXY(660,100,'Well,');
          outtextXY(660,110,'You''re');
          outtextXY(660,120,'here ');
          outtextXY(660,130,' at');
          outtextXY(660,140,'last.');
          outtextXY(660,150,'');
          outtextXY(595,160,'Now, in the');
          outtextXY(595,170,'cave, find');
          outtextXY(595,180,'ULTIMARR');
          outtextXY(595,190,'and find out');
          outtextXY(595,200,'the way to ');
          outtextXY(595,210,'DARR.');
          outtextXY(595,220,'');
          outtextXY(595,230,'end of ');
          outtextXY(595,240,' STAGE 1');
                   end;
     end;{case}
end;
end.



