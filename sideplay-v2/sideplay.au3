#Include <WindowsConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <GDIPlus.au3>
#Include <Sound.au3>

#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_UseX64=y

Opt("GUICloseOnESC", 0)
Opt("GUIOnEventMode", 1)
Opt("MustDeclareVars", 1)
Opt("MouseCoordMode", 2)

OnAutoItExitRegister("OnProgramExit")

Global Static $_CONFIG_NAME = "SidePlay"
Global Static $_CONFIG_VERSION = "2.0.041a"
Global Static $_CONFIG_RESOLUTIONX = 800
Global Static $_CONFIG_RESOLUTIONY = 600
Global Static $_CONFIG_SHOWFPS = True

Global Static $_DEF_RAND_TITLES = [ _
   "Venturing into the unknown..", _
   "You may never know.." _
]
Global Static $_DEF_RAND_TITLE = $_DEF_RAND_TITLES[Random(0, UBound($_DEF_RAND_TITLES)-1,1)]

Global Static $_DEF_SIZE = 13
Global Static $_DEF_STYLE = 0
Global Static $_DEF_FONT = "Segoe UI Light"
Global Static $_DEF_BACKGROUND = 0xFF1C1C1C
Global Static $_DEF_FOREGROUND = 0xFFFFFFFF
Global Static $_DEF_COLOR = 0x2459B3FF
Global Static $_DEF_BUTTONLEN = 200
Global Static $_DEF_PLAYER_WIDTH = 50
Global Static $_DEF_PLAYER_HEIGHT = 50
Global Static $_DEF_MAX_ADVENTURES = 50

_GDIPlus_Startup()

Global $hStringFormat = _GDIPlus_StringFormatCreate()
Global $hBitmapLeftStop = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\Pictures\left_stop.png")
Global $hBitmapRightStop = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\Pictures\right_stop.png")
Global $hBitmapLeftMove = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\Pictures\left_move.png")
Global $hBitmapRightMove = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\Pictures\right_move.png")

Global $hWindow = GUICreate($_CONFIG_NAME, $_CONFIG_RESOLUTIONX, $_CONFIG_RESOLUTIONY, -1, -1, -1, -1)
Global $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hWindow)
Global $hBitmap = _GDIPlus_BitmapCreateFromGraphics($_CONFIG_RESOLUTIONX, $_CONFIG_RESOLUTIONY, $hGraphics)
Global $hBuffer = _GDIPlus_ImageGetGraphicsContext($hBitmap)

Global $iGameState = -1
Global $sMouseHover, $sMouseClicked
Global $bToggleMove = True
Global $iCurrentPage = 0

GUISetOnEvent($GUI_EVENT_CLOSE, "DoProgramExit")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "OnLeftClick")
GUIRegisterMsg($WM_PAINT, "DoProgramRepaint")

GUISetState()

Global $aSound = _SoundOpen(@ScriptDir & "\Sounds\title.mp3")
_SoundPlay($aSound)
AdlibRegister("TimerMove")

If $_CONFIG_SHOWFPS == True Then
   Global $iFPS, $iFPSBuffer = "Loading.."
   AdlibRegister("TimerFPS", 1000)
EndIf

While 1
   _WinAPI_RedrawWindow($hWindow, 0, 0, 2)
   _GDIPlus_GraphicsClear($hBuffer, $_DEF_BACKGROUND)

   OnProgramRepaint()
WEnd

Func TimerClicked()
   $sMouseClicked = ""
   AdlibUnRegister("TimerClicked")
EndFunc

Func TimerMove()
   $bToggleMove = Not $bToggleMove
EndFunc

Func TimerFPS()
   $iFPSBuffer = $iFPS
   $iFPS = 0
EndFunc

Func DoProgramRepaint()
   _GDIPlus_GraphicsDrawImageRect($hGraphics, $hBitmap, 0, 0, $_CONFIG_RESOLUTIONX, $_CONFIG_RESOLUTIONY)
   Return $GUI_RUNDEFMSG
EndFunc
Func OnProgramRepaint()
   Switch $iGameState
	  Case -1 ; Main Menu
		 _DrawString($_DEF_RAND_TITLE, -1*($_CONFIG_RESOLUTIONX/2), 100, 15)

		 If $bToggleMove Then
			_GDIPlus_GraphicsDrawImageRect($hBuffer, $hBitmapRightMove, $_CONFIG_RESOLUTIONX/2 - $_DEF_PLAYER_WIDTH/2, 150, $_DEF_PLAYER_WIDTH, $_DEF_PLAYER_HEIGHT)
		 Else
			_GDIPlus_GraphicsDrawImageRect($hBuffer, $hBitmapRightStop, $_CONFIG_RESOLUTIONX/2 - $_DEF_PLAYER_WIDTH/2, 150, $_DEF_PLAYER_WIDTH, $_DEF_PLAYER_HEIGHT)
		 EndIf

		 Local $hBrush = _GDIPlus_BrushCreateSolid(-11383475)
		 _GDIPlus_GraphicsFillRect($hBuffer, 0, 200, $_CONFIG_RESOLUTIONX, 12, $hBrush)
		 _GDIPlus_BrushDispose($hBrush)

		 _DrawString($_CONFIG_NAME, -1*($_CONFIG_RESOLUTIONX/2), 240, 20)

		 _DrawButton("Story", $_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2, 300)
		 _DrawButton("Adventure", $_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2, 340)
		 _DrawButton("Optionen", $_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2, 380)
		 _DrawButton("Beenden", $_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2, 420, 0xFFFF3333)

		 _DrawString("Version " & $_CONFIG_VERSION, $_CONFIG_RESOLUTIONX-100, $_CONFIG_RESOLUTIONY-20, 10)
	  Case 0 ; Level selection
		 If $iPages >= 0 Then
			If $iCurrentPage < $iPages Then
			   _DrawButton("Next ->", ($_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2) + 150, 500)
			EndIf
			If $iCurrentPage <= $iPages And $iCurrentPage > 0 Then
			   _DrawButton("<- Last", ($_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2) - 150, 500)
			EndIf

			Local $iCount = 1
			For $i = $iCurrentPage*5 To $iCurrentPage*5+4
			   If StringLen($aLevels[$i]) Then
				  _DrawButton(StringTrimRight($aLevels[$i], 6), $_CONFIG_RESOLUTIONX/2 - $_DEF_BUTTONLEN/2, 200+ $iCount*30)
				  $iCount += 1
			   EndIf
			Next
		 Else
			_DrawString("You do not have any level files in the game directory.", -1*$_CONFIG_RESOLUTIONX/2, 250)
			_DrawString("If you do now know what this means check out the help.", -1*$_CONFIG_RESOLUTIONX/2, 275)
		 EndIf
   EndSwitch

   If $_CONFIG_SHOWFPS == True Then
	  _DrawString("FPS: " & $iFPSBuffer, 0, 0, 12)
	  $iFPS += 1
   EndIf
EndFunc

Func OnLeftClick()
   $sMouseClicked = $sMouseHover
   AdlibRegister("TimerClicked", 50)
EndFunc

Func DoProgramExit()
   Exit
EndFunc
Func OnProgramExit()
   AdlibUnregister("TimerFPS")
   AdlibUnregister("TimerMove")

   _SoundStop($aSound)
   _SoundClose($aSound)

   _GDIPlus_BitmapDispose($hBitmapLeftMove)
   _GDIPlus_BitmapDispose($hBitmapRightMove)
   _GDIPlus_BitmapDispose($hBitmapLeftStop)
   _GDIPlus_BitmapDispose($hBitmapRightStop)

   _GDIPlus_GraphicsDispose($hBuffer)
   _GDIPlus_BitmapDispose($hBitmap)
   _GDIPlus_GraphicsDispose($hGraphics)
   _GDIPlus_Shutdown()
EndFunc

Func _LoadLevel($sFile)
   Local $hFile = FileOpen($sFile)
   Local $hRead = FileRead($hFile)
   FileClose($hFile)
EndFunc

Func _DrawButton($sLabel, $iPosX, $iPosY, $iForeColor = $_DEF_FOREGROUND, $iBackColor = $_DEF_COLOR, $iSize = $_DEF_SIZE, $sFontName = $_DEF_FONT, $iStyle = $_DEF_STYLE)
   Local $aMouse = MouseGetPos()

   If ($aMouse[0] > $iPosX And $aMouse[0] < $iPosX + $_DEF_BUTTONLEN) And ($aMouse[1] > $iPosY And $aMouse[1] < $iPosY + $iSize*2) Then
	  Switch $sMouseClicked
		 Case "0Next ->"
			If $iLevels > 0 Then
			   $iCurrentPage += 1
			EndIf
		 Case "0<- Last"
			If $iLevels > 0 Then
			   $iCurrentPage -= 1
			EndIf
		 Case "-1Adventure"
			If FileChangeDir(@ScriptDir & "\Levels\Adventure") Then
			   Local $hSearch = FileFindFirstFile("*.level")
			   ;If $hSearch = -1 Then Return

			   Global $iLevels = 0, $aLevels[$_DEF_MAX_ADVENTURES], $iPages = 0

			   While 1
				  Local $hFind = FileFindNextFile($hSearch)
				  If @Error Then ExitLoop
				  If StringInStr(FileGetAttrib($hFind), "A") Then
					 $aLevels[$iLevels] = $hFind
					 $iLevels += 1
				  EndIf
			   WEnd

			   ReDim $aLevels[$iLevels+4]

			   $iPages = Ceiling($iLevels/5)-1

			   FileClose($hSearch)

			   $iGameState = 0
			EndIf
		 Case "-1Beenden"
			Local $bLeave = MsgBox($MB_YESNO + $MB_ICONWARNING, "Beenden", "Möchtest du das Spiel wirklich beenden?")
			If $bLeave == $IDYES Then DoProgramExit()
		 Case Else
			If StringLeft($sMouseClicked, 1) == "0" Then
			   For $i = 0 To UBound($aLevels)-1
				  If StringTrimRight($aLevels[$i], 6) == StringTrimLeft($sMouseClicked, 1) Then
					 _LoadLevel("Adventure\" & $aLevels[$i])
					 ExitLoop
				  EndIf
			   Next
			EndIf
	  EndSwitch
	  $sMouseClicked = ""
	  $sMouseHover = $iGameState & $sLabel
	  Local $hPen = _GDIPlus_PenCreate($iForeColor, 2)
   Else
	  Local $hPen = _GDIPlus_PenCreate($iForeColor, 1)
   EndIf

   _GDIPlus_GraphicsDrawRect($hBuffer, $iPosX, $iPosY, $_DEF_BUTTONLEN, $iSize*2, $hPen)
   _GDIPlus_PenDispose($hPen)

   Local $hBrush = _GDIPlus_BrushCreateSolid($iBackColor)
   _GDIPlus_GraphicsFillRect($hBuffer, $iPosX, $iPosY, $_DEF_BUTTONLEN, $iSize*2, $hBrush)
   _DrawString($sLabel, -1*($iPosX + $_DEF_BUTTONLEN/2), $iPosY, $iSize, $iForeColor, $sFontName, $iStyle)
EndFunc

Func _DrawString($sLabel, $iPosX, $iPosY, $iSize = 13, $iColor = 0xFFFFFFFF, $sFontName = "Segoe UI Light", $iStyle = 0)
   Local $hFamily = _GDIPlus_FontFamilyCreate($sFontName)
   Local $hFont = _GDIPlus_FontCreate($hFamily, $iSize, $iStyle)
   Local $tLayout = _GDIPlus_RectFCreate(0, 0, $_CONFIG_RESOLUTIONX, $_CONFIG_RESOLUTIONY)
   Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $sLabel, $hFont, $tLayout, $hStringFormat)
   Local $iWidth = DllStructGetData($aInfo[0], "Width"), $iHeight = DllStructGetData($aInfo[0], "Height")

   If $iPosX < 0 Then $iPosX = -1*$iPosX - $iWidth/2
   If $iPosY < 0 Then $iPosY = -1*$iPosY - $iHeight/2

   $tLayout = _GDIPlus_RectFCreate($iPosX, $iPosY, $iWidth, $iHeight)
   $aInfo = _GDIPlus_GraphicsMeasureString($hGraphics, $sLabel, $hFont, $tLayout, $hStringFormat)
   Local $hBrush = _GDIPlus_BrushCreateSolid($iColor)
   _GDIPlus_GraphicsDrawStringEx($hBuffer, $sLabel, $hFont, $aInfo[0], $hStringFormat, $hBrush)
   _GDIPlus_BrushDispose($hBrush)
   _GDIPlus_FontDispose($hFont)
   _GDIPlus_FontFamilyDispose($hFamily)
EndFunc