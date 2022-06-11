/*
	wm4k: butt-simple window management for 4k monitors
	(as of v2.2 this works for monitors of any size)

	by Roel Hammerschlag
	roel@hammerschlag.llc

	modifications and adjustments by Jeremiah Johnson
	naikrovek {at} gmail.com
	http://github.com/naikrovek/

	Version 1.0: September 2014

	Version 2.0: April 2016
		- streamline math & code
		- add NumPadMul 1/12 window
		- remove NumPad0 "tiny" window
		- compensate for transparent window borders in Windows 10

	Version 2.1: July 2016
		- add NumPadAdd & NumPadSub nudging

	Version 2.2: June 2019
		- replace hard-coded 4k dimensions with A_ScreenWidth and A_ScreenHeight
		- allow #Fnn keys in case the computer doesn't have a numpad
		- fix bug where nudge function resized the nudged window

	Version 2.3: November 2019
		- add landscape 1/3 window
		- add 2/3 window
		- robust handling of screen edges in nudge function

	Version 2.4: November 2019
	
	Version 2.5: June 2020
		- ignore +, -, and * on the numpad if numlock is on.

	Before using, set values for marginLeft etc. below to reflect
	your own Windows Taskbar size & location.

	Hotkeys are designed for NumLock OFF.
*/

SetBatchLines, -1
SetTitleMatchMode, 2
SetTitleMatchMode, fast
SetWinDelay, 10
#NoEnv
#SingleInstance force
#WinActivateForce

marginLeft := 0
marginRight := 0
marginTop := 0
marginBottom := 40

xStep := (A_ScreenWidth - marginLeft - marginRight) // 12
yStep := (A_ScreenHeight - marginTop - marginBottom) // 2

yTopRow := marginTop
yBottomRow := marginTop + yStep

topRowTest := marginTop + yStep/2


NumpadEnd::                                       ; "1" on num pad invokes full-screen window
#F1::
	WinMaximize, A
	return

NumpadDown::                                      ; "2" on num pad handles 1/2-screen windows
#F2::                                             ;  (portrait)
	width := xStep*6
	height := yStep*2
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 2)
	y := yTopRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

^NumpadDown::                                     ; CTRL+"2" on num pad handles 1/2-screen windows
^#F2::                                            ;  (landscape)
	width := xStep*12
	height := yStep
	Gosub, spyActiveWindow

	x := 0
	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

NumpadPgDn::                                      ; "3" on num pad handles 1/3-screen windows
#F3::                                             ;  (portait format)
	width := xStep * 4
	height := yStep * 2
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 3)
	y := yTopRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

^NumpadPgDn::                                     ; CTRL+"3" on num pad handles 1/3-screen windows
^#F3::                                            ;  (landscape format)
	width := xStep * 8
	height := yStep
	Gosub, spyActiveWindow

	if (x = marginLeft)
		x := marginLeft + xStep * 4
	else
		x := marginLeft

	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

^+NumpadPgDn::                                    ; CTRL+SHIFT+"3" on num pad handles 2/3-screen windows
^+#F3::                                           ;  (for laptops/small screens)
	width := xStep * 8
	height := yStep * 2
	Gosub, spyActiveWindow

	if (x = marginLeft)
		x := marginLeft + xStep * 4
	else
		x := marginLeft

	y := yTopRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

^NumpadLeft::                                     ; CTRL+"4" on num pad handles 1/4-screen windows
^#F4::                                            ;  (portrait format)
	width := xStep * 3
	height := yStep * 2
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 4)
	y := yTopRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

NumpadLeft::                                      ; "4" on num pad handles 1/4-screen windows
#F4::                                             ;  (landscape format)
	width := xStep * 6
	height := yStep
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 2)
	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

^NumpadRight::                                    ; CTRL+"6" on num pad handles 1/6-screen windows
^#F6::                                            ;  (portrait format)
	width := xStep*2
	height := yStep*2
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 6)
	y := yTopRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

NumpadRight::                                     ; "6" on num pad handles 1/6-screen windoows
#F6::                                             ;  (landscape format)
	width := xStep * 4
	height := yStep
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 3)
	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

NumpadUp::                                        ; "8" on num pad handles 1/8-screen windows
#F8::
	width := xStep * 3
	height := yStep
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 4)
	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return

#F12::
	width := xStep * 2
	height := yStep
	Gosub, spyActiveWindow

	x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 6)
	Gosub, chooseRow
	WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff

	return
NumpadMult::                                      ; where the "12" would be, if there was one. :-)
	if GetKeyState("NumLock", "T") == 0 {
		width := xStep * 2
		height := yStep
		Gosub, spyActiveWindow

		x := marginLeft + width * mod(((xInner - marginLeft) // width + 1), 6)
		Gosub, chooseRow
		WinMove, A, , x - xOffset, y - yOffset, width + wDiff, height + hDiff
	} else {
		SendInput {*}
	}

	return

#F9::
	WinSet, AlwaysOnTop, toggle, A
	return
NumpadDel::                                       ; toggle "Always On Top"
	if GetKeyState("NumLock", "T") == 0 {
		WinSet, AlwaysOnTop, toggle, A
	} else {
		SendInput {Del}
	}

	return

#]::
	Gosub, spyActiveWindow
	x := marginLeft + xStep * mod(min(((xInner - marginLeft) // xStep + 1), 11), 12)

	if (yOuter < topRowTest)
		y := yTopRow
	else
		y := yBottomRow

	WinMove, A, , x - xOffset, y - yOffset, wOuter, hOuter

	return
NumpadAdd::                                       ; nudge right
	if GetKeyState("NumLock", "T") == 0 {
		Gosub, spyActiveWindow
		x := marginLeft + xStep * mod(min(((xInner - marginLeft) // xStep + 1), 11), 12)

		if (yOuter < topRowTest)
			y := yTopRow
		else
			y := yBottomRow

		WinMove, A, , x - xOffset, y - yOffset, wOuter, hOuter
	} else {
		SendInput {+}
	}

	return

#[::
	Gosub, spyActiveWindow
	maxLeftSteps := wInner / xStep - 1
	x := marginLeft + xStep * mod(max(((xInner - marginLeft) // xStep - 1), - maxLeftSteps), 12)

	if (yOuter < topRowTest)
		y := yTopRow
	else
		y := yBottomRow

	WinMove, A, , x - xOffset, y - yOffset, wOuter, hOuter

	return
NumpadSub::                                       ; nudge left
	if GetKeyState("NumLock", "T") == 0 {
		Gosub, spyActiveWindow
		maxLeftSteps := wInner / xStep - 1
		x := marginLeft + xStep * mod(max(((xInner - marginLeft) // xStep - 1), - maxLeftSteps), 12)

		if (yOuter < topRowTest)
			y := yTopRow
		else
			y := yBottomRow

		WinMove, A, , x - xOffset, y - yOffset, wOuter, hOuter
	} else {
		SendInput {-}
	}

	return

chooseRow:
	if (x = marginLeft) {
		if (yOuter < topRowTest)                    ; if the x position just cycled to the left
			y := yBottomRow                          ; edge of the screen then switch rows...
		else
			y := yTopRow
	} else {
		if (yOuter < topRowTest)                    ; ...otherwise, keep it in the same row.
			y := yTopRow
		else
			y := yBottomRow
	}

	return

spyActiveWindow:
	WinRestore, A
	WinGet, hA, ID, A
	WinGetPos, xOuter, yOuter, wOuter, hOuter, A
	WinGetPosEx(hA, xInner, yInner, wInner, hInner)
	xOffset := xInner - xOuter
	yOffset := yInner - yOuter
	wDiff := wOuter - wInner
	hDiff := hOuter - hInner

	return

#include WinGetPosEx.ahk
