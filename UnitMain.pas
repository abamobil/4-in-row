unit UnitMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Grids, ImgList, UnitGame, ExtCtrls, StdCtrls;

type
  TFormGame = class(TForm)
    BoardGrid: TDrawGrid;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    NewGame1: TMenuItem;
    Exit1: TMenuItem;
    ImageListCellBitmaps: TImageList;
    Label1: TLabel;
    ImageListPlayers: TImageList;
    ImagePlayer: TImage;
    LabelPlayerName: TLabel;
    LabelGameState: TLabel;
    procedure BoardGridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BoardGridClick(Sender: TObject);
    procedure NewGame1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
    FGame : TGame;
    procedure Redraw(ACol, ARow: Integer);
  public
    { Public declarations }
  end;

var
  FormGame: TFormGame;

implementation

{$R *.dfm}

procedure TFormGame.NewGame1Click(Sender: TObject);
begin
  FGame.NewGame;
  Redraw(0, 0);
end;

procedure TFormGame.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TFormGame.FormCreate(Sender: TObject);
begin
  FGame := TGame.Create;
  NewGame1Click(nil);
end;

procedure TFormGame.FormDestroy(Sender: TObject);
begin
  FGame.Free;
end;

procedure TFormGame.BoardGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  X, Y : Integer;
  CellBitmapIndex : Integer;
  SenderGrid : TDrawGrid;
begin
  SenderGrid := Sender as TDrawGrid;
  Y := ACol+1;
  X := ARow+1;
  CellBitmapIndex := Integer(FGame.Board[Y, X]);
  with SenderGrid do begin
    Canvas.Brush.Color := clBackGround;
    Canvas.FillRect(Rect);
    ImageListCellBitmaps.Draw(Canvas, Rect.Left, Rect.Top, CellBitmapIndex);
    if gdFocused in State then
      Canvas.DrawFocusRect(Rect);
  end;
end;

procedure TFormGame.Redraw(ACol, ARow : Integer);
begin
  BoardGrid.Invalidate;{InvalidateCell(ACol, ARow) - Redraw only Certain Cell}
  //ImageListPlayers.GetBitmap(Integer(FGame.CurrentPlayer)-1, ImagePlayer.Picture.Bitmap);
  ImageListPlayers.Draw(ImagePlayer.Canvas, 0, 0, Integer(FGame.CurrentPlayer)-1);
  ImagePlayer.Invalidate;
  LabelPlayerName.Caption := FGame.CurrentPlayerName;
  LabelGameState.Caption := FGame.GameStateText;
end;

procedure TFormGame.BoardGridClick(Sender: TObject);
var
  CurCel : TPoint;
  P, Pc : TPoint;
begin
  if not (FGame.GameState in [gsNewGame, gsInProgress]) then raise Exception.Create('Game Finished. Start new game.');
  GetCursorPos(P);
  Pc := BoardGrid.ScreenToClient(P);
  BoardGrid.MouseToCell(Pc.X, Pc.Y, CurCel.X, CurCel.Y);
  CurCel.Y := FGame.DoPlayerMove(CurCel.X+1) - 1;
  if CurCel.Y < 0 then begin
    Raise Exception.Create('This Move is not Allowed');
  end else begin
    Redraw(CurCel.X, CurCel.Y);
    if not (FGame.GameState in [gsNewGame, gsInProgress]) then ShowMessage('Game Finished. '+FGame.GameStateText);
  end;
end;

end.
