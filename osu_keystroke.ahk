; SCRIPT DIRECTIVES =====================================================================================================================================================

#Requires AutoHotkey v2.0-

#SingleInstance
OnExit SaveIni


; GLOBALS ===============================================================================================================================================================

KEY_X := 0
KEY_Y := 0
OLD_X := Number(IniRead("osu_keystroke.ini", "KeyCount", "Key_X", 0))
OLD_Y := Number(IniRead("osu_keystroke.ini", "KeyCount", "Key_Y", 0))
NEW_X := OLD_X
NEW_Y := OLD_Y


; GUI ===================================================================================================================================================================

hFBFBFB := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xfbfbfb, "Ptr")
hDCDCDC := DllCall("gdi32\CreateBitmap", "Int", 1, "Int", 1, "UInt", 0x1, "UInt", 32, "Int64*", 0xdcdcdc, "Ptr")

OnMessage 0x0111, EN_SETFOCUS

Main := Gui()
Main.MarginX := 15
Main.MarginY := 15
Main.SetFont("s20 w600", "Segoe UI")
Main.AddText("xm ym w300 0x201", "Osu KeybdHook")

Main.SetFont("s10 w400", "Segoe UI")
Main.AddPicture("xm   ym+54 w302 h97 BackgroundTrans", "HBITMAP:*" hDCDCDC)
Main.AddPicture("xm+1 ym+55 w300 h95 BackgroundTrans", "HBITMAP:*" hFBFBFB)

Main.AddText("xm+16 ym+70 w20 h25 0x200 BackgroundFBFBFB", "X:")
EDX1 := Main.AddEdit("x+5 yp w100 0x802 BackgroundE4E8F8", 0)
EDX2 := Main.AddEdit("x+5 yp w140 0x802 BackgroundE4E8F8", GetNumberFormatEx(OLD_X))

Main.AddText("xm+16 y+15 w20 h25 0x200 BackgroundFBFBFB", "Y:")
EDY1 := Main.AddEdit("x+5 yp w100 0x802 BackgroundE4E8F8", 0)
EDY2 := Main.AddEdit("x+5 yp w140 0x802 BackgroundE4E8F8", GetNumberFormatEx(OLD_Y))

Main.OnEvent("Close", Gui_Close)
Main.Show()


; KEYBD HOOK ============================================================================================================================================================

Hook := InputHook()
Hook.KeyOpt("{All}", "+N")
Hook.OnKeyDown      := OnKeyDown
Hook.VisibleText    := true
Hook.VisibleNonText := true
Hook.Start()


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

OnKeyDown(hk, vk, sc)
{
	global KEY_X, OLD_X, NEW_X
	global KEY_Y, OLD_Y, NEW_Y

	if (WinActive("ahk_exe osu!.exe"))
	{
		switch vk
		{
			case 88:
				EDX1.Value := GetNumberFormatEx(++KEY_X)
				EDX2.Value := GetNumberFormatEx(NEW_X := OLD_X + KEY_X)
			case 89:
				EDY1.Value := GetNumberFormatEx(++KEY_Y)
				EDY2.Value := GetNumberFormatEx(NEW_Y := OLD_Y + KEY_Y)
		}
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


; ON EXIT ===============================================================================================================================================================

SaveIni(*)
{
	global NEW_X
	global NEW_Y

	IniWrite NEW_X, "osu_keystroke.ini", "KeyCount", "Key_X"
	IniWrite NEW_Y, "osu_keystroke.ini", "KeyCount", "Key_Y"
}


; =======================================================================================================================================================================
