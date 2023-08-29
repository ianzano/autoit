#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

Func _Min($NNUM1, $NNUM2)
	If (Not IsNumber($NNUM1)) Then Return SetError(1, 0, 0)
	If (Not IsNumber($NNUM2)) Then Return SetError(2, 0, 0)
	If $NNUM1 > $NNUM2 Then
		Return $NNUM2
	Else
		Return $NNUM1
	EndIf
EndFunc

Global $iPi = 3.14159265358979
Global $i2Rad = $iPi / 180

Global $iGuiWidth = 500
Global $iGuiHeight = 500
Global $iGuiX = $iGuiWidth / 2
Global $iGuiY = $iGuiHeight / 2

Global $iGuiMaximal = _Min($iGuiWidth, $iGuiHeight)

Global $iCircleOut = 47 ; Radius



$IRADSTROKESMALLIN = 40
$IRADSTROKESMALLOUT = 45
$IRADSTROKEBIGIN = 37
$IRADSTROKEBIGOUT = 45
$IRADHOURIN = 10
$IRADHOUROUT = 30
$IRADMINUTEIN = 10
$IRADMINUTEOUT = 36
$IRADSECONDIN = 10
$IRADSECONDOUT = 30

OnAutoItExitRegister("_OnExit")
_GDIPlus_Startup()

Global $hBrushCircleOut = _GDIPlus_BrushCreateSolid(-1973791)
Global $hPenHour = _GDIPlus_PenCreate(-16777216, 14, 2)
Global $hPenMinute = _GDIPlus_PenCreate(-16777216, 14, 2)
Global $hPenSecond = _GDIPlus_PenCreate(-16777216, 5, 2)
Global $hPenStrokeSmall = _GDIPlus_PenCreate(-16777216, 1, 2)
Global $hPenStrokeBig = _GDIPlus_PenCreate(-16777216, 9, 2)
Global $hPenArcOut = _GDIPlus_PenCreate(-11206656, 6, 2)

Global $hGui = GUICreate("",$iGuiWidth,$iGuiHeight,0,0,$WS_POPUP,$WS_EX_TOPMOST)
Global $hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGui)
Global $hBitmap = _GDIPlus_BitmapCreateFromGraphics($iGuiWidth,$iGuiHeight,$hGraphic)
Global $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)

Global $n

_GDIPlus_GraphicsSetSmoothingMode($hBuffer,2)
GUIRegisterMsg($WM_PAINT, "_WM_PAINT")
GUISetState()

_Draw()

While 1
	If GuiGetMsg() == $GUI_EVENT_CLOSE Then Exit
	_Draw()
	_WinAPI_RedrawWindow($hGui,0,0,2)
WEnd

Func _Draw()
	_GDIPlus_GraphicsClear($hBuffer,-3355444)
	_GDIPlus_GraphicsFillEllipse($hBuffer,$iGuiX - $iGuiMaximal / 100 * $iCircleOut,$iGuiY - $iGuiMaximal / 100 * $iCircleOut, $iGuiMaximal / 50 * $iCircleOut, $iGuiMaximal / 50 * $iCircleOut,$hBrushCircleOut)
	_GDIPlus_GraphicsDrawArc($hBuffer,$iGuiX - $iGuiMaximal / 100 * $iCircleOut,$iGuiY - $iGuiMaximal / 100 * $iCircleOut,$iGuiMaximal / 50 * $iCircleOut,$iGuiMaximal / 50 * $iCircleOut,180,360,$hPenArcOut)

	For $i = 360 - 360/4 To 360 - 360/4 + 359  Step 36
		_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIY + Sin($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIX + Cos($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $IGUIY + Sin($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $hPenStrokeBig)
	Next
	For $i = 360 - 360/4 To 360 - 360/4 + 359  Step 3.6
		_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIY + Sin($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIX + Cos($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $IGUIY + Sin($i * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $hPenStrokeSmall)
	Next

	Local $iMSecond = @MSEC/360
	Local $iTime = Int((@HOUR * 60 * 60 + @MIN * 60 + @SEC) / 0.864)
	Local $iHour = Int($iTime / 10000)
	$iTime -= $iHour * 10000
	Local $iMinute = Int($iTime / 100)
	$iTime -= $iMinute * 100
	Local $iSecond = $iTime
	$iTime -= $iSecond

	$iDegree = $iHour * 36 + $iMinute / 3.6 - 90
	_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOURIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOURIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOUROUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOUROUT, $HPENHOUR)
	$iDegree = $iMinute * 3.6 + $iSecond / 36 - 90
	_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEOUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEOUT, $HPENMINUTE)
	$iDegree = $iSecond * 3.6  - 90
	_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSECONDIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSECONDIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSECONDOUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSECONDOUT, $HPENSECOND)
EndFunc
Func _WM_PAINT()
	_GDIPlus_GraphicsDrawImageRect($HGRAPHIC, $HBITMAP, 0, 0, $IGUIWIDTH, $IGUIHEIGHT)
	Return $GUI_RUNDEFMSG
EndFunc

Func _OnExit()
	_GDIPlus_GraphicsDispose($HGRAPHIC)
	_GDIPlus_BitmapDispose($HBITMAP)
	_GDIPlus_GraphicsDispose($HBUFFER)
	_GDIPlus_Shutdown()
EndFunc