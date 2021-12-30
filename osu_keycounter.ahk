; SCRIPT DIRECTIVES =====================================================================================================================================================

#Requires AutoHotkey v2.0-

#SingleInstance
OnExit SaveIni


; GLOBALS ===============================================================================================================================================================

OSU_PATH  := ""   ; <- osu! path here is not installed under "C:\Users\<Username>\AppData\Local\osu!\"


; INI ===================================================================================================================================================================

KEY_LEFT  := 0
KEY_RIGHT := 0
OLD_LEFT  := Number(IniRead("osu_keycounter.ini", "KeyCount", "keyOsuLeft", 0))
OLD_RIGHT := Number(IniRead("osu_keycounter.ini", "KeyCount", "keyOsuRight", 0))
NEW_LEFT  := OLD_LEFT
NEW_RIGHT := OLD_RIGHT


; INIT ==================================================================================================================================================================

OSU_KEYS := GetOsuKeys(OSU_PATH)


; GUI ===================================================================================================================================================================

hFBFBFB := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xfbfbfb, "Ptr")
hDCDCDC := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xdcdcdc, "Ptr")

OnMessage 0x0111, EN_SETFOCUS

Main := Gui()
Main.MarginX := 15
Main.MarginY := 15
Main.SetFont("s20 w600", "Segoe UI")
Main.AddText("xm ym w300 0x201", "osu! KeyCounter")

Main.SetFont("s10 w400", "Segoe UI")
Main.AddPicture("xm   ym+54 w302 h97 BackgroundTrans", "HBITMAP:*" hDCDCDC)
Main.AddPicture("xm+1 ym+55 w300 h95 BackgroundTrans", "HBITMAP:*" hFBFBFB)

Main.AddText("xm+16 ym+70 w20 h25 0x200 BackgroundFBFBFB", "Left:")
EDL1 := Main.AddEdit("x+5 yp w100 0x802 BackgroundE4E8F8", 0)
EDL2 := Main.AddEdit("x+5 yp w140 0x802 BackgroundE4E8F8", GetNumberFormatEx(OLD_LEFT))

Main.AddText("xm+16 y+15 w20 h25 0x200 BackgroundFBFBFB", "Right:")
EDR1 := Main.AddEdit("x+5 yp w100 0x802 BackgroundE4E8F8", 0)
EDR2 := Main.AddEdit("x+5 yp w140 0x802 BackgroundE4E8F8", GetNumberFormatEx(OLD_RIGHT))

Main.OnEvent("Close", Gui_Close)
Main.Show()


; KEYBD HOOK ============================================================================================================================================================

A_HotkeyInterval := 0
HotIfWinActive "ahk_exe notepad++.exe"
Hotkey "~*" OSU_KEYS["Left"],  OnKeyPressed
Hotkey "~*" OSU_KEYS["Right"], OnKeyPressed
HotIfWinActive


; WINDOW EVENTS =========================================================================================================================================================

Gui_Close(*)
{
	if (hDCDCDC)
		DllCall("gdi32\DeleteObject", "ptr", hDCDCDC)
	if (hFBFBFB)
		DllCall("gdi32\DeleteObject", "ptr", hFBFBFB)
	SaveIni()
	ExitApp
}


; FUNCTIONS =============================================================================================================================================================

OnKeyPressed(ThisHotkey)
{
	global KEY_LEFT,  OLD_LEFT,  NEW_LEFT
	global KEY_RIGHT, OLD_RIGHT, NEW_RIGHT
	global OSU_KEYS

	KeyWait SubStr(ThisHotkey, 3)
	switch SubStr(ThisHotkey, 3)
	{
		case OSU_KEYS["Left"]:
			EDL1.Value := GetNumberFormatEx(++KEY_LEFT)
			EDL2.Value := GetNumberFormatEx(NEW_LEFT := OLD_LEFT + KEY_LEFT)
		case OSU_KEYS["Right"]:
			EDR1.Value := GetNumberFormatEx(++KEY_RIGHT)
			EDR2.Value := GetNumberFormatEx(NEW_RIGHT := OLD_RIGHT + KEY_RIGHT)
	}
}


EN_SETFOCUS(wParam, lParam, *)
{
	static EM_SETSEL   := 0x00B1
	static EN_SETFOCUS := 0x0100

	if ((wParam >> 16) = EN_SETFOCUS)
	{
		DllCall("user32\HideCaret", "Ptr", lParam)
		PostMessage EM_SETSEL, -1, 0,, "ahk_id " lParam
	}
}


GetNumberFormatEx(Value, LocaleName := "!x-sys-default-locale")
{
	if (Size := DllCall("kernel32\GetNumberFormatEx", "str", LocaleName, "uint", 0, "str", Value, "ptr", 0, "ptr", 0, "int", 0))
	{
		Size := VarSetStrCapacity(&NumberStr, Size)
		if (DllCall("kernel32\GetNumberFormatEx", "str", LocaleName, "uint", 0, "str", Value, "ptr", 0, "str", NumberStr, "int", Size))
			return SubStr(NumberStr, 1, -3)
	}
	return ""
}


GetOsuKeys(OsuPath := "")
{
	OsuPath := (OsuPath) ? OsuPath : EnvGet("LOCALAPPDATA") "\osu!"

	try
		DirExist(OsuPath)
	catch as Err
	{
		MsgBox("Can't find osu! path`n`n" Type(Err) ": " Err.Message)
		return
	}

	try
		FileExist(OsuPath "\osu!." StrReplace(A_UserName, ".", "") ".cfg")
	catch as Err
	{
		MsgBox("Can't find osu! config`n`n" Type(Err) ": " Err.Message)
		return
	}

	try
		hFile := FileOpen("osu!." StrReplace(A_UserName, ".", "") ".cfg", "r")
	catch as Err
	{
		MsgBox("Can't open osu! config`n`n" Type(Err) ": " Err.Message)
		return
	}

	OsuKeys := Map("Left", "", "Right", "")
	while !(hFile.AtEOF)
	{
		if (InStr(GetConfigLine := hFile.ReadLine(), "keyOsuLeft"))
		{
			OsuKeys["Left"]  := StrLower(SubStr(GetConfigLine, -1))
		}
		if (InStr(GetConfigLine := hFile.ReadLine(), "keyOsuRight"))
		{
			OsuKeys["Right"] := StrLower(SubStr(GetConfigLine, -1))
		}
	}
	hFile.Close()
	return OsuKeys
}


; ON EXIT ===============================================================================================================================================================

SaveIni(*)
{
	global NEW_LEFT
	global NEW_RIGHT

	IniWrite NEW_LEFT,  "osu_keycounter.ini", "KeyCount", "keyOsuLeft"
	IniWrite NEW_RIGHT, "osu_keycounter.ini", "KeyCount", "keyOsuRight"
}


; =======================================================================================================================================================================
