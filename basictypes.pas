unit BasicTypes;

{$mode objfpc}{$H+}


{ ----- interface ------------------------------------------------------------------------------------------------- }


interface


uses
  Classes, SysUtils, zglHeader, Registry, Windows;


{ ----- global constants ------------------------------------------------------------------------------------------ }


const
  SPRITE_SIZE_X = 40;
  SPRITE_SIZE_Y = 40;


const
  RESOLUTION_X = SPRITE_SIZE_X * 15 + 360;
  RESOLUTION_Y = SPRITE_SIZE_Y * 15;


const
  FRAME_SIZE_X = 100;
  FRAME_SIZE_Y = 100;


{ ----- global types ---------------------------------------------------------------------------------------------- }


type
  TAppState = (asMenu, asGameStarted, asGamePaused);

type
  TControlsSettings = record
    Up: UInt16;
    Down: Int16;
    Left: Int16;
    Right: Int16;
    PutBomb: Int16;
    Detonate: Int16;
  end;

type
  TScreenSettings = record
    FullScreen: Boolean;
    Stretch: Boolean;
  end;


{ ----- classes --------------------------------------------------------------------------------------------------- }


type
  TSettings = class
    private
      FControlsSettings: TControlsSettings;
      FScreenSettings: TScreenSettings;
    private
      function LoadFromFile() : Boolean;
      procedure LoadDefaults();
      procedure SaveToFile();
    public
      constructor Create();
      destructor Destroy(); override;
    public
      property ControlsSettings : TControlsSettings read FControlsSettings write FControlsSettings;
      property ScreenSettings : TScreenSettings read FScreenSettings write FScreenSettings;
  end;


{ ----- global variables ------------------------------------------------------------------------------------------ }


var
  ConfigPath : String;
  DataPath   : String;


{ ----- global procedures & functions ----------------------------------------------------------------------------- }


procedure SetPath();
procedure SetScreenSettings(AFullScreen, AStretch: Boolean);


{ ----- end interface --------------------------------------------------------------------------------------------- }


implementation


{ ----- TSettings class ----------------------------------------------------------------------------------- }


constructor TSettings.Create();
begin
  inherited Create;
  if not LoadFromFile then LoadDefaults;
end;


destructor TSettings.Destroy();
begin
  SaveToFile;
  inherited Destroy;
end;


function TSettings.LoadFromFile() : Boolean;
var
  ConfigFile: TFileStream;
begin
  Result := False;

  if FileExists(ConfigPath + 'config.cfg') then
  begin
    ConfigFile := TFileStream.Create(ConfigPath + 'config.cfg', fmOpenRead);
    try
      ConfigFile.ReadBuffer(FControlsSettings, SizeOf(FControlsSettings));
      ConfigFile.ReadBuffer(FScreenSettings, SizeOf(FScreenSettings));
    finally
      ConfigFile.Free();
    end;
    Result := True;
  end;
end;


procedure TSettings.LoadDefaults();
begin
  FControlsSettings.Up := K_UP;
  FControlsSettings.Down := K_DOWN;
  FControlsSettings.Left := K_LEFT;
  FControlsSettings.Right := K_RIGHT;
  FControlsSettings.PutBomb := K_SPACE;
  FControlsSettings.Detonate := K_B;

  FScreenSettings.FullScreen := False;
  FScreenSettings.Stretch := False;
end;


procedure TSettings.SaveToFile();
var
  ConfigFile: TFileStream;
begin
  ConfigFile := TFileStream.Create(ConfigPath + 'config.cfg', fmCreate);
  try
    ConfigFile.WriteBuffer(FControlsSettings, SizeOf(FControlsSettings));
    ConfigFile.WriteBuffer(FScreenSettings, SizeOf(FScreenSettings));
  finally
    ConfigFile.Free();
  end;
end;


{ ----- global procedures & functions ----------------------------------------------------------------------------- }


procedure SetPath();
var
  Registry : TRegistry;
begin
  Registry := TRegistry.Create();
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKey('SOFTWARE\Bomberman', true) then
    try
      if Registry.ValueExists('Path') then
        DataPath := Registry.ReadString('Path')
      else
      begin
        MessageBox(0, 'Missing registry key. Please reinstall game', 'Error!', MB_OK);
        Halt(2);
      end;
    finally
      Registry.CloseKey();
    end
    else
    begin
      MessageBox(0, 'Missing registry value. Please reinstall game', 'Error!', MB_OK);
      Halt(1);
    end;
  finally
    Registry.Free();
  end;

  if DirectoryExists(DataPath) then
    SetCurrentDir(DataPath)
  else
  begin
    MessageBox(0, 'Failed to set correct working path. Please reinstall game', 'Error!', MB_OK);
    Halt(3);
  end;

  ConfigPath := SysUtils.GetEnvironmentVariable('appdata') + '\Bomberman\';
  if not DirectoryExists(ConfigPath) then
    if not CreateDir(ConfigPath) then
    begin
      MessageBox(0, 'Failed to set correct path to configuration file. Please reinstall game', 'Error!', MB_OK);
      Halt(4);
    end;
end;


procedure SetScreenSettings(AFullScreen, AStretch: Boolean);
begin
  if AFullScreen and not AStretch then
  begin
    zgl_Enable(CORRECT_RESOLUTION);
    scr_CorrectResolution(RESOLUTION_X, RESOLUTION_Y);
    scr_SetOptions(zgl_Get(DESKTOP_WIDTH), zgl_Get(DESKTOP_HEIGHT), REFRESH_MAXIMUM, True, False);
  end

  // fullscreen bez czarnych pasów.
  else if AFullScreen and AStretch then
  begin
    zgl_Enable(CORRECT_RESOLUTION);
    zgl_Disable(CORRECT_WIDTH);
    zgl_Disable(CORRECT_HEIGHT);

    scr_CorrectResolution(RESOLUTION_X, RESOLUTION_Y);
    scr_SetOptions(zgl_Get(DESKTOP_WIDTH), zgl_Get(DESKTOP_HEIGHT), REFRESH_MAXIMUM, True, False);
  end
  else
  // okno
  begin
    zgl_Disable(CORRECT_RESOLUTION);
    scr_SetOptions(RESOLUTION_X, RESOLUTION_Y, REFRESH_MAXIMUM, False, False);
  end;
end;


{ ----- end implementation----------------------------------------------------------------------------------------- }


end.

