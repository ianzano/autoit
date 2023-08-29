;#Include <WindowsConstants.au3>
;#Include <ComboConstants.au3>
;#Include <File.au3>
;#Include <Bass.au3>
;#Include <Array.au3>
;#Include <WinAPI.au3>

#Include <GDIPlus.au3>
#Include <GUIConstantsEx.au3>
#Include <WindowsConstants.au3>

Opt("GuiOnEventMode", True)
Opt("MouseCoordMode", 2)
Opt("MustDeclareVars", True)
Opt("TrayIconHide", True)

OnAutoItExitRegister("__Exit")

Local $iGUIWidth = 500
Local $iGUIHeight = 500
Local $iFieldsX = 50
Local $iFieldsY = 50
Local $iBackground = 0xFFFFFFFF

_GDIPlus_Startup()

Local $hGUI = GUICreate("Game of Life", $iGUIWidth, $iGUIHeight) ; 0, 0, $WS_POPUP, $WS_EX_TOPMOST
GUISetState()

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUIRegisterMsg($WM_PAINT, "_Paint")

Local $hBrushOff = _GDIPlus_BrushCreateSolid(0xFF01232E)
Local $hBrushOn = _GDIPlus_BrushCreateSolid(0xFF5555FF)

Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($iGUIWidth, $iGUIHeight, $hGraphics)
Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)

_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)

Dim $aFields[$iFieldsY][$iFieldsX]

Local $iXOffset = $iGUIWidth / $iFieldsX
Local $iYOffset = $iGUIHeight / $iFieldsY

Local $iPercentage = 10

For $y = 0 To $iFieldsY-1
   For $x = 0 To $iFieldsX-1
	  Local $iAdvantage = 0

	  If Random(0, 1) - $iAdvantage < $iPercentage/100 Then
		 $aFields[$y][$x] = True
	  EndIf
   Next
Next

AdlibRegister("_Update", 250)

Do
   _GDIPlus_GraphicsClear($hBuffer, $iBackground)

   For $y = 0 To $iFieldsY-1
	  For $x = 0 To $iFieldsX-1

		 If $aFields[$y][$x] = False Then
			_GDIPlus_GraphicsFillRect($hBuffer, $x * $iXOffset, $y * $iYOffset, $iXOffset, $iYOffset, $hBrushOff)
		 Else
			_GDIPlus_GraphicsFillRect($hBuffer, $x * $iXOffset, $y * $iYOffset, $iXOffset, $iYOffset, $hBrushOn)
		 EndIf
	  Next
   Next

   _WinAPI_RedrawWindow($hGUI, 0, 0, 2)
Until False

Func _Update()
   For $y = 0 To $iFieldsY-1
	  For $x = 0 To $iFieldsX-1
		 Local $iAround = _GetAround($x, $y)
		 If $iAround = 3 Then
			$aFields[$y][$x] = True
		 ElseIf $iAround < 2 Or $iAround > 3 Then
			$aFields[$y][$x] = False
		 EndIf
	  Next
   Next
EndFunc

Func _GetAround($x, $y)
   Local $iResult = 0

   If $x <> 0 And $aFields[$y][$x-1] <> False Then $iResult += 1
   If $x < $iFieldsX-1 And $aFields[$y][$x+1] <> False Then $iResult += 1

   If $y <> 0 Then
	  If $aFields[$y-1][$x] <> False Then $iResult += 1
	  If $x <> 0 And $aFields[$y-1][$x-1] <> False Then $iResult += 1
	  If $x < $iFieldsX-1 And $aFields[$y-1][$x+1] <> False Then $iResult += 1
   EndIf

   If $y < $iFieldsY-1 Then
	  If $aFields[$y+1][$x] <> False Then $iResult += 1

	  If $x <> 0 And $aFields[$y+1][$x-1] <> False Then $iResult += 1
	  If $x < $iFieldsX-1 And $aFields[$y+1][$x+1] <> False Then $iResult += 1
   EndIf

   Return $iResult
EndFunc

Func _Paint()
   _GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, 0, 0, $iGUIWidth, $iGUIHeight)
   Return $GUI_RUNDEFMSG
EndFunc

Func _Exit()
   Exit
EndFunc

Func __Exit()
   _GDIPlus_BrushDispose($hBrushOn)
   _GDIPlus_BrushDispose($hBrushOff)
   _GDIPlus_GraphicsDispose($hGraphics)
   _GDIPlus_BitmapDispose($hBitmap)
   _GDIPlus_GraphicsDispose($hBuffer)
   _GDIPlus_Shutdown()
EndFunc