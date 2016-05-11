unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    HotkeyControl1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure HotkeyControl1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    HotKey1:Integer;
    Restore:Boolean;
    LastActive:HWND;

    Procedure MinimizeWindows;
    Procedure RestoreWindows;
    procedure WMHotKey(var Msg : TWMHotKey); message WM_HOTKEY;


  end;

var
  Form1: TForm1;

implementation


function PointToStr(p: TPoint): String;
begin
      Result:=Inttostr(p.X)+','+inttostr(p.Y);
end;

Function PosBackwards(const source,Mask:String;StartIndex:Integer;CaseSensitive:Boolean):Integer;
var
  ws,wsource,wmask:String;
  wsl:Integer;
  i:integer;
  ts:String;
begin
    Result:=0;
    wsl:=Length(Source);
    if wsl<1 then exit;
    if Mask='' then exit;
    if StartIndex<1 then exit;
    if caseSensitive then
    begin
        wsource:=Source;
        wmask:=Mask
    end else
    begin
        wSource:=AnsiUpperCase(Source);
        wMask:=AnsiUpperCase(mask);
    end;
    ws:='';

    ts:='';
    For i:=Length(Mask) downto 1 do ts:=ts+WMask[i];

    for i:=StartIndex downto 1 do
    begin
         ws:=ws+wsource[i];
    end;

    i:=pos(ts,ws);
    if i>0 then
    begin
        if Length(mask)>1 then
        result:=wsl-(Length(mask)-i) else Result:=wsl;
    end else result:=0;
end;
Function IsSubstringAt(source:String;atPos:integer;Mask:String;CaseSensitive:boolean):Boolean;
var
    SourceP,MaskP:PChar;
    sourceL,maskl:integer;
    i:integer;
begin
   result:=false;
   if source='' then exit;
   if mask='' then exit;
   if atpos<1 then exit;

   SourceL:=Length(Source);
   MaskL:=Length(mask);
   if atpos>SourceL-maskL+1 then exit;

   SourceP:=@Source[atpos];
   MaskP:=@Mask[1] ;

   result:=true; //now we can only fail and set false;
   for i:=1 to maskL do
   begin
        case CaseSensitive of
        True : Begin
                    if sourcep^<>maskp^ then
                    begin
                        result:=false;
                        break;
                    end;
                    inc(sourcep);
                    inc(maskp);
               end;
        False:Begin
                   if AnsiUpperCase(SourceP^)<>ansiuppercase(Maskp^) then
                   begin
                        result:=false;
                        break;
                   end;
                   inc(sourceP);
                   inc(maskP);
              end;
        end;//of case
   end;


end;

Function CountSubStrings(Source,mask:String;CaseSensitive:Boolean):Integer;
var
  ss,ms:String;
  sl,ml,si:Integer;
  sp,mp:PChar;
  RS:String;
begin
    result:=0;
    if source='' then Exit;
    if mask='' then exit;

    if not CaseSensitive then
    begin
        ss:=AnsiUppercase(source);
        ms:=AnsiUppercase(Mask);
    end else
    begin
      ss:=Source;
      ms:=Mask;
    end;


    sl:=Pos(ms,ss);
    rs:=ss;
    While sl=1 do
    begin
         rs:=Copy(rs,2,length(rs));
         sl:=pos(ms,rs);
    end;
    ss:=rs;

    sl:=PosBackwards(rs,ms,length(rs),False);
    While sl=Length(rs) do
    begin
          if rs='' then Break;
          if rs[Length(rs)]<>ms then break;
          if sl=1 then
          begin
              rs:='';
              Result:=0;
              Exit;
          end;

          rs:=Copy(rs,1,sl-1);
          sl:=PosBackwards(rs,ms,length(rs),false);
    end;
    ss:=rs;
    if rs='' then exit;



    sl:=Length(Ss);
    ml:=Length(mask);
    Si:=0;

    Result:=0;
    While si<sl do
    begin
        if IsSubStringAt(ss,si+1,ms,CaseSensitive) then
        begin
             inc(Result);
             While IsSubStringat(ss,si+1,ms,casesensitive) do
                   si:=si+ml;

             if si<sl then inc(result)
        end else
        begin
          inc(si);
        end;
    end;
    if Result=0 then Result:=1;

end;

function GrabSubString(Source,Mask:String;Index:integer;CaseInsensitive:Boolean;var Offset:Integer):String;
var
    wString,WMask:String;
    wStringP,wMaskP:PChar;
    OrigSourcep:PWideChar;

    wIndex:Integer;
    i,SourceL,MaskL,FindIndex,MatchCount:integer;

    MaxC:Integer;

    cMaskPos:integer;
    Function MatchMask:Boolean;
    var
        i:integer;
        oSourcep:PWideChar;
        OChar,MaskChar:Char;
    begin
          oSourcep:=wStringP;
          result:=False;
          try
             wmaskp:=@wMask[1];
             for i:=1 to length(wmask) do
             begin
                  OChar:=String(wStringp^)[1];
                  MAskChar:=String(WMaskp^)[1];
                  if MaskChar <> OChar then
                  begin
                        wStringP:=oSourceP;
                        result:=false;
                        exit;
                  end;

                  inc(wmaskp);
                  inc(wStringp);
             end;

             result:=True;

          except on exception do begin wStringp:=oSourceP; result:= false; end;
          end;
          wStringP:=OSourceP;
    end;

begin
    wString:=Source;
    wMask:=Mask;
    if CaseInsensitive then
    begin
        wString:=AnsiUppercase(wString);
        wMask:=AnsiUppercase(wMask);
    end;
    result:=Source; //not the uppercased wSource

    if mask='' then exit;

    cMaskPos:=Pos(wMask,wString);
    if cMaskPos<1 then exit;

    MaxC:=CountSubStrings(Source,mask,not CaseInSensitive);
    if index>MaxC then exit('');


    wStringP:=@wString[1];
    wMaskP:=@wMask[1];
    SourceL:=Length(wString);
    maskL:=Length(wMask);

    FindIndex:=Index;
    if Index<=0 then FindIndex:=1;

  //hello TEST world TEST of
  // 1           2        3
  //TEST hello TEST world TEST of
  //      1           3        3
  //hello TESTTEST world of TEST gielinor
  // 1               2             3

    MatchCount:=1;
    origSourcep:=@Source[1];
    result:='';
    i:=1;
    //strip any leading instances of mask
     if MatchMask then
     Repeat
                i:=i+1;
                inc(wStringP,MaskL);//,MaskL);
                inc(origSourceP,MaskL);//,MaskL);
     until not MatchMask;


    While i <= SourceL  do
    begin
          if MatchMask=false then //Something other than Mask is at our position
          begin
                if MatchCount = FindIndex then
                begin
                     Offset:=i;
                     //now we will stream OrigSourceP to result until another matchmask, exception or string end;
                     try
                     repeat
                         result:=Result+OrigSourceP^;

                         inc(i);
                         inc(OrigSourcep);
                         inc(wStringP);


                     until (matchmask) or (i>SourceL);

                           if matchmask then
                           begin
                              Inc(OrigSourceP,MaskL);
                              inc(wStringP,Maskl);
                              inc(i,MaskL);
                              inc(i,SourceL);
                              inc(MatchCount);
                           end

                     except on exception do begin end;
                     end;

                end else begin
                         inc(wStringP);
                         inc(OrigSourceP);
                         inc(i);
                         end;

          end else
          begin

               if not MatchMask then
               Repeat
                i:=i+1;
                inc(wStringP);//,MaskL);
                inc(origSourceP);//,MaskL);
               until (not MatchMask) {or (i>SourceL)};
               if (i<=SourceL) and (MaskL>0) then
               begin
                   i:=i+MaskL;
                   inc(WStringP,MaskL);
                   inc(OrigSourceP,MaskL);
               end;
               inc(matchcount);
          end;


    end;

end;

Function IsAltTabWindow(wnd:HWND):Boolean;
var
  hwndwalk:HWND;
  HwndTry:HWND;

begin
    hwndwalk:= GetAncestor(wnd,ga_Rootowner);
    hwndtry:=GetLastActivePopup(hwndWalk);
    while (GetLastActivePopup(hwndwalk) <> hwndTry )  do
    begin
          if IsWindowVisible(hwndtry) then break;
          hwndWalk:=hwndTry;
          hwndtry:=GetLastActivePopup(hwndWalk)
    end;
    result:=hwndwalk=wnd;
end;
Function AllAltTabHWNDS_Callback(wHnd: THandle; List: TList): Bool; stdcall;
var
  tl:Integer;
  Buffer:String;// array[0..4096] of char;
  Style:integer;
  timeoutP:Pointer;
  ts:String;
begin
      begin

       if IsAltTabWindow(wHnd) and IsWindowVisible(wHnd) then
        begin
          // ts:=buffer;
          List.Add(TObject(wHnd));
        end;

      end;
    Result := True; // continiue enumeration
end;

Function EnumerateAltTabHWNDS(Var List:TList):Integer;
Begin
EnumWindows(@AllAltTabHWNDS_Callback,lparam(List));
End;
Function FindWindowClassName(wnd:HWND):String;
var
  ts:String;
  i:integer;
begin
    SetLength(ts,1024);
    GetClassName(wnd,@ts[1],1023);
    if ts='' then exit('');
    if Pos(#0,ts)>0 then ts:=Grabsubstring(ts,#0,1,True,i);
    ts:=trim(ts);
    Result:=ts;

end;

{$R *.dfm}

procedure TForm1.Close1Click(Sender: TObject);
begin
    Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
b:bool;
begin
    hotkey1 := GlobalAddAtom('MinimizeActiveDesktop');
    b:=RegisterHotKey(handle, hotkey1, MOD_control,$dc);
    Visible:=False;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  UnregisterHotKey(Handle,Hotkey1);
end;

procedure TForm1.HotkeyControl1Click(Sender: TObject);
var
  ms:TWMHotkey;
begin
      Self.WMHotKey(ms);
end;

procedure TForm1.MinimizeWindows;
var
  tsl:TList;
  i:integer;

  MyMon,testMon:TMOnitor;
  hw:HWND;
  MyPID:Cardinal;
  PID:Cardinal;
  ts:String;
begin

// hw:=WinApi.Windows.GetDesktopWindow;
// SendMessage(hw,wm_keydown,

  tsl:=Tlist.Create;
  //Commonfunctions.EnumerateAltTabWindows(tsl);
  EnumerateAltTabHWNDS(tsl);

//  Winapi.Windows.GetWindowThreadProcessId(Handle,MyPID);
//  MyMon:=Screen.MonitorFromWindow(Handle);

  hw:=Winapi.Windows.GetForegroundWindow;
  LastActive:=hw;

  mymon:=Screen.MonitorFromWindow(hw);


   if tsl.Count>0 then for i:=0 to tsl.Count -1 do
   begin
        hw:=HWND(tsl[i]);

        TestMon:=screen.MonitorFromWindow(hw);
        if myMon<>TestMon then continue;

        ts:=FindWindowClassName(hw);
        if pos('SHELL',AnsiUppercase(ts))>0 then Continue;

        ShowWindow(hw,sw_minimize);

   end;

   Restore:=True;

   tsl.Free;
end;


procedure TForm1.RestoreWindows;
var
  tsl:TList;
  i:integer;

  MyMon,testMon:TMOnitor;
  hw:HWND;
  MyPID:Cardinal;
  PID:Cardinal;
  ts:String;
begin
  tsl:=Tlist.Create;
  EnumerateAltTabHWNDS(tsl);

  hw:=Winapi.Windows.GetActiveWindow;
  if IsWindow(LastActive) then hw:=LastActive;
  mymon:=Screen.MonitorFromWindow(hw);


   if tsl.Count>0 then for i:=0 to tsl.Count -1 do
   begin
        hw:=HWND(tsl[i]);

        if hw=Handle then continue;

        TestMon:=screen.MonitorFromWindow(hw);
        if myMon<>TestMon then continue;

        ts:=FindWindowClassName(hw);
        if pos('SHELL',AnsiUppercase(ts))>0 then Continue;

        ShowWindow(hw,sw_Restore);

   end;


   Restore:=False;

   if IsWindow(LastActive) then
   begin
      Winapi.Windows.SetForegroundWindow(LastActive);
      Winapi.Windows.SetFocus(LaStActive);
      Winapi.Windows.BringWindowToTop(LastActive);

   end;
   tsl.Free;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    Hide;
    Timer1.Enabled:=False;
end;

procedure TForm1.WMHotKey(var Msg: TWMHotKey);
begin
    if Restore then
    begin
           self.RestoreWindows;
    end else
    MinimizeWindows;
end;

end.
