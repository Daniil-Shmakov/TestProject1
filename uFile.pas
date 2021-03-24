{ ���� ������� ��� ������ � ������ - �������� �������� ����� }

unit uFile;

interface

uses
  SysUtils, Classes, StrUtils, IOUtils;

procedure DeleteLine(StrList: TStringList; MaxTime: TDateTime);
procedure DeleteLineWithStringList(Filename : string; MaxTime: TDateTime);

implementation

// ������� ������ �� ������, ��� ����� ������ ��������� � MaxTime
procedure DeleteLine(StrList: TStringList; MaxTime: TDateTime);
var
  Index : Integer;
  DT : TDateTime;
begin
 for Index := StrList.Count-1 downto 0 do
  begin
  // �������� ����/����� �� ������ (��������� 20 ��������)
  // ��, �������, �� ����������� ������� ������ �����
    DT := StrToDateTime(RightStr(StrList[Index], 20));
    if DT <= MaxTime then
       StrList.Delete(Index);
  end;
end;

// ������� �� ����� ������, ��� ����� ������ ��������� � MaxTime
procedure DeleteLineWithStringList(Filename : string; MaxTime: TDateTime);
var StrList : TStringList;
begin
 StrList := TStringList.Create;
 try
  StrList.LoadFromFile(Filename);
  DeleteLine(StrList, MaxTime);
  StrList.SaveToFile(Filename);
 finally
  StrList.Free;
 end;
end;

end.
