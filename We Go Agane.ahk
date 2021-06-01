#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; ===================================================================================================

ApplicationName := "We Go Agane"
VersionString := "1.2"
CoordMode, Pixel, Client
SetTitleMatchMode, 1
Menu, Tray, Add, Settings, Settings
Menu, Tray, Add, About, About

; ===================================================================================================

OpenGui:
	; Load Registry Keys
	RegRead, WorldDeletion, HKCU\Software\WeGoAgane, WorldDeletion
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	RegRead, WorldsToKeep, HKCU\Software\WeGoAgane, WorldsToKeep
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	RegRead, RunType, HKCU\Software\WeGoAgane, RunType
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	RegRead, Delay, HKCU\Software\WeGoAgane, Delay
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

    RegRead, Difficulty, HKCU\Software\WeGoAgane, Difficulty
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	RegRead, ResetHotkey, HKCU\Software\WeGoAgane, ResetHotkey
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	RegRead, FullscreenHotkey, HKCU\Software\WeGoAgane, FullscreenHotkey
	If (ErrorLevel = 1) {
        WriteDefaults()
	}

	; Separate Difficulty vars
	DiffP := Difficulty
	DiffE := Difficulty - 1
	DiffN := Difficulty - 2
	DiffH := Difficulty - 3
	ShowDiff := (RunType != 1)

	; Create GUI
	Gui, Margin, 10, 10	

	Gui, Add, GroupBox, x15 y15 w360 h185, Reset Options

	Gui, Add, Text, x50 y45, Version:
	Gui, Add, DropDownList, vRunType x105 y43 w85 gDisableDiff AltSubmit Choose%RunType%, 1.16 RSG|1.16 SSG|1.14 RSG|1.14 SSG
	Gui, Add, Text, x235 y45, Delay (ms):
	Gui, Add, Edit, w50 x300 y43
	Gui, Add, UpDown, vDelay Range50-200, %Delay%
	Gui, Add, Text, x50 y80, Hotkey:
	Gui, Add, Hotkey, x105 y77 w85 vResetHotkey, %ResetHotkey%

	Gui, Add, GroupBox, x33 y105 w180 h80, World Deletion
	Gui, Add, CheckBox, vWorldDeletion x50 y127 gDisableWTK Checked%WorldDeletion%, Delete Worlds
	Gui, Add, Text, x50 y155, Worlds to Keep:
	Gui, Add, Edit, w65 x135 y152
	Gui, Add, UpDown, vWorldsToKeep Range0-10, %WorldsToKeep%

	Gui, Add, GroupBox, x230 y80 w125 h105, Difficulty
	Gui, Add, Radio, x240 y100 vDifficulty Checked%DiffP%, Peaceful
	Gui, Add, Radio, x240 y120 Checked%DiffE%, Easy
	Gui, Add, Radio, x240 y140 Checked%DiffN%, Normal
	Gui, Add, Radio, x240 y160 Checked%DiffH%, Hard
	
	Gui, Add, Text, x17 y215, Toggle Borderless Fullscreen:
	Gui, Add, Hotkey, x167 y212 w75 vFullscreenHotkey, %FullscreenHotkey%
	
	Gui, Add, Button, w80 h25 x297 y210 gSave, Start
	Gui, Show, h245 w390, %ApplicationName% %VersionString%

	GuiControl, Enable%WorldDeletion%, Edit2
	GuiControl, Disable%ShowDiff%, Peaceful
	GuiControl, Disable%ShowDiff%, Easy
	GuiControl, Disable%ShowDiff%, Normal
	GuiControl, Disable%ShowDiff%, Hard
	return

; ===================================================================================================

Save:
	; Save UI Options to variables
	Gui, Submit

	
	; Save Registry Keys
	RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, WorldDeletion, %WorldDeletion%
	RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, WorldsToKeep, %WorldsToKeep%
	RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, RunType, %RunType%
	RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, Delay, %Delay%
	RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, Difficulty, %Difficulty%
	RegWrite, REG_SZ, HKCU\Software\WeGoAgane, ResetHotkey, %ResetHotkey%
	RegWrite, REG_SZ, HKCU\Software\WeGoAgane, FullscreenHotkey, %FullscreenHotkey%

	; Register Hotkeys
	Hotkey, %ResetHotkey%, Macro
	Hotkey, %FullscreenHotkey%, ToggleWindow
	return
	
GuiEscape:
GuiClose:
ButtonCancel:
	Gui, Destroy
	ExitApp
	return

DisableDiff:
	Gui, Submit, NoHide
	ShowDiff := (RunType != 1)
	GuiControl, Disable%ShowDiff%, Peaceful
	GuiControl, Disable%ShowDiff%, Easy
	GuiControl, Disable%ShowDiff%, Normal
	GuiControl, Disable%ShowDiff%, Hard
	return

DisableWTK:
	Gui, Submit, NoHide
	GuiControl, Enable%WorldDeletion%, Edit2
	return
	
Settings:
	Reload
	return

About:
	MsgBox, , %ApplicationName% %VersionString% - About, Macro/Application by @digilog`n`nInspired by Seedminer (@jojoe77777)`n`nThanks to @Nerdi for the previous world deletion`nidea (the reason I made this in the first place)`n`nFullscreen Borderless Toggle by @Barrow, @kon,`n@Hastarin, and @WAZAAAAA on the AHK forums
	return
	
; ===================================================================================================

Macro:
	; Init abort variables
	SetTimer, TimeOut, -6000
	Abort := 0
	RegRead, Delay, HKCU\Software\WeGoAgane, Delay

	; Magical 5Head sequence that escapes any in-world gui -> {esc}{e}{esc}{esc}
	; After this, we are always in one of 2 states: in-game pause screen, or main menu.
	Send, {Escape}
	Sleep, 4
	Send, E
	Sleep, 4
	Send, {Escape}
	Sleep, 4
	Send, {Escape}
	Sleep, %Delay%

	; If we are in the pause menu, save and quit, then wait
	if (CheckForVersionText() = 0) {
		Send, +{Tab}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%

		Loop {
			if (Abort = 1) {
				return
			}

			if (CheckForVersionText() = 1) {
				break
			}
			Sleep, %Delay%
		}
	}

	; Now we are always in the main menu. Select singleplayer and wait.
	Send, +{Tab}
	Sleep, %Delay%
	Send, {Tab}
	Sleep, %Delay%
	Send, {Enter}
	Sleep, %Delay%

	Loop {
		if (Abort = 1) {
			return
		}

		if (CheckForWorldSelectionScreen() = 1) {
			break
		}
		Sleep %Delay%
	}

	if (RunType = 3 || RunType = 4) {
		Send, {Tab}
	}

	; If we want to delete a world, filter out any practice worlds, then delete the nth world.
	; Finally, un-filter the worlds (for edge-case compatibility because I'm lazy)
	if (WorldDeletion = 1) {
		Send, new world
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Down %WorldsToKeep%}
		Sleep, %Delay%
		Send, {Tab 4}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%

		Loop {
			if (Abort = 1) {
				return
			}

			if (CheckForWorldSelectionScreen() = 1) {
				break
			}
			Sleep, %Delay%
		}

		if (RunType = 3 or RunType = 4) {
			Send, {Tab}
		}

		Send, {BackSpace 9}
		Sleep, %Delay%		
	}

	if (RunType = 1) { ; 1.16 RSG
		; Select "Create New World", select specified difficulty, then create the world
		Send, {Tab 3}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%
		Send, {Tab 2}
		Sleep, %Delay%

		Switch Difficulty
		{
		Case 4:
			Send, {Space}
			Sleep, %Delay%
		Case 1:
			Send, {Space}
			Sleep, %Delay%
			Send, {Space}
			Sleep, %Delay%
		Case 2:
			Send, {Space}
			Sleep, %Delay%
			Send, {Space}
			Sleep, %Delay%
			Send, {Space}
			Sleep, %Delay%
		}

		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Enter}
	} else if (RunType = 2) { ; 1.16 SSG
		; Select previous world, then "Re-create", then create the world
		Send, {Tab}
		Sleep, %Delay%
		Send, {Up}
		Sleep, %Delay%
		Send, {Tab 5}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%
		Send, {Enter}
	} else if (RunType = 3) { ; 1.14 RSG
		; Select "Create New World", then create the world
		Send, {Tab 3}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab}
		Sleep, %Delay%
		Send, {Enter}
	} else if (RunType = 4) { ; 1.14 SSG
		; Select previous world, then "Re-create", then create the world
		Send, {Tab}
		Sleep, %Delay%
		Send, {Tab 5}
		Sleep, %Delay%
		Send, {Enter}
		Sleep, %Delay%
		Send, {Enter}
	}

	SetTimer, TimeOut, Off
	return

TimeOut:
	Abort := 1
	return

; ===================================================================================================

; Look in the bottom corner of the screen for a pixel colored #FCFCFC (Only exists on the main menu)
CheckForVersionText() {
	rect := WindowGetRect()
	PixelSearch, Px, Py, 5, rect.height - 35, 35, rect.height - 5, 0xFCFCFC, 0, Fast
	if (ErrorLevel) {
		PixelSearch, Px, Py, 5, rect.height - 35, 35, rect.height - 5, 0xFFFFFF, 0, Fast
	if (ErrorLevel) {
		return 0
	} else {
		return 1
	}
	} else {
		return 1
	}
}

; Checks for the black text box on world selection screen
CheckForWorldSelectionScreen() {
	rect := WindowGetRect()
	PixelGetColor, color, rect.width / 2, rect.height / 10
	if (color = 0x000000) {
		return 1
	}
	return 0
}				

; Get dimensions of window
WindowGetRect() {
	if hwnd := WinExist("Minecraft") {
        VarSetCapacity(rect, 16, 0)
        DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rect)
        return {width: NumGet(rect, 8, "Int"), height: NumGet(rect, 12, "Int")}
    }
}

; Write Registry Default values
WriteDefaults() {
    RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, WorldDeletion, 0
    RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, WorldsToKeep, 5
    RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, Delay, 70
    RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, RunType, 1
    RegWrite, REG_DWORD, HKCU\Software\WeGoAgane, Difficulty, 2
    RegWrite, REG_SZ, HKCU\Software\WeGoAgane, ResetHotkey, F6
    RegWrite, REG_SZ, HKCU\Software\WeGoAgane, FullscreenHotkey, F7
    Reload
    return
}

; ===================================================================================================

ToggleWindow:
	Toggle_Window(WinExist("Minecraft"))
	return

; Nothing below this comment is my code. Credit to Barrow, kon, Hastarin, and WAZAAAAA

/*  YABT+ - Yet Another Borderless-Window Toggle
 *  by Barrow (March 30, 2012)
 *  rewritten by kon (May 16, 2014)
 *  http://www.autohotkey.com/board/topic/78903-yabt-yet-another-borderless-window-toggle/page-2#entry650488
 *  updated by Hastarin (Dec 5, 2014)
 *  updated by WAZAAAAA (Sep 27, 2016)
 *  tested with AutoHotkey v1.1.24.01
 */

Toggle_Window(Window:="") {
	static A := Init()
	if (!Window)
		MouseGetPos,,, Window
	WinGet, S, Style, % (i := "_" Window) ? "ahk_id " Window :  ; Get window style
	if (S & +0xC00000) {                                        ; If not borderless
		WinGet, IsMaxed, MinMax,  % "ahk_id " Window
	if (A[i, "Maxed"] := IsMaxed = 1 ? true : false)
		WinRestore, % "ahk_id " Window
	WinGetPos, X, Y, W, H, % "ahk_id " Window               ; Store window size/location
	for k, v in ["X", "Y", "W", "H"]
		A[i, v] := %v%
	Loop, % A.MCount {                                      ; Determine which monitor to use
		if (X >= A.Monitor[A_Index].Left
			&&  X <  A.Monitor[A_Index].Right
	&&  Y >= A.Monitor[A_Index].Top
	&&  Y <  A.Monitor[A_Index].Bottom) {
		WinSet, Style, -0xC00000, % "ahk_id " Window    ; Remove borders
		WinSet, Style, -0x40000, % "ahk_id " Window    ; Including the resize border
		WinSet, ExStyle, -0x00000200, % "ahk_id " Window ;Also WS_EX_CLIENTEDGE
		; The following lines are the x,y,w,h of the maximized window
		; ie. to offset the window 10 pixels up: A.Monitor[A_Index].Top - 10
		WinMove, % "ahk_id " Window,
		, A.Monitor[A_Index].Left                               ; X position
		, A.Monitor[A_Index].Top                                ; Y position
		, A.Monitor[A_Index].Right - A.Monitor[A_Index].Left    ; Width
		, A.Monitor[A_Index].Bottom - A.Monitor[A_Index].Top    ; Height
		break
	}
}
}
else if (S & -0xC00000) {                                           ; If borderless
	WinSet, Style, +0x40000, % "ahk_id " Window    		; Reapply borders
WinSet, Style, +0xC00000, % "ahk_id " Window
WinSet, ExStyle, +0x00000200, % "ahk_id " Window ;Also WS_EX_CLIENTEDGE
WinMove, % "ahk_id " Window,, A[i].X, A[i].Y, A[i].W, A[i].H    ; Return to original position
if (A[i].Maxed)
	WinMaximize, % "ahk_id " Window
A.Remove(i)
}
}

Init() {
	A := {}
	SysGet, n, MonitorCount
	Loop, % A.MCount := n {
		SysGet, Mon, Monitor, % i := A_Index
		for k, v in ["Left", "Right", "Top", "Bottom"]
			A["Monitor", i, v] := Mon%v%
	}
	return A
}