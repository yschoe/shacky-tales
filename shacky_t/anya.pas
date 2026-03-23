program aaa ( input,output);
uses graph,crt,mygraph;
var
  flag : boolean;
  grdriver,grmode : integer;

procedure talk(mess_flag : boolean;pick : integer);

   begin
     case pick of
       0:begin
{          putimage(600,90,anya_p^ ,0);}
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
{          putimage(600,90,anya_p^ ,0);}
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

       2:begin
{          putimage(600,90,anya_p^ ,0);}
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

       3:begin
{          putimage(600,90,anya_p^ ,0);}
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
                   end;;

       4:begin
{          putimage(600,90,anya_p^ ,0);}
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
                   end;;
     end;


   end;


begin
   initgr;
   frames;
   flag:=true;
   talk(flag,0);
   repeat until keypressed;
   closegraph;
end.




