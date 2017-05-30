unit TMenuClass;


{$mode objfpc}{$H+}


{ ----- interface ------------------------------------------------------------------------------------------------- }


interface

uses
  Classes, SysUtils, BasicTypes, zglHeader;


{ ----- global types ---------------------------------------------------------------------------------------------- }

type
  TMenuAction = (maStartGameE, maStartGameM, maStartGameH, maQuitGame, maChangeScreenSettings, maChangeControls, maNone);

type
  TMenuState = (msMain, msSettings, msDifficulty, msControls, msGraphic, msChangeControls);
  TChangingControl = (ccUp, ccDown, ccLeft, ccRight, ccPutBomb, ccDetonate, ccNone);

type
  TDrawProc    = procedure() of object;
  TDrawProcArr = array [TMenuState] of TDrawProc;

type
  TKeyProc    = procedure(AKey: Int16) of object;
  TKeyProcArr = array [TMenuState] of TKeyProc;


{ ----- global constant ------------------------------------------------------------------------------------------- }


const
  // TODO: Zmienić nazwy przzycisków.
  KeyNames : array[0..107] of UTF8String =
  (
    'K_SYSRQ',
    'K_PAUSE',
    'K_ESCAPE',
    'K_ENTER',
    'K_KP_ENTER',

    'K_UP',
    'K_DOWN',
    'K_LEFT',
    'K_RIGHT',

    'K_BACKSPACE',
    'K_SPACE',
    'K_TAB',
    'K_TILDE',

    'K_INSERT',
    'K_DELETE',
    'K_HOME',
    'K_END',
    'K_PAGEUP',
    'K_PAGEDOWN',

    'K_CTRL',
    'K_CTRL_L',
    'K_CTRL_R',
    'K_ALT',
    'K_ALT_L',
    'K_ALT_R',
    'K_SHIFT',
    'K_SHIFT_L',
    'K_SHIFT_R',
    'K_SUPER',
    'K_SUPER_L',
    'K_SUPER_R',
    'K_APP_MENU',

    'K_CAPSLOCK',
    'K_NUMLOCK',
    'K_SCROLL',

    'K_BRACKET_L',
    'K_BRACKET_R',
    'K_BACKSLASH',
    'K_SLASH',
    'K_COMMA',
    'K_DECIMAL',
    'K_SEMICOLON',
    'K_APOSTROPHE',

    'K_0',
    'K_1',
    'K_2',
    'K_3',
    'K_4',
    'K_5',
    'K_6',
    'K_7',
    'K_8',
    'K_9',

    'K_MINUS',
    'K_EQUALS',

    'K_A',
    'K_B',
    'K_C',
    'K_D',
    'K_E',
    'K_F',
    'K_G',
    'K_H',
    'K_I',
    'K_J',
    'K_K',
    'K_L',
    'K_M',
    'K_N',
    'K_O',
    'K_P',
    'K_Q',
    'K_R',
    'K_S',
    'K_T',
    'K_U',
    'K_V',
    'K_W',
    'K_X',
    'K_Y',
    'K_Z',

    'K_KP_0',
    'K_KP_1',
    'K_KP_2',
    'K_KP_3',
    'K_KP_4',
    'K_KP_5',
    'K_KP_6',
    'K_KP_7',
    'K_KP_8',
    'K_KP_9',

    'K_KP_SUB',
    'K_KP_ADD',
    'K_KP_MUL',
    'K_KP_DIV',
    'K_KP_DECIMAL',

    'K_F1',
    'K_F2',
    'K_F3',
    'K_F4',
    'K_F5',
    'K_F6',
    'K_F7',
    'K_F8',
    'K_F9',
    'K_F10',
    'K_F11',
    'K_F12'
  );


const
  TEXT_POSITION_X = RESOLUTION_X shr 1 - 100;
  // TODO: Przemyśleć tą tablicę.
  TEXT_POSITION_Y : array[TMenuState, 0..7] of UInt16 = (
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1, 0, 0, 0, 0, 0),
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1, 0, 0, 0, 0, 0),
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1 - 20, RESOLUTION_Y shr 1 + 20, 0, 0, 0, 0),
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1 - 20, RESOLUTION_Y shr 1, RESOLUTION_Y shr 1 + 20, RESOLUTION_Y shr 1 + 40, RESOLUTION_Y shr 1 + 80, RESOLUTION_Y shr 1 + 100),
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1, RESOLUTION_Y shr 1 + 20, 0, 0, 0, 0),
  (RESOLUTION_Y shr 1 - 60, RESOLUTION_Y shr 1 - 40, RESOLUTION_Y shr 1 - 20, RESOLUTION_Y shr 1, RESOLUTION_Y shr 1 + 20, RESOLUTION_Y shr 1 + 40, RESOLUTION_Y shr 1 + 80, RESOLUTION_Y shr 1 + 100)
  );
  PROMPT_POSITION_X = RESOLUTION_X shr 1 - 120;

{ ----- classes --------------------------------------------------------------------------------------------------- }


type
  TPrompt = class
  private
    FPromptTexture: zglPTexture;
    FPromptPosition: Int8;
    FMaxPromptPosition: Int8;
  public
    constructor Create();
    destructor Destroy(); override;
  public
    procedure Draw(AMenuState: TMenuState);
    procedure MoveDown();
    procedure MoveUp();
    procedure SetPosition(AMaxPosition, APosition: Int8);
  public
    property Position: Int8 read FPromptPosition;
  end;


type
  TMenu = class
  private
    FMenuState: TMenuState;
    FMenuAction: TMenuAction;
    FChangingControl: TChangingControl;
  private
    FDrawMenuProcedure: TDrawProcArr;
    FKeyHandleProcedure: TKeyProcArr;
  private
    FBackgroundTexture: zglPTexture;
    FFont: zglPFont;
    FPrompt: TPrompt;
  private
    FControlsSettings,
    FtmpControlsSettings: TControlsSettings;
    FScreenSettings,
    FtmpScreenSettings: TScreenSettings;
  private
    procedure DrawBackground();
    procedure DrawText(const AX, AY: Single; const AText: UTF8String);
    procedure ChangeMenu(AMaxPosition, APosition: Int8; AMenuState: TMenuState);
    function GetMenuAction(): TMenuAction;
    procedure InitDrawMenuProcArr();
    procedure InitKeyHandleProcArr();
    procedure ClearProcArr();
    function GetKeyName(AKey: Int16) : Int8;
  private
    procedure DrawMainMenu();
    procedure DrawOptionsMenu();
    procedure DrawDifficultyMenu();
    procedure DrawControlsMenu();
    procedure DrawGraphicMenu();
  private
    procedure MovePromptKeyHandle(AKey: Int16);
    procedure MainMenuKeyHandle(AKey: Int16);
    procedure OptionsMenuKeyHandle(AKey: Int16);
    procedure DifficultyMenuKeyHandle(AKey: Int16);
    procedure ControlsMenuKeyHandle(AKey: Int16);
    procedure ChangeControlsMenuKeyHandle(AKey: Int16);
    procedure GraphicMenuKeyHandle(AKey: Int16);
  public
    constructor Create(AScreenSettings: TScreenSettings; AControlsSettings: TControlsSettings);
    destructor Destroy(); override;
  public
    procedure Draw();
    procedure KeyHandle(AKey: Int16);
  public
    property MenuAction: TMenuAction read GetMenuAction;
    property ControlsSettings: TControlsSettings read FControlsSettings;
    property ScreenSettings: TScreenSettings read FScreenSettings;
  end;


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TPrompt class --------------------------------------------------------------------------------------------- }


constructor TPrompt.Create();
begin
  inherited Create;

  FPromptTexture := tex_LoadFromFile('Graphic\bomb.png'); // TODO: Zmienić teksturę
  FPromptPosition := 0;

  FMaxPromptPosition := 2;
end;


destructor TPrompt.Destroy();
begin
  tex_Del(FPromptTexture);
  inherited Destroy();
end;


procedure TPrompt.Draw(AMenuState: TMenuState);
begin
  ssprite2d_Draw(FPromptTexture, PROMPT_POSITION_X, TEXT_POSITION_Y[AMenuState, FPromptPosition], 20, 20, 0);
end;


procedure TPrompt.MoveDown();
begin
  Inc(FPromptPosition);

  if FPromptPosition > FMaxPromptPosition then
    FPromptPosition := 0;
end;


procedure TPrompt.MoveUp();
begin
  Dec(FPromptPosition);

  if FPromptPosition < 0 then
    FPromptPosition := FMaxPromptPosition;
end;


procedure TPrompt.SetPosition(AMaxPosition, APosition: Int8);
begin
  FPromptPosition := APosition;
  FMaxPromptPosition := AMaxPosition;
end;


{ ----- TMenu class ----------------------------------------------------------------------------------------------- }


constructor TMenu.Create(AScreenSettings: TScreenSettings; AControlsSettings: TControlsSettings);
begin
  inherited Create();
  FPrompt := TPrompt.Create();

  FControlsSettings := AControlsSettings;
  FtmpControlsSettings := AControlsSettings;
  FScreenSettings := AScreenSettings;
  FtmpScreenSettings := AScreenSettings;

  FMenuAction := maNone;
  FMenuState := msMain;
  FChangingControl := ccNone;

  InitDrawMenuProcArr;
  InitKeyHandleProcArr;

  FBackgroundTexture := tex_LoadFromFile('Graphic\background.png');
  FFont := font_LoadFromFile('Fonts\MainMenuFont.zfi');
end;


destructor TMenu.Destroy();
begin
  ClearProcArr();

  tex_Del(FBackgroundTexture);
  font_Del(FFont);

  FPrompt.Free();
  inherited Destroy();
end;


procedure TMenu.DrawBackground();
begin
  ssprite2d_Draw(FBackgroundTexture, 0, 0, RESOLUTION_X, RESOLUTION_Y, 0);
end;


procedure TMenu.DrawText(const AX, AY: Single; const AText: UTF8String);
var
  Rect: zglTRect;
begin
  Rect.X := AX;
  Rect.Y := AY;
  Rect.W := text_GetWidth(FFont, AText) + 20;
  Rect.H := text_GetHeight(FFont, Rect.W, AText) + 4;

  text_DrawInRect(FFont, Rect, AText, TEXT_VALIGN_CENTER);
end;


procedure TMenu.ChangeMenu(AMaxPosition, APosition: Int8; AMenuState: TMenuState);
begin
  FPrompt.SetPosition(AMaxPosition, APosition);
  FMenuState := AMenuState;
end;


function TMenu.GetMenuAction(): TMenuAction;
begin
  result := FMenuAction;
  FMenuAction := maNone;
end;


procedure TMenu.InitDrawMenuProcArr();
begin
  FDrawMenuProcedure[msMain] := @DrawMainMenu;
  FDrawMenuProcedure[msSettings] := @DrawOptionsMenu;
  FDrawMenuProcedure[msDifficulty] := @DrawDifficultyMenu;
  FDrawMenuProcedure[msControls] := @DrawControlsMenu;
  FDrawMenuProcedure[msGraphic] := @DrawGraphicMenu;
  FDrawMenuProcedure[msChangeControls] := @DrawControlsMenu;
end;


procedure TMenu.InitKeyHandleProcArr();
begin
  FKeyHandleProcedure[msMain] := @MainMenuKeyHandle;
  FKeyHandleProcedure[msSettings] := @OptionsMenuKeyHandle;
  FKeyHandleProcedure[msDifficulty] := @DifficultyMenuKeyHandle;
  FKeyHandleProcedure[msControls] := @ControlsMenuKeyHandle;
  FKeyHandleProcedure[msGraphic] := @GraphicMenuKeyHandle;
  FKeyHandleProcedure[msChangeControls] := @ChangeControlsMenuKeyHandle;
end;


procedure TMenu.ClearProcArr();
var
  MenuState : TMenuState;
begin
  for MenuState := Low(TMenuState) to High(TMenuState) do
  begin
    FDrawMenuProcedure[MenuState] := nil;
    FKeyHandleProcedure[MenuState] := nil;
  end;
end;


function TMenu.GetKeyName(AKey: Int16) : Int8;
begin
  case AKey of
    $B7: result := 0;
    $C5: result := 1;
    $01: result := 2;
    $1C: result := 3;
    $9C: result := 4;

    $C8: result := 5;
    $D0: result := 6;
    $CB: result := 7;
    $CD: result := 8;

    $0E: result := 9;
    $39: result := 10;
    $0F: result := 11;
    $29: result := 12;

    $D2: result :=  13;
    $D3: result :=  14;
    $C7: result :=  15;
    $CF: result :=  16;
    $C9: result :=  17;
    $D1: result :=  18;

    $FF - $01: result := 19;
    $1D: result := 20;
    $9D: result := 21;
    $FF - $02: result := 22;
    $38: result := 23;
    $B8: result := 24;
    $FF - $03: result := 25;
    $2A: result := 26;
    $36: result := 27;
    $FF - $04: result := 28;
    $DB: result := 29;
    $DC: result := 30;
    $DD: result := 31;

    $3A: result := 32;
    $45: result := 33;
    $46: result := 34;

    $1A: result := 35;
    $1B: result := 36;
    $2B: result := 37;
    $35: result := 38;
    $33: result := 39;
    $34: result := 40;
    $27: result := 41;
    $28: result := 42;

    $0B: result := 43;
    $02: result := 44;
    $03: result := 45;
    $04: result := 46;
    $05: result := 47;
    $06: result := 48;
    $07: result := 49;
    $08: result := 50;
    $09: result := 51;
    $0A: result := 52;

    $0C: result := 53;
    $0D: result := 54;

    $1E: result := 55;
    $30: result := 56;
    $2E: result := 57;
    $20: result := 58;
    $12: result := 59;
    $21: result := 60;
    $22: result := 61;
    $23: result := 62;
    $17: result := 63;
    $24: result := 64;
    $25: result := 65;
    $26: result := 66;
    $32: result := 67;
    $31: result := 68;
    $18: result := 69;
    $19: result := 70;
    $10: result := 71;
    $13: result := 72;
    $1F: result := 73;
    $14: result := 74;
    $16: result := 75;
    $2F: result := 76;
    $11: result := 77;
    $2D: result := 78;
    $15: result := 79;
    $2C: result := 80;

    $52: result := 81;
    $4F: result := 82;
    $50: result := 83;
    $51: result := 84;
    $4B: result := 85;
    $4C: result := 86;
    $4D: result := 87;
    $47: result := 88;
    $48: result := 89;
    $49: result := 90;

    $4A: result := 91;
    $4E: result := 92;
    $37: result := 93;
    $B5: result := 94;
    $53: result := 95;

    $3B: result := 96;
    $3C: result := 97;
    $3D: result := 98;
    $3E: result := 99;
    $3F: result := 100;
    $40: result := 101;
    $41: result := 102;
    $42: result := 103;
    $43: result := 104;
    $44: result := 105;
    $57: result := 106;
    $58: result := 107;
  end;
end;


procedure TMenu.DrawMainMenu();
begin
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'START');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'SETTINGS');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'EXIT');
end;


procedure TMenu.DrawOptionsMenu();
begin
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'GRAPHIC');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'CONTROLS');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'BACK');
end;


procedure TMenu.DrawDifficultyMenu();
begin
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'EASY');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'NORMAL');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'HARD');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 3], 'BACK');
end;


procedure TMenu.DrawControlsMenu();
begin
  if FChangingControl = ccUP then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'UP - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'UP - ' + KeyNames[GetKeyName(FtmpControlsSettings.Up)]);

  if FChangingControl = ccDown then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'DOWN - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'DOWN - ' + KeyNames[GetKeyName(FtmpControlsSettings.Down)]);

  if FChangingControl = ccLeft then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'LEFT - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'LEFT - ' + KeyNames[GetKeyName(FtmpControlsSettings.Left)]);

  if FChangingControl = ccRight then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 3], 'RIGHT - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 3], 'RIGHT - ' + KeyNames[GetKeyName(FtmpControlsSettings.Right)]);

  if FChangingControl = ccPutBomb then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 4], 'PUT BOMB - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 4], 'PUT BOMB - ' + KeyNames[GetKeyName(FtmpControlsSettings.PutBomb)]);

  if FChangingControl = ccDetonate then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 5], 'DETONATE - ???')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 5], 'DETONATE - ' + KeyNames[GetKeyName(FtmpControlsSettings.Detonate)]);

  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 6], 'SAVE');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 7], 'BACK');
end;


procedure TMenu.DrawGraphicMenu();
begin
  if FtmpScreenSettings.FullScreen then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'FULLSCREEN - YES')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 0], 'FULLSCREEN - NO');

  if FtmpScreenSettings.Stretch then
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'STRETCH - YES')
  else
    DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 1], 'STRETCH - NO');

  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 2], 'SAVE');
  DrawText(TEXT_POSITION_X, TEXT_POSITION_Y[FMenuState, 3], 'BACK');
end;


procedure TMenu.MovePromptKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.Up then
    FPrompt.MoveUp()
  else
    if AKey = FControlsSettings.Down then
      FPrompt.MoveDown();
end;


procedure TMenu.MainMenuKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.PutBomb then
  case FPrompt.Position of
    0: ChangeMenu(3, 0, msDifficulty);
    1: ChangeMenu(2, 0, msSettings);
    2: FMenuAction := maQuitGame;
  end;
end;


procedure TMenu.OptionsMenuKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.PutBomb then
  case FPrompt.Position of
    0: ChangeMenu(3, 0, msGraphic);
    1: ChangeMenu(7, 0, msControls);
    2: ChangeMenu(2, 1, msMain);
  end;
end;


procedure TMenu.DifficultyMenuKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.PutBomb then
  case FPrompt.Position of
    0: FMenuAction := maStartGameE;
    1: FMenuAction := maStartGameM;
    2: FMenuAction := maStartGameH;
    3: ChangeMenu(2, 0, msMain);
  end;
end;


procedure TMenu.ControlsMenuKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.PutBomb then
  case FPrompt.Position of
    0 : begin
          ChangeMenu(7, 0, msChangeControls);
          FChangingControl := ccUp;
        end;
    1 : begin
          ChangeMenu(7, 1, msChangeControls);
          FChangingControl := ccDown;
        end;
    2 : begin
          ChangeMenu(7, 2, msChangeControls);
          FChangingControl := ccLeft;
        end;
    3 : begin
          ChangeMenu(7, 3, msChangeControls);
          FChangingControl := ccRight;
        end;
    4 : begin
          ChangeMenu(7, 4, msChangeControls);
          FChangingControl := ccPutBomb;
        end;
    5 : begin
          ChangeMenu(7, 5, msChangeControls);
          FChangingControl := ccDetonate;
        end;
    6 : begin
          FControlsSettings := FtmpControlsSettings;
          FMenuAction := maChangeControls;
        end;
    7 : begin
          FtmpControlsSettings := FControlsSettings;
          ChangeMenu(2, 1, msSettings);
        end;
  end;
end;


procedure TMenu.ChangeControlsMenuKeyHandle(AKey: Int16);
begin
  case FChangingControl of
    ccUp      : FtmpControlsSettings.Up := AKey;
    ccDown    : FtmpControlsSettings.Down := AKey;
    ccLeft    : FtmpControlsSettings.Left := AKey;
    ccRight   : FtmpControlsSettings.Right := AKey;
    ccPutBomb : FtmpControlsSettings.PutBomb := AKey;
    ccDetonate: FtmpControlsSettings.Detonate := AKey;
  end;
  FMenuState := msControls;
  FChangingControl := ccNone;
end;


procedure TMenu.GraphicMenuKeyHandle(AKey: Int16);
begin
  if AKey = FControlsSettings.PutBomb then
  case FPrompt.Position of
    0: FtmpScreenSettings.FullScreen := not FtmpScreenSettings.FullScreen;
    1: FtmpScreenSettings.Stretch := not FtmpScreenSettings.Stretch;
    2: begin
         FScreenSettings := FtmpScreenSettings;
         FMenuAction := maChangeScreenSettings;
       end;
    3: begin
         FtmpScreenSettings := FScreenSettings;
         ChangeMenu(2, 0, msSettings);
       end;
  end;
end;


procedure TMenu.Draw();
begin
  DrawBackground();
  FDrawMenuProcedure[FMenuState]();
  FPrompt.Draw(FMenuState);
end;


procedure TMenu.KeyHandle(AKey: Int16);
begin
  if FMenuState <> msChangeControls then
    MovePromptKeyHandle(AKey);
  FKeyHandleProcedure[FMenuState](AKey);
end;


{ ----- end implementation----------------------------------------------------------------------------------------- }


end.

