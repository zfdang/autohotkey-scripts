; https://gist.github.com/JCovarrubias7/b8ddcd4a35330ce78901bdf52e54b84a
; Option 1: When Win+Alt+Space is pressed, resize the active window to be 70% of the screen width and center it.
; Option 2: When Win+Alt+c is pressed, center the active window.
; Option 3: When Win+Ctrl+Space is pressed, rezise the active windows to 30% of the screen width. It will not center
; the active screen. 

; Variables can be adjusted to fit your needs (percentage of total resolution).
BIG_WIDTH_PERCENTAGE := 0.70
BIG_HEIGHT_PERCENTAGE := 0.90
SMALL_WIDTH_PERCENTAGE := 0.33
SMALL_HEIGHT_PERCENTAGE := 0.95
SMALL_USE_PERCENTAGE := false ; Change to false so active window doesn't move
SMALL_LEFTMARGIN_PERCENTAGE := 0.335 ; Change percentage of screen for X position of left margin

; Calculated constant to center active window. Don't touch. 
BIG_MARGIN_PERCENTAGE := (1 - BIG_WIDTH_PERCENTAGE) / 2 

; Monitor Work Area and Resolution
SysGet, BoundingCoordinates, MonitorWorkArea
ResolutionWidth := BoundingCoordinatesRight - BoundingCoordinatesLeft
ResolutionHeight := BoundingCoordinatesBottom - BoundingCoordinatesTop

; DON'T CHANGE ANYTHING UNDER THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.
; Custom Big Command
#!Space::
AdjustedWidth := BIG_WIDTH_PERCENTAGE * ResolutionWidth
AdjustedHeight := BIG_HEIGHT_PERCENTAGE * ResolutionHeight
LeftMargin := BIG_MARGIN_PERCENTAGE * ResolutionWidth

WinMove A, , LeftMargin, 0, AdjustedWidth, AdjustedHeight
return

; Custom Center Command
#!c::
WinGetPos, , , ActiveWidth, ActiveHeight, A
HorizontalMargin := (ResolutionWidth - ActiveWidth) / 2
VerticalMargin := (ResolutionHeight - ActiveHeight) / 2

WinMove A, , HorizontalMargin, VerticalMargin
return

; Custom Small Command
#^Space::
if (SMALL_USE_PERCENTAGE){
	LeftMargin := SMALL_LEFTMARGIN_PERCENTAGE * ResolutionWidth
} else {
	WinGetPos, X, , , , A
	LeftMargin := %X% ; Active window X coordinate
}
AdjustedWidth := SMALL_WIDTH_PERCENTAGE * ResolutionWidth
AdjustedHeight := SMALL_HEIGHT_PERCENTAGE * ResolutionHeight

WinMove A, , LeftMargin, 0, AdjustedWidth, AdjustedHeight
return
