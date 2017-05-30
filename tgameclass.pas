unit TGameClass;


{$mode objfpc}{$H+}


{ ----- interface ------------------------------------------------------------------------------------------------- }


interface


uses
  zglHeader, BasicTypes, TMenuClass, Classes, SysUtils;


{ ----- global types ---------------------------------------------------------------------------------------------- }


type
  TDrawProc = procedure() of object;
  TInputProc = procedure(AKey: Int16) of object;


{ ----- classes --------------------------------------------------------------------------------------------------- }


type
  TGame = class
    private
      FMenu : TMenu;
      FSettings: TSettings;

      FAppState: TAppState;
      FDrawProcedure: array[TAppState] of TDrawProc;
      FInputProcedure: array[TAppState] of TInputProc;
    private
      procedure MenuDraw();
      procedure MenuInput(AKey: Int16);
      procedure GameDraw();
      procedure GameInput(AKey: Int16);
    public
      constructor Create();
      destructor Destroy(); override;
    public
      procedure Draw();
      procedure Logic();
      procedure Input(AKey: Int16);
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TGame class ----------------------------------------------------------------------------------------------- }


constructor TGame.Create();
begin
  inherited Create();

  FSettings := TSettings.Create();
  FMenu := TMenu.Create(FSettings.ScreenSettings, FSettings.ControlsSettings);
  SetScreenSettings(FSettings.ScreenSettings.FullScreen, FSettings.ScreenSettings.Stretch);

  FAppState := asMenu;
  FDrawProcedure[asMenu] := @MenuDraw;
  FDrawProcedure[asGameStarted] := @GameDraw;
  FDrawProcedure[asGamePaused] := @MenuDraw;

  FInputProcedure[asMenu] := @MenuInput;
  FInputProcedure[asGameStarted] := @GameInput;
  FInputProcedure[asGamePaused] := @MenuInput;
end;


destructor TGame.Destroy();
var
  i : TAppState;
begin
  FSettings.ControlsSettings := FMenu.ControlsSettings;
  FSettings.ScreenSettings := FMenu.ScreenSettings;

  FMenu.Free;
  FSettings.Free;

  for i in TAppState do
  begin
    FDrawProcedure[i] := nil;
    FInputProcedure[i] := nil;
  end;

  inherited Destroy;
end;


procedure TGame.MenuDraw();
begin
  FMenu.Draw();
end;


procedure TGame.MenuInput(AKey: Int16);
var
  MenuAction: TMenuAction;
begin
  if (AKey = K_ESCAPE) and (FAppState = asGamePaused) then
    FAppState := asGameStarted;
  FMenu.KeyHandle(AKey);
  MenuAction := FMenu.MenuAction;
  case MenuAction of
    maChangeScreenSettings :
      begin
        FSettings.ScreenSettings := FMenu.ScreenSettings;
        SetScreenSettings(FSettings.ScreenSettings.FullScreen, FSettings.ScreenSettings.Stretch);
      end;
    maChangeControls :
      FSettings.ControlsSettings := FMenu.ControlsSettings;
    maQuitGame :
      zgl_Exit;
    maStartGameE :
      FAppState := asGameStarted;
    maStartGameM :
      FAppState := asGameStarted;
    maStartGameH :
      FAppState := asGameStarted;
  end;
end;


procedure TGame.GameDraw();
begin

end;


procedure TGame.GameInput(AKey: Int16);
begin
  if AKey = K_ESCAPE then
    FAppState := asGamePaused;
end;

procedure TGame.Draw();
begin
  FDrawProcedure[FAppState];
end;


procedure TGame.Logic();
begin

end;


procedure TGame.Input(AKey: Int16);
begin
  FInputProcedure[FAppState](AKey);
end;


{ ----- end implementation----------------------------------------------------------------------------------------- }


end.

