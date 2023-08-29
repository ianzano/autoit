#include <GUIConstantsEx.au3>
#include <GDIPlus.au3>
#include <WinAPI.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode",1)
Opt("MouseCoordMode",2)

; Constants
$Width = 600
$Height = 491
$Field_Size = 35

; Arrays
Dim $Falling[10][Floor($Height/$Field_Size)]
Dim $Placed[10][Floor($Height/$Field_Size)]

; Variables
$Playing = 0
$Background = 0xFF1C1C1C

; Script start
_GDIPlus_Startup()

$Window = GUICreate("Tetris",10*$Field_Size + 200,$Height)
$Graphic = _GDIPlus_GraphicsCreateFromHWND($Window)
$Bitmap = _GDIPlus_BitmapCreateFromGraphics($Width,$Height,$Graphic)
$Backlayer = _GDIPlus_ImageGetGraphicsContext($Bitmap)
$Brush = _GDIPlus_BrushCreateSolid(0x2459B3FF)
$Brush_Red = _GDIPlus_BrushCreateSolid(0xFFFF0000)

GUISetBkColor($Background)
GUISetState()
GUISetOnEvent($GUI_EVENT_CLOSE,"_Exit")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "_LeftClickDown")
;GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "_RightClick")
;GUISetOnEvent($GUI_EVENT_MOUSEMOVE, "_Hover")
GUIRegisterMsg($WM_PAINT,"_Paint")

HotKeySet("{Left}","_LeftKey")
HotKeySet("{Right}","_RightKey")
HotKeySet("{Up}","_UpKey")
HotKeySet("{Down}","_DownKey")

While 1
   _GDIPlus_GraphicsClear($Backlayer,$Background)
   If Not $Playing Then
	  _DrawString("Tetris",0xFFFFFFFF,"Arial",20,$Width/2 - 50,55)

	  _GDIPlus_GraphicsFillRect($Backlayer,$Width/2 - 110,125,200,25, $Brush)
	  _DrawString("Start",0xFFFFFFFF,"Segoe UI Light",15,$Width/2 - 33,121)

	  _GDIPlus_GraphicsFillRect($Backlayer,$Width/2 - 110,160,200,25, $Brush)
	  _DrawString("Exit",0xFFFFFFFF,"Segoe UI Light",15,$Width/2 - 28,157)
   Else
	  For $x = 0 To UBound($Falling,1)-1
		 For $y = 0 To UBound($Falling,2)-1
			If Not $Falling[$x][$y] And Not $Placed[$x][$y] Then
			   _GDIPlus_GraphicsDrawRect($Backlayer,$x*$Field_Size+6,$y*$Field_Size,$Field_Size,$Field_Size)
			ElseIf $Falling[$x][$y] Or $Placed[$x][$y] Then
			   _GDIPlus_GraphicsFillRect($Backlayer,$x*$Field_Size+6,$y*$Field_Size,$Field_Size,$Field_Size,$Brush_Red)
			EndIf
		 Next
	  Next

	  _GDIPlus_GraphicsFillRect($Backlayer,$Width*0.01,0,10*$Field_Size,$Height, $Brush)

	  _GDIPlus_GraphicsFillRect($Backlayer,10*$Field_Size + 23,444,163,33, $Brush)
	  _DrawString("Exit to main menu",0xFFFFFFFF,"Segoe UI Light",15,10*$Field_Size + 25,444)
   EndIf
   _WinAPI_RedrawWindow($Window,0,0,2)
WEnd

Func _LeftKey()
   For $x = 0 To UBound($Falling,1)-1
	  For $y = 0 To UBound($Falling,2)-1
		 If $Falling[$x][$y] And $x > 0 Then
			If Not $Placed[$x-1][$y] Then
			   $Falling[$x-1][$y] = 1
			   $Falling[$x][$y] = 0
			EndIf
		 EndIf
	  Next
   Next
EndFunc

Func _RightKey()
   For $x = UBound($Falling,1)-1 To 0 Step -1
	  For $y = UBound($Falling,2)-1 To 0 Step -1
		 If $Falling[$x][$y] And $x < 9 Then
			If Not $Placed[$x+1][$y] Then
			   $Falling[$x][$y] = 0
			   $Falling[$x+1][$y] = 1
			EndIf
		 EndIf
	  Next
   Next
EndFunc

Func _UpKey()
   ; Drehen
EndFunc

Func _DownKey()
   AdlibUnRegister("_Fall")
   AdlibRegister("_Fall",40)
EndFunc

Func _Generate()
;~ 	$Random = Random(1,3,1)
;~ 	Switch $Random
;~ 		Case Default
			$Falling[5][0] = 1
			$Falling[6][0] = 1
			$Falling[5][1] = 1
			$Falling[6][1] = 1
			AdlibRegister("_Fall",900)
;~ 	EndSwitch
EndFunc

Func _Fall()
   For $x = UBound($Falling,1)-1 To 0 Step -1
	  For $y = UBound($Falling,2)-1 To 0 Step -1
		 If $Falling[$x][$y] Then

			; If most down
			If $y = 13 Then
			   AdlibUnRegister()
			   For $x = 0 To UBound($Falling,1)-1
				  For $y = 0 To UBound($Falling,2)-1
					 If $Falling[$x][$y] Then
						$Placed[$x][$y] = 1
						$Falling[$x][$y] = 0
					 EndIf
				  Next
			   Next
			   _Generate()
			   ExitLoop 2
			Else
			   If $Placed[$x][$y+1] Then
				  AdlibUnRegister()
				  For $x = 0 To UBound($Falling,1)-1
					 For $y = 0 To UBound($Falling,2)-1
						If $Falling[$x][$y] Then
						   ;If $Placed[$x][$y+1] Then
							  $Falling[$x][$y] = 0
							  $Placed[$x][$y] = 1
						   ;EndIf
						EndIf
					 Next
				  Next
				  _Generate()
				  ExitLoop 2
			   Else
				  $Falling[$x][$y] = 0
				  $Falling[$x][$y+1] = 1
			   EndIf
			EndIf
		 EndIf
	  Next
   Next
EndFunc

Func _LeftClickDown()
   $MousePos = MouseGetPos()
   If Not $Playing Then
	  Select
		 Case $MousePos[0] > ($Width/2) - 110 And $MousePos[0] < ($Width/2) - 110 + 200
			If $MousePos[1] > 121 And $MousePos[1] < 150 Then
			   $Playing = 1
			   _Generate()
			ElseIf $MousePos[1] > 157 And $MousePos[1] < 178 Then
			   _Exit()
			EndIf
	  EndSelect
   Else
	  If $MousePos[0] > 10*$Field_Size + 23 And $MousePos[0] < 10*$Field_Size + 23 + 163 And $MousePos[1] > 444 And $MousePos[1] < 444 + 33 Then
		 $Playing = 0
	  EndIf
   EndIf
EndFunc

Func _Paint()
   _GDIPlus_GraphicsDrawImageRect($Graphic,$Bitmap,0,0,$Width,$Height)
   Return $GUI_RUNDEFMSG
EndFunc

Func _DrawString($String, $Brush, $FontFamily, $FontSize, $X, $Y)
   $Brush = _GDIPlus_BrushCreateSolid($Brush)
   $Format = _GDIPlus_StringFormatCreate()
   $FontFamily = _GDIPlus_FontFamilyCreate($FontFamily)
   $Font = _GDIPlus_FontCreate($FontFamily, $FontSize)
   $Layout = _GDIPlus_RectFCreate($X, $Y)
   $Length = _GDIPlus_GraphicsMeasureString($Backlayer, $String, $Font, $Layout, $Format)
   _GDIPlus_GraphicsDrawStringEx($Backlayer, $String, $Font, $Length[0], $Format, $Brush)
   Return $Length
EndFunc

Func _ConsoleWrite($String)
   Return ConsoleWrite($String & @CRLF)
EndFunc

Func _Exit()
   _GDIPlus_Shutdown()
   Exit
EndFunc