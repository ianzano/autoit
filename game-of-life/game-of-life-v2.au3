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
;Opt("TrayIconHide", True)

OnAutoItExitRegister("__Exit")

Local $iGUIWidth = 600
Local $iGUIHeight = 600
Local $iFieldsX = 120
Local $iFieldsY = 120
Local $iBackground = 0xFFFFFFFF
Local $iPercentage = 10
Local $iAge = 4 ; Set to 0 to disable aging

_GDIPlus_Startup()

Local $hGUI = GUICreate("Game of Life", $iGUIWidth, $iGUIHeight) ; 0, 0, $WS_POPUP, $WS_EX_TOPMOST
GUISetState()

GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
GUIRegisterMsg($WM_PAINT, "_Paint")

Dim $hBrushes[$iAge+1]
$hBrushes[0] = _GDIPlus_BrushCreateSolid(0xFF01232E)
$hBrushes[1] = _GDIPlus_BrushCreateSolid(0xFF55FFFF)
$hBrushes[2] = _GDIPlus_BrushCreateSolid(0xFF5599FF)
$hBrushes[3] = _GDIPlus_BrushCreateSolid(0xFF5599FF)
$hBrushes[4] = _GDIPlus_BrushCreateSolid(0xFF5555FF)

Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
Local $hBitmap = _GDIPlus_BitmapCreateFromGraphics($iGUIWidth, $iGUIHeight, $hGraphics)
Local $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)

_GDIPlus_GraphicsSetSmoothingMode($hBuffer, 2)

Dim $aFields[$iFieldsY][$iFieldsX]

Local $iXOffset = $iGUIWidth / $iFieldsX
Local $iYOffset = $iGUIHeight / $iFieldsY

For $y = 0 To $iFieldsY-1
   For $x = 0 To $iFieldsX-1
	  Local $iAdvantage = 0

	  If Random(0, 1) - $iAdvantage < $iPercentage/100 Then

		 If _GetAround($x, $y) < 3 Then ; Better randomizer
			$aFields[$y][$x] = 1
		 EndIf

	  EndIf
   Next
Next

While 1
   _GDIPlus_GraphicsClear($hBuffer, $iBackground)

   For $y = 0 To $iFieldsY-1
	  For $x = 0 To $iFieldsX-1
		 ConsoleWrite($aFields[$y][$x] & @CRLF)
		 _GDIPlus_GraphicsFillRect($hBuffer, $x * $iXOffset, $y * $iYOffset, $iXOffset, $iYOffset, $hBrushes[$aFields[$y][$x]])

		 If $iAge <> 0 Then
			If $aFields[$y][$x] > 0 Then
			   If $aFields[$y][$x] = $iAge Then
				  $aFields[$y][$x] = 0
				  ContinueLoop 1
			   Else
				  $aFields[$y][$x] += 1
			   EndIf
			EndIf
		 EndIf

		 Local $iAround = _GetAround($x, $y)
		 If $iAround = 3 Then
			If $aFields[$y][$x] = 0 Then $aFields[$y][$x] = 1
		 ElseIf $iAround < 2 Or $iAround > 3 Then
			$aFields[$y][$x] = 0
		 EndIf

	  Next
   Next

   _WinAPI_RedrawWindow($hGUI, 0, 0, 2)
WEnd

Func _GetAround($x, $y)
   Local $iResult = 0

   If $x <> 0 And $aFields[$y][$x-1] > 0 Then $iResult += 1
   If $x < $iFieldsX-1 And $aFields[$y][$x+1] > 0 Then $iResult += 1

   If $y <> 0 Then
	  If $aFields[$y-1][$x] > 0 Then $iResult += 1
	  If $x <> 0 And $aFields[$y-1][$x-1] > 0 Then $iResult += 1
	  If $x < $iFieldsX-1 And $aFields[$y-1][$x+1] > 0 Then $iResult += 1
   EndIf

   If $y < $iFieldsY-1 Then
	  If $aFields[$y+1][$x] > 0 Then $iResult += 1

	  If $x <> 0 And $aFields[$y+1][$x-1] > 0 Then $iResult += 1
	  If $x < $iFieldsX-1 And $aFields[$y+1][$x+1] > 0 Then $iResult += 1
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
   For $i In $hBrushes
	  _GDIPlus_BrushDispose($i)
   Next

   _GDIPlus_GraphicsDispose($hGraphics)
   _GDIPlus_BitmapDispose($hBitmap)
   _GDIPlus_GraphicsDispose($hBuffer)
   _GDIPlus_Shutdown()
EndFunc