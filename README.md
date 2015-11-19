# Chapin
unit MetricChapin;

interface

type List = ^TList;
     TList = record
       Name: string;
       Activity: boolean;
       Func: byte;
       Next: List;
     end;

procedure TakeVars(var VarList: List; line:string);
procedure DefineFunc(var VarList:List; line:string);
procedure DefineActivity(var VarList:List; line:string);
procedure DefineBugs(var VarList:List);
function  DeterminateChapin(var VarList:List):real;




(*****************************************************************************)

implementation

uses SysUtils,RegExpr;


//Функция, определяющая наличие переменной в списке
function FindPlace(var varList:List; name:string):boolean;
var p:List;
begin
  if varList=nil
  then result:=true
  else
  begin
    p:=varList;
    while (Assigned(p)) and not(p^.Name=name) do p:=p^.Next;
    if p=nil
    then result:=true
    else result:=false;
  end;
end;

//Процедура добавления элемента в список
procedure AddToList(var varList:List; name: string);
var
  p:List;
begin
if FindPlace(varList, Name) then
begin
  if  varList=nil
  then
    begin
      new(varList);
      varList^.Name:=name;
      varList^.Activity:=false;
      varList^.Func:=1;
      varList^.Next:=nil;
    end
  else
    begin
      p:=varList;
      while p^.Next<>nil do
        p:=p^.Next;
      new(p^.Next);
      p:=P^.Next;
      p^.Name:=name;
      p^.Activity:=false;
      p^.Func:=1;
      p^.Next:=nil;
    end;
end;
end;


{Процедура, просматривающая инициализацию переменных внутри программы,
тем самым находя все переменные, используемые в коде}
procedure TakeVars(var varList: List; line:string);
var expr:TRegExpr;
    subexpr:byte;
begin
  expr:=TRegExpr.Create;
  expr.Expression:='(\w+)\s*[^\\\+\*\-\%\=]=[^=]'; //examples: i = 3 or n = y = 3+5 ** 6
  subexpr:=1;
  expr.InputString:=line;
  if expr.Exec then
  begin
    AddToList(varList, expr.Match[subexpr]);
    while expr.ExecNext do
      AddToList(varList, expr.Match[subexpr]);
  end;

  expr.Expression:='for\s+(\w+)\s+in';  //examples: for i in str
  if expr.Exec then
    AddToList(varList, expr.Match[subexpr]);

  expr.Expression:='\sdef\s+\w+\((.*)\)';  //examples: def function(a,b)
  if expr.Exec then
  begin
    expr.InputString:=expr.Match[subexpr];
    expr.Expression:='\w+';
    subexpr:=0;
    if expr.Exec then
    begin
      AddToList(varList, expr.Match[subexpr]);
      while expr.ExecNext do
        AddToList(varList, expr.Match[subexpr]);
    end;
  end;

end;


{Процедура, изменяющая функциональную группу переменной}
procedure ChangeFunc(var varList:List; variable:string; func:byte);
var p:List;
begin
  if varList<>nil
  then
  begin
    p:=varList;
    while (Assigned(p) and (variable<>p^.Name)) do
      p:=p^.Next;
    if ((p<>nil) and (p^.Func<func)) then
      p^.Func:=func;
  end;
end;

{Процедура, изменяющая значение активности переменной}
procedure ChangeActivity(var varList:List; variable:string; activ:boolean);
var p:List;
begin
  if varList<>nil
  then
  begin
    p:=varList;
    while (Assigned(p) and (variable<>p^.Name)) do
      p:=p^.Next;
    if (p<>nil) then  p^.Activity:=activ;
  end;
end;


{Процедура, которая, основываясь на строке кода s, определяет выполняемую
переменной в программе функцию}
procedure DefineFunc(var varList:List; line:string);
const P=1;
      M=2;
      C=3;
var expr:TRegExpr;
    subexpr:byte;

  //Производит изменения параметра выполняемой функции
  procedure MakeChanges(var expr:TRegExpr; group:byte);
  begin
  if expr.Exec
    then
    begin
      subexpr:=1;
      ChangeFunc(varList,expr.Match[subexpr],group);
      while expr.ExecNext do
        ChangeFunc(varList,expr.Match[subexpr],group);
    end;
  end;

(*DefineFunc Begin*)
begin
  // Функциональная группа "1" - Исходные (Родительские)
  expr:=TRegExpr.Create;
  expr.Expression:='(\w+)(\[\w+\])*\s*=\s*(.*\()*((input|open)\(.*\)+\s*|\w+\.(read|readline)\([0-9]*\)+\s*)$';  //example: i= input()
  subexpr:=1;
  expr.InputString:=line;
  if expr.Exec
  then
  begin
    expr.Expression:='(\w+)(\[\w+\])*\s*=[^=]';
    MakeChanges(expr,P);
  end

  // Функциональная группа "2" - Модифицируемые
  else
  begin
    expr.Expression:='(\w+)(\[\w+\])*\s*[\-\+\\\%\*]*=';  //example: i+=2 or n = 4 + z
    MakeChanges(expr,M);

    expr.Expression:='(\w+)(\[\w+\])*\.\w+';  //example: i.include()
    MakeChanges(expr,M)
  end;

  //Функциональная группа "3"  - Управляющие
    expr.Expression:='for\s+(\w+)\s+in\s';    // цикл for
    if expr.Exec
    then
    begin
      ChangeFunc(varList,expr.Match[subexpr],C);
      expr.Expression:='\s*(\w+)(\[.*\])*';
      while expr.ExecNext do
        ChangeFunc(varList,expr.Match[subexpr],C);
    end;

    expr.Expression:='(while|if|elif)[\(\-\+\s]+(\w+)';    // цикл while и if-elif
    subexpr:=2;
    if expr.Exec
    then
    begin
      ChangeFunc(varList,expr.Match[subexpr],C);
      expr.Expression:='\s*(\w+)(\[.*\])*';
      subexpr:=1;
      while expr.ExecNext do
        ChangeFunc(varList,expr.Match[subexpr],C);
    end;

end;

{Процедура, которая определяет, использовались ли в дальнейшем
инициализированные переменные или нет}
procedure DefineActivity(var varList:List; line:string);
var expr:TRegExpr;
    variable:string;
    subexpr:byte;

  //Произвести изменения для всех переменных внутри выражения или среди параметров
  procedure ChangeActivityForAll(varList:List; line:string; active:boolean);
  begin
    if expr.Exec then
    begin
      subexpr:=1;
      expr.InputString:=expr.Match[subexpr]+' ';
      expr.Expression:= '(\w+)\.?\,?(\[.*\])*[^(]';
      if expr.Exec then
        begin
          ChangeActivity(varList,expr.Match[subexpr],true);
          while expr.ExecNext do
            ChangeActivity(varList,expr.Match[subexpr],true);
        end;
    end;
  end;

(*DefineActivity Begin*)
begin
  subexpr:=1;
  expr:=TRegExpr.Create;
  expr.Expression:='(\w+)\s*[\\\-\+\*\%]?=[\s\w]'; //example (a) = x  or (a) += 2
  expr.InputString:=line;
  if expr.Exec then
  begin
    variable:=expr.Match[subexpr];
    expr.Expression:= '(\w+)\.?\,?(\[.*\])*[^(]';  //example a = (x)[5] + (z) + 4 + (y)
    while expr.ExecNext do
      if expr.Match[subexpr]<>variable then
        ChangeActivity(varList,expr.Match[subexpr],true);
  end;

  expr.InputString:=line;
  expr.Expression:='\w+\((.*)\)';      //example function(x,y,z)
  ChangeActivityForAll(varList,expr.Match[subexpr],true);

  expr.InputString:=line;
  expr.Expression:='\sreturn\s(.*)';  //example return a+b
  ChangeActivityForAll(varList,expr.Match[subexpr],true);
end;



{Процедура по определению "паразитов" из конечного списка}
procedure DefineBugs(var varList:List);
const C=3;
      T=4;
var p:List;
begin
  p:=varList;
  While Assigned(p) do
  begin
    if (not(p^.Activity) and (p^.Func<>C)) then p^.Func:=T;
    p:=p^.Next;
  end;
end;



{Функция, возвращающая значение метрики Чепина}
function DeterminateChapin(var varList:List):real;
const P=1;
      M=2;
      C=3;
      T=0.5;
var elementForDel,elementOfList:List;
begin
  elementOfList:=varList;
  while Assigned(elementOfList) do
  begin
    elementForDel:=elementOfList;
    Case elementOfList^.Func of //смотрим, какую функцию выполняет данная переменная
      1:result:=result+P;
      2:result:=result+M;
      3:result:=result+C;
      4:result:=result+T;
    end;
    elementOfList:=elementOfList^.Next;
    dispose(elementForDel);
  end;
end;


(*********************************************************************************)
(*********************************************************************************)
(*********************************************************************************)
end.
