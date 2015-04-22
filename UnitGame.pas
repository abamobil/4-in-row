unit UnitGame;

interface

uses
  Windows, SysUtils, Classes;

type
  TBoardCellState = (bcsEmpty, bcsPlayer1, bcsPlayer2);
  TCurrentPlayer = (cpPlayer1=1{bcsPlayer1}, cpPlayer2=2{bcsPlayer2});
  TGameState = (gsNewGame, gsInProgress, gsFinishedWinNobody, gsFinishedWinPlayer1, gsFinishedWinPlayer2);
  TBoard = array[1..7,1..6] of TBoardCellState;

  TGame = class
  private
    FBoard : TBoard;
    FCurrentPlayer : TCurrentPlayer;
    FGameState : TGameState;
    FUsedCells : Integer;
    procedure ClearBoard;
  protected
    function GetCurrentPlayerName : String;
    function GetGameStateText : String;
    procedure CheckWin(x, y : Integer);
  public
    constructor Create;
    procedure NewGame;
    function DoPlayerMove(ACol : Integer) : Integer;
    property Board : TBoard read FBoard;
    property CurrentPlayer : TCurrentPlayer read FCurrentPlayer;
    property CurrentPlayerName : String read GetCurrentPlayerName;
    property GameState : TGameState read FGameState;
    property GameStateText : String read GetGameStateText;
  end;

implementation

{ TGame }

constructor TGame.Create;
begin
  inherited;
  ClearBoard;
end;

procedure TGame.ClearBoard;
var
  i, j : Integer;
begin
  for i := 1 to 7 do
    for j := 1 to 6 do
      FBoard[i, j] := bcsEmpty;
  FCurrentPlayer := cpPlayer1;
  FGameState := gsNewGame;
  FUsedCells := 0;
end;

procedure TGame.NewGame;
begin
  ClearBoard;
end;

function TGame.GetCurrentPlayerName : String;
begin
  if FCurrentPlayer = cpPlayer1 then Result := 'Player 1' else Result := 'Player 2';
end;

function TGame.GetGameStateText : String;
begin
  case FGameState of
  gsNewGame : Result := 'New';
  gsInProgress : Result := 'In progress';
  gsFinishedWinNobody : Result := 'Finished';
  gsFinishedWinPlayer1 : Result := 'Win 1';
  gsFinishedWinPlayer2 : Result := 'Win 2';
  end;
end;

function TGame.DoPlayerMove(ACol : Integer) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if not (FGameState in [gsNewGame, gsInProgress]) then exit;
  for i := 6 downto 1 do
    if FBoard[ACol, i] = bcsEmpty then begin
      Result := i;
      FBoard[ACol, i] := TBoardCellState(FCurrentPlayer);
      FGameState := gsInProgress;
      inc(FUsedCells);
      CheckWin(ACol, i);
      if FGameState in [gsNewGame, gsInProgress] then
        if FCurrentPlayer = cpPlayer1 then FCurrentPlayer := cpPlayer2 else FCurrentPlayer := cpPlayer1;
      break;
    end;
end;

procedure TGame.CheckWin(x, y : Integer);
var
  player : TBoardCellState;
  i : Integer;
  SameOnLeft, SameOnRight : Integer;
  SameOnTop, SameOnBottom : Integer;
  SameOnDiag1, SameOnDiag2 : Integer;

  function GetWiner : TGameState;
  begin
    if player = bcsPlayer1 then Result := gsFinishedWinPlayer1 else Result := gsFinishedWinPlayer2;
  end;

begin
  player := FBoard[x, y];
  //Horizontal
  SameOnLeft := 0;
  for i := x - 1 downto 1 do
    if FBoard[i, y] = player then inc(SameOnLeft) else break;
  SameOnRight := 0;
  for i := x + 1 to 7 do
    if FBoard[i, y] = player then inc(SameOnRight) else break;
  if SameOnLeft + SameOnRight + 1 >= 4 then begin
    FGameState := GetWiner;
    exit;
  end;
  //Vertical
  SameOnTop := 0;
  for i := y - 1 downto 1 do
    if FBoard[x, i] = player then inc(SameOnTop) else break;
  SameOnBottom := 0;
  for i := y + 1 to 6 do
    if FBoard[x, i] = player then inc(SameOnBottom) else break;
  if SameOnTop + SameOnBottom + 1 >= 4 then begin
    FGameState := GetWiner;
    exit;
  end;
  //diagonal 1
  SameOnDiag1 := 0;
  for i := 1 to 7 do
    if (x - i > 0) and (y - i > 0) and (FBoard[x - i, y - i] = player) then inc(SameOnDiag1) else break;
  SameOnDiag2 := 0;
  for i := 1 to 7 do
    if (x + i <= 7) and (y + i <= 6) and (FBoard[x + i, y + i] = player) then inc(SameOnDiag2) else break;
  if SameOnDiag1 + SameOnDiag2 + 1 >= 4 then begin
    FGameState := GetWiner;
    exit;
  end;
  //diagonal 2
  SameOnDiag1 := 0;
  for i := 1 to 7 do
    if (x + i <= 7) and (y - i > 0) and (FBoard[x + i, y - i] = player) then inc(SameOnDiag1) else break;
  SameOnDiag2 := 0;
  for i := 1 to 7 do
    if (x - i > 0) and (y + i <= 6) and (FBoard[x - i, y + i] = player) then inc(SameOnDiag2) else break;
  if SameOnDiag1 + SameOnDiag2 + 1 >= 4 then begin
    FGameState := GetWiner;
    exit;
  end;

  if (FGameState = gsInProgress) and (FUsedCells = 6*7) then FGameState := gsFinishedWinNobody;
end;

end.
