program bomberman;

{$mode objfpc}{$H+}

uses
  zglHeader, TMenuClass, BasicTypes, TGameClass, TTextureManagerClass;


{ ----- global constant ------------------------------------------------------------------------------------------- }


const
  INPUT_TIMER_INTERVAL = 64;
  LOGIC_TIMER_INTERVAL = 128;


{ ----- global variables ------------------------------------------------------------------------------------------ }


var
  Game : TGame;


{ ----- init, draw, quit ------------------------------------------------------------------------------------------ }


procedure Init();
begin
  Game := TGame.Create;
end;


procedure Draw();
begin
  wnd_SetCaption('Bomberman dev 0.2 FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)));

  Game.Draw;
end;


procedure Quit();
begin
  Game.Free;
end;


{ ----- timers ---------------------------------------------------------------------------------------------------- }


procedure Timer_Input();
begin
  if key_Press(key_Last(KA_DOWN)) then // bez tego ifa jakieś cuda się dzieją O.o
    Game.Input(key_Last(KA_DOWN));

  key_ClearState();
end;


procedure Timer_Logic();
begin
  Game.Logic;
end;


{ ----- main block ------------------------------------------------------------------------------------------------ }


begin
  SetPath();
  if not zglLoad(libZenGL) then Exit();

  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_DRAW, @Draw);
  zgl_Reg(SYS_EXIT, @Quit);

  Timer_Add(@Timer_Input, INPUT_TIMER_INTERVAL);
  Timer_Add(@Timer_Logic, LOGIC_TIMER_INTERVAL);

  wnd_ShowCursor(False);

  zgl_Init();
end.

