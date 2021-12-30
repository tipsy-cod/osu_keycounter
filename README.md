# osu! KeyCounter (written in AutoHotkey)

[![osu_keycounter](https://raw.githubusercontent.com/tipsy-cod/osu_keycounter/master/osu_keycounter.png)](https://github.com/tipsy-cod/osu_keycounter)


## osu! (is a free-to-win rhythm game)
[Download](https://osu.ppy.sh/home/) osu! here  
osu!'s [Forum](https://osu.ppy.sh/community/forums)  
osu! on [GitHub](https://github.com/ppy/osu)


## AutoHotkey (is a free scripting language for desktop automation)
[Download](https://www.autohotkey.com/download/) AutoHotkey here (v2 needed for this script)  
AutoHotkey's [Forum](https://www.autohotkey.com/boards/)  
AutoHotkey on [GitHub](https://github.com/Lexikos/AutoHotkey_L)


## HowTo
1. Download this script `osu_keycounter.ahk`
2. Download `AutoHotkey.exe`
3. Rename `AutoHotkey.exe` to `osu_keycounter.exe` (see [Portability of AutoHotkey.exe](https://lexikos.github.io/v2/docs/Program.htm#portability)=
4. Run `osu_keycounter.exe`


## FAQ
**Question:** This Script does not detect osu!.  
**Reason:** By default, osu! is installed in the following locations: "C:\Users\<Username>\AppData\Local\osu!\". But it can also be installed somewhere else.  
**Answer:** Open the Script with Notepad (I prefer Notepad++) and fill the osu! installation path in the brakets (e.g. `OSU_PATH := "D:\somewhere_else\games\osu!"`)
