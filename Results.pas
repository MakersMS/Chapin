unit Results;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TResultForm = class(TForm)
    CloseButton: TButton;
    Res: TMemo;
    Label2: TLabel;
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ResultForm: TResultForm;

implementation

{$R *.dfm}

procedure TResultForm.CloseButtonClick(Sender: TObject);
begin
ResultForm.Close;
end;

end.
