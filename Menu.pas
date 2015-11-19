unit Menu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls;

type
  TMenuForm = class(TForm)
    Code: TMemo;
    Label1: TLabel;
    LoadButton: TButton;
    ChapinButton: TButton;
    ResultButton: TButton;
    LoadDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Codc: TMemo;
    procedure LoadButtonClick(Sender: TObject);
    procedure ResultButtonClick(Sender: TObject);
    procedure ChapinButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MenuForm: TMenuForm;

implementation

uses Results, MetricChapin, RegExpr;

{$R *.dfm}

procedure TMenuForm.LoadButtonClick(Sender: TObject);
type bool = record
       bool: boolean;
       typeof: char;
     end;
var i,j:integer;
    polystr:bool;
    str:string;
const LettersVars=['a'..'z','A'..'Z','_'];

    function DelStrAndCom(str:string;var polystr:bool):string;
    var strpos:integer;
        expr:TRegExpr;

          procedure StringPerformance(quotes: char);
          begin
            if expr.MatchLen[0]=3
              then             // многострочная строка
                begin
                  expr.Expression:=quotes+quotes+quotes;
                  polystr.bool:=true;
                  polystr.typeof:=quotes;
                  strpos:=expr.MatchPos[0];

                  repeat
                    if not(expr.ExecNext) then break;
                  until (expr.MatchPos[0]-strpos>=3) and (str[expr.MatchPos[0]-1]<>'\');

                  if expr.MatchPos[0]>0 then
                  begin
                    Delete(str,strpos+1,expr.MatchPos[0]-strpos+1);
                    polystr.bool:=false;
                  end
                  else
                    Delete(str,strpos+1,255)
                end
              else          //однострочная
                begin
                  expr.Expression:=quotes;
                  strpos:=expr.MatchPos[0];
                  while expr.ExecNext do
                    if str[expr.MatchPos[0]-1]<>'\' then break;
                  Delete(str,strpos+1,expr.MatchPos[0]-strpos-1);
                end;
          end;

    begin
    if polystr.bool then     //если у нас идёт многострочная строка, ищем в какой строке она заканчивается
    begin
      expr:=TRegExpr.Create;
      if polystr.typeof='"'
        then expr.Expression:='"""'
        else expr.Expression:='''''''';
      if expr.Exec(str) then
      begin
        Delete(str,1,expr.MatchPos[0]+1);
        polystr.bool:=false;
      end
      else str:='';
    end
    else       //если такой не замечено и у нас идёт именно код
    begin
        expr:=TRegExpr.Create;
        expr.Expression:='=|"""|''''''|''|"|#';
        strpos:=0;
        if expr.Exec(str) then  //смотрим что мы нашли
          Case expr.Match[0][1] of
          '#' :             //комментарий
              begin
                Delete(str,expr.MatchPos[0],255);
                strpos:=length(str);
              end;
          '"' :             //строка в ""
              StringPerformance('"');
          '''':            //строка в ''
              StringPerformance('''');
          '=' :
              begin
                if (str[expr.MatchPos[0]]='=') and (str[expr.MatchPos[0]-1] in LettersVars)
                  then Insert(' ',str,expr.MatchPos[0]);
                if (str[expr.MatchPos[0]]='=') and (str[expr.MatchPos[0]+1] in LettersVars)
                  then Insert(' ',str,expr.MatchPos[0]+1);
              end;
          end;
        end;
      if (strpos+1<length(str)) and (strpos<>0) then
        str:=Copy(str,1,strpos+1)+DelStrAndCom(Copy(str,strpos+2,255),polystr);
      result:=str;
    end;

begin
If LoadDialog.Execute
  then
  begin
    Code.Lines.LoadFromFile(LoadDialog.FileName);
    Codc.Lines.LoadFromFile(LoadDialog.FileName);
    ChapinButton.Enabled:=True;
    ResultButton.Enabled:=False;
    polystr.bool:=false;
    i:=0;
    while i<=Code.Lines.Count-1 do
    begin
      if Trim(Code.Lines.Strings[i])='' then
        Code.Lines.Delete(i)
      else
        inc(i);
    end;
    i:=0;
    while i<=Code.Lines.Count-1 do
    begin
      str:=' '+Code.Lines.Strings[i];
      if polystr.bool
      then
        begin
          Code.Lines.Delete(i);
          Code.Lines.Strings[i-1]:=Code.Lines.Strings[i-1]+DelStrAndCom(str,polystr);
          if not(polystr.bool) then Code.Lines.Strings[i-1]:=Code.Lines.Strings[i-1]+' ';
        end
      else
        begin
          Code.Lines.Strings[i]:=DelStrAndCom(str,polystr)+' ';
          inc(i);
        end;
    end;
    i:=0;
    while i<=Code.Lines.Count-1 do
    begin
      if (Pos(' if ',Code.Lines.Strings[i])<>0) or
         (Pos(' elif ',Code.Lines.Strings[i])<>0) or
         (Pos(' while ',Code.Lines.Strings[i])<>0) or
         (Pos(' else:',Code.Lines.Strings[i])<>0)
      then
        if (Pos(':',Code.Lines.Strings[i])=0)
        then
        begin
          Code.Lines.Strings[i]:=Code.Lines.Strings[i]+Trim(Code.Lines.Strings[i+1])+' ';
          Code.Lines.Delete(i+1);
        end
        else
        begin
          if Pos(':',Code.Lines.Strings[i])<>length(Code.Lines.Strings[i])-1 then Code.Lines.Insert(i+1,Copy(Code.Lines.Strings[i],Pos(':',Code.Lines.Strings[i])+1,255));
          Code.Lines.Strings[i]:=Copy(Code.Lines.Strings[i],1,Pos(':',Code.Lines.Strings[i]));
          inc(i);
        end
      else inc(i);
    end;
    i:=0;
    while i<=Code.Lines.Count-1 do
    begin
      j:=0;
      str:=Code.Lines.Strings[i];
      while j<length(Code.Lines.Strings[i]) do
      begin
        if (str[j]='=') and (str[j-1] in LettersVars)
        then
        begin
          Insert(' ',str,j);
          inc(j);
        end;

        if (str[j]='=') and (str[j-1] in LettersVars)
        then
        begin
          Insert(' ',str,j+1);
          inc(j);
        end;
        inc(j);
      end;
      Code.Lines.Strings[i]:=str;
      inc(i);
    end;
  end;
end;

procedure TMenuForm.ResultButtonClick(Sender: TObject);
begin
ResultForm.Visible:=true;
end;

procedure TMenuForm.ChapinButtonClick(Sender: TObject);
var i,j:integer;
    result: real;
    p,VarList:List;

 function DefineSpaces(line:string):integer;
  var i:integer;
  begin
    i:=0;
    While line[i+1]=' ' do inc(i);
    result:=i;
  end;

  procedure AnalyseCode(procname:string; const posBegin,posEnd:integer);
  var groupStr: array [0..3] of string;
      i,spacenum,lines:integer;
      result: real;
      p,VarList:List;
      defname:string;
  begin
    VarList:=nil;
    groupStr[0]:='группа P: ';
    groupStr[1]:='группа M: ';
    groupStr[2]:='группа C: ';
    groupStr[3]:='группа T: ';

    i:=posBegin;
    if procname<>'main' then TakeVars(VarList,Code.Lines.Strings[i-1]);
    While i<=posEnd do
    begin
      if Pos(' def ',Code.Lines.Strings[i])<>0 then
        begin
          inc(i);
          lines:=0;
          spacenum:=DefineSpaces(Code.Lines.Strings[i]);
          while (DefineSpaces(Code.Lines.Strings[i+lines])>=spacenum) and (i<posEnd) do inc(lines);
          defname:=Copy(Code.Lines.Strings[i-1],Pos(' def ',Code.Lines.Strings[i-1])+5,Pos('(',Code.Lines.Strings[i-1])-Pos(' def ',Code.Lines.Strings[i-1])-5);
          AnalyseCode(defname,i,i+lines-1);
          i:=i+lines;
          continue;
        end;
      TakeVars(VarList,Code.Lines.Strings[i]);
      DefineFunc(VarList,Code.Lines.Strings[i]);
      DefineActivity(VarList,Code.Lines.Strings[i]);
      inc(i)
    end;

    DefineBugs(VarList);
    p:=VarList;
    if p=nil then exit;
    while Assigned(p) do
    begin
      Case p^.Func of
        1: groupStr[0]:=groupStr[0]+p^.Name+' ';
        2: groupStr[1]:=groupStr[1]+p^.Name+' ';
        3: groupStr[2]:=groupStr[2]+p^.Name+' ';
        4: groupStr[3]:=groupStr[3]+p^.Name+' ';
      end;
      p:=p^.Next;
    end;
    ResultForm.Res.Lines.Add('Метрика Чепина для процедуры ' + procname);
    ResultForm.Res.Lines.Add(groupStr[0]);
    ResultForm.Res.Lines.Add(groupStr[1]);
    ResultForm.Res.Lines.Add(groupStr[2]);
    ResultForm.Res.Lines.Add(groupStr[3]);
    result:=DeterminateChapin(VarList);
    ResultForm.Res.Lines.Add('Значение метрики Чепина: '+floattostr(result));
    ResultForm.Res.Lines.Add('');
  end;

begin
  ResultButton.Enabled:=True;
  ResultForm.Res.Clear;
  AnalyseCode('main',0,Code.Lines.Count-1);
end;
end.
