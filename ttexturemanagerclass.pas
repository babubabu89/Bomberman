unit TTextureManagerClass;

{$mode objfpc}{$H+}


{ ----- interface ------------------------------------------------------------------------------------------------- }


interface

uses
  zglHeader, BasicTypes, Classes, SysUtils;

{ ----- global types ---------------------------------------------------------------------------------------------- }





{ ----- classes --------------------------------------------------------------------------------------------------- }


type
  TTexturesInfo = class
    private
      FMonstersQuantity: uInt8;
      FMonsterTexturePath : array of string;
      FWallTexturePath: array[0..5] of string;
      FFireTexturePath: string;
      FBonusTexturePath: string;
      FPlayerTexturePath: string;
    private
      procedure ClearPaths();
    public
      constructor Create();
      destructor Destroy(); override;
    public
      procedure LoadTexturesInfo(AFileName: string);
    public
      function MonsterTexturePath(AIndex: uInt8): string;
      function WallTexturePath(AIndex: uInt8): string;
      function FireTexturesPath(): string;
      function BonusTexturePath(): string;
      function PlayerTexturePath(): string;
    public
      property MonstersQuantity : uInt8 read FMonstersQuantity;
  end;


type
  TTexture = class
    private
      FTexture: zglPTexture;
    public
      constructor Create(AFilename: String; AAnimated: Boolean);
      destructor Destroy(); override;
    property
      GetTexture : zglPTexture read FTexture;
  end;


type
  TTextureManager = class
    private
      FTexturesInfo: TTexturesInfo;
      FMonsterTexture: array of TTexture;
      FWallTexture: array[0..5] of TTexture;
      FFireTexture: TTexture;
      FBonusTexture: TTexture;
      FPlayerTexture: TTexture;
    private
      procedure GetInfo(AFileName: string);
    public
      constructor Create();
      destructor Destroy(); override;
    public
      procedure LoadTextures();
      procedure FreeTextures();
    end;


implementation


{ ----- TTexturesInfo class --------------------------------------------------------------------------------------- }

constructor TTexturesInfo.Create();
begin
  inherited Create();
end;


destructor TTexturesInfo.Destroy();
begin
  ClearPaths;

  inherited Destroy();
end;


procedure TTexturesInfo.ClearPaths();
begin
  SetLength(FMonsterTexturePath, 0);
  FFireTexturePath := '';
  FBonusTexturePath := '';
  FPlayerTexturePath := '';
end;


procedure TTexturesInfo.LoadTexturesInfo(AFileName: string);
begin
  // TODO: Zrobić przykładowy plik i zaimplementować ładowanie
end;


function TTexturesInfo.MonsterTexturePath(AIndex: uInt8): string;
begin
  result := FMonsterTexturePath[AIndex];
end;


function TTexturesInfo.WallTexturePath(AIndex: uInt8): string;
begin
  result := FWallTexturePath[AIndex];
end;


function TTexturesInfo.FireTexturesPath(): string;
begin
  result := FFireTexturePath;
end;


function TTexturesInfo.BonusTexturePath(): string;
begin
  result := FBonusTexturePath;
end;


function TTexturesInfo.PlayerTexturePath(): string;
begin
  result := FPlayerTexturePath;
end;


{ ----- TTexture class -------------------------------------------------------------------------------------------- }


constructor TTexture.Create(AFilename: String; AAnimated: Boolean);
begin
  inherited Create();

  FTexture := tex_LoadFromFile(AFilename);
  if AAnimated then
    tex_SetFrameSize(FTexture, FRAME_SIZE_X, FRAME_SIZE_Y);
end;


destructor TTexture.Destroy();
begin
   tex_Del(FTexture);

  inherited Destroy();
end;


{ ----- TTextureManager class ------------------------------------------------------------------------------------- }


constructor TTextureManager.Create();
begin
  inherited Create();

  FTexturesInfo := TTexturesInfo.Create();
end;


destructor TTextureManager.Destroy();
begin
  FreeTextures();

  inherited Destroy();
end;


procedure TTextureManager.GetInfo(AFileName: string);
begin
  FTexturesInfo.LoadTexturesInfo(AFileName);
  SetLength(FMonsterTexture, FTexturesInfo.FMonstersQuantity);
end;


procedure TTextureManager.LoadTextures();
var
  i: uInt8;
begin
  for i := Low(FMonsterTexture) to High(FMonsterTexture) do
    FMonsterTexture[i] := TTexture.Create(FTexturesInfo.FMonsterTexturePath[i], true);

  for i := Low(FWallTexture) to High(FWallTexture) do
    FWallTexture[i] := TTexture.Create(FTexturesInfo.FWallTexturePath[i], true);

  FFireTexture := TTexture.Create(FTexturesInfo.FFireTexturePath, true);
  FBonusTexture := TTexture.Create(FTexturesInfo.FBonusTexturePath, true);
  FPlayerTexture := TTexture.Create(FTexturesInfo.FPlayerTexturePath, true);
end;


procedure TTextureManager.FreeTextures();
var
  i : uInt8;
begin
  for i := Low(FMonsterTexture) to High(FMonsterTexture) do
    FreeAndNil(FMonsterTexture[i]);

  for i := Low(FWallTexture) to High(FWallTexture) do
    FreeAndNil(FWallTexture[i]);

  FreeAndNil(FFireTexture);
  FreeAndNil(FBonusTexture);
  FreeAndNil(FPlayerTexture);
end;

{ ----- end implementation----------------------------------------------------------------------------------------- }


end.

