program AddRegKey;
uses Registry;

procedure AddKey();
var
  Registry : TRegistry;
begin
  Registry := TRegistry.Create();
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    Registry.CreateKey('SOFTWARE\Bomberman');
    Registry.OpenKey('SOFTWARE\Bomberman', true);
    Registry.WriteString('Path', 'E:\Moje\Programowanie\Lazarus\Bomberman dev 0.2');
  finally
    Registry.Free();
  end;
end;

begin
  Write('Dodawanie klucza do rejestru...');
  AddKey();
  Writeln('Zakończono. Naciśnij ENTER by zakończyć');
  Readln;
end.

