#include <WinAPI.au3>
#include <GDIPlus.au3>
#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>

Func _ATAN2(Const $NY, Const $NX)
	Const $NPI = 3.14159265358979
	Local $NRESULT
	If IsNumber($NY) = 0 Then
		SetError(1)
		Return 0
	ElseIf IsNumber($NX) = 0 Then
		SetError(1)
		Return 0
	EndIf
	If $NX = 0 Then
		If $NY > 0 Then
			$NRESULT = $NPI / 2
		ElseIf $NY < 0 Then
			$NRESULT = 3 * $NPI / 2
		Else
			SetError(2)
			Return 0
		EndIf
	ElseIf $NX < 0 Then
		$NRESULT = ATan($NY / $NX) + $NPI
	Else
		$NRESULT = ATan($NY / $NX)
	EndIf
	While $NRESULT < 0
		$NRESULT += 2 * $NPI
	WEnd
	Return $NRESULT
EndFunc
Func _Degree($NRADIANS)
	If IsNumber($NRADIANS) Then Return $NRADIANS * 57.2957795130823
	Return SetError(1, 0, "")
EndFunc
Func _MathCheckDiv($I_NUMA, $I_NUMB = 2)
	If Number($I_NUMA) = 0 Or Number($I_NUMB) = 0 Or Int($I_NUMA) <> $I_NUMA Or Int($I_NUMB) <> $I_NUMB Then
		Return SetError(1, 0, -1)
	ElseIf Int($I_NUMA / $I_NUMB) <> $I_NUMA / $I_NUMB Then
		Return 1
	Else
		Return 2
	EndIf
EndFunc
Func _Max($NNUM1, $NNUM2)
	If Not IsNumber($NNUM1) Then Return SetError(1, 0, 0)
	If Not IsNumber($NNUM2) Then Return SetError(2, 0, 0)
	If $NNUM1 > $NNUM2 Then
		Return $NNUM1
	Else
		Return $NNUM2
	EndIf
EndFunc
Func _Min($NNUM1, $NNUM2)
	If (Not IsNumber($NNUM1)) Then Return SetError(1, 0, 0)
	If (Not IsNumber($NNUM2)) Then Return SetError(2, 0, 0)
	If $NNUM1 > $NNUM2 Then
		Return $NNUM2
	Else
		Return $NNUM1
	EndIf
EndFunc
Func _Radian($NDEGREES)
	If Number($NDEGREES) Then Return $NDEGREES / 57.2957795130823
	Return SetError(1, 0, "")
EndFunc




_GDIPlus_Startup()

OnAutoItExitRegister("_OnExit")

Global $iPi = 3.14159265358979
Global $i2Rad = $iPi / 180

Global $iGuiWidth = 500
Global $iGuiHeight = 500
Global $iGuiX = $iGuiWidth / 2
Global $iGuiY = $iGuiHeight / 2

Global $iGuiMaximal = _Min($iGuiWidth, $iGuiHeight)

Global $hBrushCircleOut = _GDIPlus_BrushCreateSolid(-1973791)

Global $IRADARCOUT = 47
$IRADCIRCLEOUT = 47
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
$HPENHOUR = _GDIPlus_PenCreate(-16777216, 14, 2)
$HPENMINUTE = _GDIPlus_PenCreate(-16777216, 14, 2)
$HPENSECOND = _GDIPlus_PenCreate(-16777216, 5, 2)
$HPENSTROKESMALL = _GDIPlus_PenCreate(-16777216, 9, 2)
$HPENSTROKEBIG = _GDIPlus_PenCreate(-16777216, 15, 2)
$HPENARCOUT = _GDIPlus_PenCreate(-11206656, 6, 2)
$HGUI = GUICreate("", $IGUIWIDTH, $IGUIHEIGHT, 0, 0, $WS_POPUP, $WS_EX_TOPMOST)
$HGRAPHIC = _GDIPlus_GraphicsCreateFromHWND($HGUI)
$HBITMAP = _GDIPlus_BitmapCreateFromGraphics($IGUIWIDTH, $IGUIHEIGHT, $HGRAPHIC)
$HBUFFER = _GDIPlus_ImageGetGraphicsContext($HBITMAP)
_GDIPlus_GraphicsSetSmoothingMode($HBUFFER, 2)
_DRAW()
GUIRegisterMsg($WM_PAINT, "_WM_PAINT")
GUISetState(@SW_SHOW, $HGUI)
While GUIGetMsg() <> $GUI_EVENT_CLOSE
	_DRAW()
	_WinAPI_RedrawWindow($HGUI, 0, 0, 2)
WEnd
Func _DRAW()
	_GDIPlus_GraphicsClear($HBUFFER, -3355444)
	_GDIPlus_GraphicsFillEllipse($HBUFFER, $IGUIX - $IGUIMAXIMAL / 100 * $IRADCIRCLEOUT, $IGUIY - $IGUIMAXIMAL / 100 * $IRADCIRCLEOUT, $IGUIMAXIMAL / 50 * $IRADCIRCLEOUT, $IGUIMAXIMAL / 50 * $IRADCIRCLEOUT, $HBRUSHCIRCLEOUT)
	_GDIPlus_GraphicsDrawArc($HBUFFER, $IGUIX - $IGUIMAXIMAL / 100 * $IRADARCOUT, $IGUIY - $IGUIMAXIMAL / 100 * $IRADARCOUT, $IGUIMAXIMAL / 50 * $IRADARCOUT, $IGUIMAXIMAL / 50 * $IRADARCOUT, 180, 360, $HPENARCOUT)
	For $IDEGREE = 0 To 359 Step 6
		If Mod($IDEGREE, 30) Then
			_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKESMALLOUT, $HPENSTROKESMALL)
		Else
			_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKEBIGIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKEBIGIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKEBIGOUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADSTROKEBIGOUT, $HPENSTROKEBIG)
		EndIf
	Next

	$IHOUR = @HOUR
	$IMINUTE = @MIN
	$ISECOND = @SEC
	$IMSECOND = @MSEC
	If $IHOUR > 11 Then $IHOUR -= 12
	$IDEGREE = $IHOUR * 30 + $IMINUTE / 2 - 90
	_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOURIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOURIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOUROUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADHOUROUT, $HPENHOUR)
	$IDEGREE = $IMINUTE * 6 + $ISECOND / 10 - 90
	_GDIPlus_GraphicsDrawLine($HBUFFER, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEIN, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEIN, $IGUIX + Cos($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEOUT, $IGUIY + Sin($IDEGREE * $I2RAD) * $IGUIMAXIMAL / 100 * $IRADMINUTEOUT, $HPENMINUTE)
	$IDEGREE = $ISECOND * 6 + $IMSECOND / 166.66667 - 90
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