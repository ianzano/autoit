#include <GDIPlus.au3>
#include <WindowsConstants.au3>
#include <GuiConstantsEx.au3>

OnAutoItExitRegister("_Exit")

Opt("GuiOnEventMode",1)
Opt("MouseCoordMode",2)

_GDIPlus_Startup()

Global $iGuiWidth = 500
Global $iGuiHeight = 500

Global $iColorCode = 0xFF000000

Global $iColorWhite = 0xFFFFFF
Global $iColorBlack = 0x000000

Global $hPenWhite = _GDIPlus_PenCreate($iColorCode + $iColorWhite)
Global $hPenBlack = _GDIPlus_PenCreate($iColorCode + $iColorBlack)

$hGui = GuiCreate("Main Menu",$iGuiWidth,$iGuiHeight)

$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGui)
$hBitmap = _GDIPlus_BitmapCreateFromGraphics($iGuiWidth,$iGuiHeight,$hGraphic)
$hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)
_GDIPlus_GraphicsSetSmoothingMode($hBuffer,2)
_GDIPlus_GraphicsClear($hGraphic,$iColorWhite)

GuiSetState()
GuiRegisterMsg($WM_PAINT,"WM_PAINT")
GuiSetOnEvent($GUI_EVENT_RESTORE,"WM_PAINT")
GUISetOnEvent($GUI_EVENT_CLOSE,"_Close")

While 1
	_GDIPlus_GraphicsClear($hBuffer,$iColorCode + $iColorBlack)
	
	; Backbuffer
	_GDIPlus_GraphicsDrawRect($hBuffer,40,40,40,40,$hPenWhite)
	
	_GDIPlus_GraphicsDrawImageRect($hGraphic,$hBitmap,0,0,$iGuiWidth,$iGuiHeight)
WEnd

Func WM_PAINT()
	_GDIPlus_GraphicsDrawImageRect($hGraphic,$hBitmap,0,0,$iGuiWidth,$iGuiHeight)
EndFunc
Func _Close()
	Exit
EndFunc
Func _Exit()
	_GDIPlus_ImageDispose($hBuffer)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_PenDispose($hPenWhite)
	_GDIPlus_Shutdown()
EndFunc