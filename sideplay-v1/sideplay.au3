#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <Sound.au3>
#include "Binary.au3"

#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_UseX64=y

Opt("GUICloseOnESC",False)
Opt("GUIOnEventMode",True)
Opt("MustDeclareVars",True)
Opt("MouseCoordMode",2)

OnAutoItExitRegister("onExit")

Global $iGameState = -1
Global $sGameDir = @AppDataDir & "\SidePlay"
Global $sGameFile = $sGameDir & "\options.ini"
Global $oGameSettings = ObjCreate("Scripting.Dictionary")
Global $oGameTextures = ObjCreate("Scripting.Dictionary")
Global $oGameOptions = ObjCreate("Scripting.Dictionary")
Global $aGameStruct[100][100]
Global $iGameCounter = 0
Global $aGameScanDir[100]
Global $iGamePages = 0
Global $iGamePage = 0
Global $iGuiWidth = 600
Global $iGuiHeight = 500
Global $iGuiBackground = 0xFF1C1C1C
Global $iGuiButtonLen = 200
Global $iGuiButtonX = $iGuiWidth/2 - $iGuiButtonLen/2
Global $iGuiButtonHeight = 25
Global $iGuiButtonBackground = 0x2459B3FF
Global $bGuiPlayerMoving = False
Global $iBlockWidth = 32
Global $iBlockHeight = 32
Global $iColorWhite = 0xFFFFFFFF
Global $fPlayerPosX = -1.0
Global $fPlayerPosY = -1.0
Global $fPlayerPosYBackup = $fPlayerPosY
Global $iPlayerWidth = 50
Global $iPlayerHeight = 50
Global $bPlayerJumping = False
Global $bPlayerDirection = True
Global $iPlayerMoveCounter = 0
Global $bPlayerAnimationSwitcher = False
Global $fPlayerSpeed = 0.15
Global $fPlayerJumpHeight = 2.5
Global $bPlayerJumpingEx = False
Global $bPlayerMoving = False
Global $bFPS = False
Global $iFPS = 30
Global $sFPS = "FPS: " & $iFPS
Global $bFPSt = False
Global $aSound
Global $bSound = False
Global $hSound
Global $bSoundE = False

$oGameSettings("Left") = IniRead($sGameFile,"HOTKEYS","Left","41")
$oGameSettings("Right") = IniRead($sGameFile,"HOTKEYS","Right","44")
$oGameSettings("Jump") = IniRead($sGameFile,"HOTKEYS","Jump","20")
$oGameSettings("ESC") = IniRead($sGameFile,"HOTKEYS","ESC","1B")
$oGameSettings("Sound") = IniRead($sGameFile,"HOTKEYS","Sound","73")
$oGameSettings("FPS") = IniRead($sGameFile,"HOTKEYS","FPS","72")
$oGameSettings("Music") = IniRead($sGameFile,"OPTIONS","Music","1")
$oGameSettings("Debug") = IniRead($sGameFile,"OPTIONS","Debug","0")

If Not FileExists($sGameDir & "\Levels\Story") Then DirCreate($sGameDir & "\Levels\Story")
If Not FileExists($sGameDir & "\Levels\Adventure") Then DirCreate($sGameDir & "\Levels\Adventure")
If Not FileExists($sGameDir & "\Resources") Then DirCreate($sGameDir & "\Resources")
If Not FileExists($sGameDir & "\Resources\pSRight.png") Then FileWrite($sGameDir & "\Resources\pSRight.png",Binary($sPlayerStandRight))
If Not FileExists($sGameDir & "\Resources\pMRight.png") Then FileWrite($sGameDir & "\Resources\pMRight.png",Binary($sPlayerMoveRight))
If Not FileExists($sGameDir & "\Resources\pSLeft.png") Then FileWrite($sGameDir & "\Resources\pSLeft.png",Binary($sPlayerStandLeft))
If Not FileExists($sGameDir & "\Resources\pMLeft.png") Then FileWrite($sGameDir & "\Resources\pMLeft.png",Binary($sPlayerMoveLeft))
If Not FileExists($sGameDir & "\Resources\title.mp3") Then FileWrite($sGameDir & "\Resources\title.mp3",Binary($sTitle))
If Not FileExists($sGameDir & "\options.ini") Then FileWrite($sGameDir & "\options.ini","[HOTKEYS]" & @CRLF & "Left=41" & @CRLF & "Right=44" & @CRLF & "Jump=20" & @CRLF & "ESC=1B" & @CRLF & "Sound=73"& @CRLF & "FPS=72" & @CRLF & @CRLF & "[OPTIONS]" & @CRLF & "Music=1" & @CRLF & "Debug=0")

_GDIPlus_Startup()

Global $hGuiHwnd = GUICreate("Sideplay",$iGuiWidth,$iGuiHeight)
Global $hGuiGraphics = _GDIPlus_GraphicsCreateFromHWND($hGuiHwnd)
Global $hGuiBitmap = _GDIPlus_BitmapCreateFromGraphics($iGuiWidth,$iGuiHeight,$hGuiGraphics)
Global $hGuiBuffer = _GDIPlus_ImageGetGraphicsContext($hGuiBitmap)

Global $hStringFormat = _GDIPlus_StringFormatCreate()
Global $hBtmBackground = _GDIPlus_BitmapCreateFromFile($sGameDir & "\Resources\bgMain.png")
Global $hBtmStandRight = _GDIPlus_BitmapCreateFromFile($sGameDir & "\Resources\pSRight.png")
Global $hBtmStandLeft = _GDIPlus_BitmapCreateFromFile($sGameDir & "\Resources\pSLeft.png")
Global $hBtmMoveRight = _GDIPlus_BitmapCreateFromFile($sGameDir & "\Resources\pMRight.png")
Global $hBtmMoveLeft = _GDIPlus_BitmapCreateFromFile($sGameDir & "\Resources\pMLeft.png")

GUISetOnEvent($GUI_EVENT_CLOSE,"_Exit")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN,"onClick")
GUIRegisterMsg($WM_PAINT,"_Paint")
GUISetState()

_Menu()

While 1
	_WinAPI_RedrawWindow($hGuiHwnd,0,0,2)
	_GDIPlus_GraphicsClear($hGuiBuffer,$iGuiBackground)

	Local $tempBrush
	Switch $iGameState
		Case -3, -2, -1
			If WinActive($hGuiHwnd) Then
				If _IsPressed($oGameSettings("Sound")) Then _ToggleSound()
			EndIf

			$tempBrush = _GDIPlus_BrushCreateSolid(-11383475)
			_GDIPlus_GraphicsFillRect($hGuiBuffer,0,180,700,12,$tempBrush)
			_GDIPlus_BrushDispose($tempBrush)

			If Not $bGuiPlayerMoving Then
				_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmStandRight,$iGuiWidth/2-$iPlayerWidth/2,60,$iPlayerWidth,$iPlayerHeight)
			Else
				_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmMoveRight,$iGuiWidth/2-$iPlayerWidth/2,60,$iPlayerWidth,$iPlayerHeight)
			EndIf

			$tempBrush = _GDIPlus_BrushCreateSolid($iGuiButtonBackground)
			Switch $iGameState
				Case -3
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,400,$iGuiButtonLen,25,$tempBrush)
					If $iGamePages > 0 Then
						If $iGamePage < $iGamePages Then
							_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX+5+$iGuiButtonLen,400,$iGuiButtonLen/2,25,$tempBrush)
							_CreateFont("Next ->","Segoe UI Light",13,0,$hGuiBuffer,$iGuiButtonX+5+$iGuiButtonLen+20,400,$iGuiWidth,$iGuiHeight,$iColorWhite)
						EndIf
						If $iGamePage <= $iGamePages Then
							GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX-5-$iGuiButtonLen/2,400,$iGuiButtonLen/2,25,$tempBrush)
							_CreateFont("<- Last","Segoe UI Light",13,0,$hGuiBuffer,$iGuiButtonX-5-$iGuiButtonLen/2+20,400,$iGuiWidth,$iGuiHeight,$iColorWhite)
						EndIf
					EndIf

					Local $iCount = 0
					For $i = $iGamePage*5 To $iGamePage*5+4
						If StringLen($aGameScanDir[$i]) Then
							_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX/2,220+25+30*$iCount,$iGuiButtonLen*2,25,$tempBrush)
							_CreateFontEx(StringTrimRight($aGameScanDir[$i],6),"Segoe UI Light",13,0,$hGuiBuffer,0,220+25+30*$iCount,$iGuiWidth,$iGuiHeight,$iColorWhite)
							$iCount += 1
						EndIf
					Next
					_CreateFontEx("Adventure","Segoe UI Light",20,0,$hGuiBuffer,0,130,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Back","Segoe UI Light",13,0,$hGuiBuffer,0,400,$iGuiWidth,$iGuiHeight,$iColorWhite)
				Case -2
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,400,$iGuiButtonLen,25,$tempBrush)
					_CreateFontEx("Options","Segoe UI Light",20,0,$hGuiBuffer,0,130,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Move left ... A","Segoe UI Light",13,0,$hGuiBuffer,50,220,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Move right ... S","Segoe UI Light",13,0,$hGuiBuffer,50,245,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Jump  ... Space bar","Segoe UI Light",13,0,$hGuiBuffer,50,270,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Quit to menu ... ESC","Segoe UI Light",13,0,$hGuiBuffer,50,295,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Toggle Debug ... F3","Segoe UI Light",13,0,$hGuiBuffer,250,220,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Toggle Music ... F4","Segoe UI Light",13,0,$hGuiBuffer,250,245,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Music by Kevin MacLeod","Segoe UI Light",13,0,$hGuiBuffer,0,360,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Back","Segoe UI Light",13,0,$hGuiBuffer,0,400,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFont("Quit to menu ... ESC","Segoe UI Light",13,0,$hGuiBuffer,50,295,$iGuiWidth,$iGuiHeight,$iColorWhite)
				Case -1
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,225,$iGuiButtonLen,25,$tempBrush)
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,260,$iGuiButtonLen,25,$tempBrush)
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,295,$iGuiButtonLen,25,$tempBrush)
					_GDIPlus_GraphicsFillRect($hGuiBuffer,$iGuiButtonX,330,$iGuiButtonLen,25,$tempBrush)
					_CreateFontEx("Sideplay","Segoe UI Light",20,0,$hGuiBuffer,0,130,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Story","Segoe UI Light",15,0,$hGuiBuffer,0,222,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Adventure","Segoe UI Light",15,0,$hGuiBuffer,0,257,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Options","Segoe UI Light",15,0,$hGuiBuffer,0,292,$iGuiWidth,$iGuiHeight,$iColorWhite)
					_CreateFontEx("Exit","Segoe UI Light",15,0,$hGuiBuffer,0,327,$iGuiWidth,$iGuiHeight,$iColorWhite)
			EndSwitch
			_GDIPlus_BrushDispose($tempBrush)
		Case 1
			If $oGameOptions.Exists("BackgroundImage") Then
				_GDIPlus_GraphicsClear($hGuiBuffer)
				Local $tempBackground = _GDIPlus_ImageLoadFromFile($sGameDir & "\Resources\" & $oGameOptions("BackgroundImage"))
				_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$tempBackground,0,0,$iGuiWidth,$iGuiHeight)
			EndIf

			If $oGameOptions.Exists("BackgroundColor") Then
			   _GDIPlus_GraphicsClear($hGuiBuffer,$oGameOptions("BackgroundColor"))
			EndIf

			For $iY = 0 To $oGameOptions("Height")-1
				For $iX = 0 To $oGameOptions("Width")-1
					If StringLen($aGameStruct[$iX][$iY] > 0) Then
						_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$oGameTextures($aGameStruct[$iX][$iY]),$iX * $iBlockWidth,($iGuiHeight - $iY * $iBlockHeight) - $iBlockHeight,$iBlockWidth,$iBlockHeight)
					EndIf
				Next
			Next

			If WinActive($hGuiHwnd) Then
				If _IsPressed($oGameSettings("ESC")) Then _Menu()

				If $bPlayerMoving = True Then
					If _IsPressed($oGameSettings("Left")) Then
						If $bPlayerAnimationSwitcher = False Then
							_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmStandLeft,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight) - $iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
						Else
							_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmMoveLeft,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight) - $iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
						EndIf
					ElseIf _IsPressed($oGameSettings("Right")) Then
						If $bPlayerAnimationSwitcher = False Then
							_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmStandRight,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight) - $iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
						Else
							_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmMoveRight,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight) - $iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
						EndIf
					EndIf
				Else
					onStop()
				EndIf
			Else
					onStop()
			EndIf
	EndSwitch

	If WinActive($hGuiHwnd) Then
		If _IsPressed($oGameSettings("FPS")) And $bFPSt = False Then
			If $bFPS = False Then
				$bFPS = True
				AdlibRegister("fpsTimer",1000)
			Else
				$bFPS = False
				AdlibUnRegister("fpsTimer")
			EndIf
			$bFPSt = True
			AdlibRegister("fpsTimer2",250)
		EndIf
	EndIf

	If $bFPS = True Then
		_CreateFont($sFPS,"Segoe UI Light",12,2,$hGuiBuffer,0,0,$iGuiWidth,$iGuiHeight,$iColorWhite)
		$iFPS += 1
	EndIf
WEnd

; Timer
Func genTimer()
	Local $iPosX = Round($fPlayerPosX)
	Local $iLowerX = Floor($fPlayerPosX)
	Local $iPosY = Round($fPlayerPosY)

	$bPlayerMoving = False

	If WinActive($hGuiHwnd) Then
		If _IsPressed($oGameSettings("Left")) Then
			If 0 < $fPlayerPosX Then
				If $aGameStruct[$iLowerX][$iPosY] = "" And $aGameStruct[$iLowerX][$iPosY+1] = "" Then
					$bPlayerDirection = False ;Left
					$bPlayerMoving = True
					$iPlayerMoveCounter += 1
					$fPlayerPosX -= $fPlayerSpeed
				EndIf
			EndIf
		ElseIf _IsPressed($oGameSettings("Right")) Then
			If $iPosX < $oGameOptions("Width") - 1 Then
				If $aGameStruct[$iPosX+1][$iPosY] = "" And $aGameStruct[$iPosX+1][$iPosY+1] = "" Then
					$bPlayerDirection = True
					$bPlayerMoving = True
					$iPlayerMoveCounter += 1
					$fPlayerPosX += $fPlayerSpeed
				EndIf
			EndIf
		EndIf
	EndIf

	If $iPlayerMoveCounter = 5 Then
		If $bPlayerAnimationSwitcher = False Then
			$bPlayerAnimationSwitcher = True
		Else
			$bPlayerAnimationSwitcher = False
		EndIf
		$iPlayerMoveCounter = 0
	EndIf

	If WinActive($hGuiHwnd) Then
		If _IsPressed($oGameSettings("Jump")) And $bPlayerJumping = False Then
			$bPlayerJumping = True
			$bPlayerJumpingEx = True
		EndIf
	EndIf
EndFunc
Func soundTimer()
	$bSoundE = False
EndFunc
Func fpsTimer()
	$sFPS = "FPS: " & $iFPS
	$iFPS = 0
EndFunc
Func fpsTimer2()
	$bFPSt = False
EndFunc
Func moveTimer()
	If $bGuiPlayerMoving = True Then
		$bGuiPlayerMoving = False
	Else
		$bGuiPlayerMoving = True
	EndIf
EndFunc

; Events
Func onMove()
	Local $iLowerX = Floor($fPlayerPosX)
	Local $iPosX = Round($fPlayerPosX)
	If $bPlayerJumpingEx = False Then
		$fPlayerPosYBackup = $fPlayerPosY
		If $aGameStruct[$iPosX][Ceiling($fPlayerPosY)-1] = "" And $aGameStruct[Ceiling($fPlayerPosX)][Ceiling($fPlayerPosY)-1] = "" Then
			$fPlayerPosY -= 0.25
		Else
			$bPlayerJumping = False
		EndIf
	Else
		If $fPlayerPosY >= $fPlayerPosYBackup + $fPlayerJumpHeight Then
			$bPlayerJumpingEx = False
		Else
			If $aGameStruct[$iPosX][Ceiling($fPlayerPosY)+1] = "" And $aGameStruct[Ceiling($fPlayerPosX)][Ceiling($fPlayerPosY)+1] = "" Then
				$fPlayerPosY += 0.25
			Else
				$bPlayerJumpingEx = False
			EndIf
		EndIf
	EndIf
EndFunc
Func onStop()
	If $bPlayerDirection = False Then
		_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmStandLeft,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight)-$iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
	Else
		_GDIPlus_GraphicsDrawImageRect($hGuiBuffer,$hBtmStandRight,$fPlayerPosX * $iBlockWidth,($iGuiHeight - $fPlayerPosY * $iBlockHeight)-$iPlayerHeight,$iPlayerWidth,$iPlayerHeight)
	EndIf
EndFunc
Func onClick()
	Local $MousePos = MouseGetPos()
	If $iGameState = -1 Then
		If $MousePos[0] > $iGuiButtonX And $MousePos[0] < $iGuiButtonX+$iGuiButtonLen Then
			If $MousePos[1] > 224 And $MousePos[1] < 224+$iGuiButtonHeight Then

			ElseIf $MousePos[1] > 260 And $MousePos[1] < 260+$iGuiButtonHeight Then
				If FileChangeDir($sGameDir & "\Levels\Adventure") Then
					Local $hSearch = FileFindFirstFile("*.level")
					If $hSearch = -1 Then Return 0
					For $i = 0 To UBound($aGameScanDir)-1
						If Not StringLen($aGameScanDir[$i]) Then ExitLoop
						$aGameScanDir[$i] = ""
					Next
					$iGameCounter = 0
					$iGamePages = 0

					While 1
						Local $hFind = FileFindNextFile($hSearch)
						If @Error Then ExitLoop
						If StringInStr(FileGetAttrib($hFind),"A") Then
							$aGameScanDir[$iGameCounter] = $hFind
							$iGameCounter += 1
						EndIf
					WEnd
					$iGamePages = Ceiling($iGameCounter/5)-1
					FileClose($hSearch)
					$iGameState = -3
				EndIf
			ElseIf $MousePos[1] > 292 And $MousePos[1] < 292+$iGuiButtonHeight Then
				; Options
				$iGameState = -2
			ElseIf $MousePos[1] > 327 And $MousePos[1] < 327+$iGuiButtonHeight Then
				Exit
			EndIf
		EndIf
	 ElseIf $iGameState = -2 Or $iGameState = -3 Then
		If $MousePos[0] > $iGuiButtonX And $MousePos[0] < $iGuiButtonX+$iGuiButtonLen Then
			If $MousePos[1] > 400 And $MousePos[1] < 400+$iGuiButtonHeight Then
				$iGameState = -1
			EndIf
		EndIf

	  ConsoleWrite("test")

		If $iGameState = -3 Then
			Local $iCountIt = 0
			For $i = $iGamePage*5 To $iGamePage*5 + 4
				If $MousePos[0] > $iGuiButtonX/2 And $MousePos[0] < $iGuiButtonX/2+$iGuiButtonLen*2 Then
					If $MousePos[1] > 220+25+30*$iCountIt And $MousePos[1] < 220+25+30*$iCountIt+$iGuiButtonHeight Then
						ConsoleWrite($aGameScanDir[$i])
						_Load($sGameDir & "\Levels\Adventure\" & $aGameScanDir[$i])
					EndIf
					$iCountIt += 1
				EndIf
			Next

			If $iGamePages > 0 Then
				If $MousePos[1] > 400 And $MousePos[1] < 400+$iGuiButtonHeight Then
					If $MousePos[0] > $iGuiButtonX+$iGuiButtonLen+5 And $MousePos[0] < $iGuiButtonX+$iGuiButtonLen+5+$iGuiButtonLen/2 And ($iGamePage = 0 Or $iGamePage < $iGamePages) Then
						$iGamePage += 1
					ElseIf $MousePos[0] > $iGuiButtonX-5-$iGuiButtonLen/2 And $MousePos[0] < $iGuiButtonX-5 And $iGamePage > 0 Then
						$iGamePage -= 1
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc
Func onExit()
	AdlibUnRegister("onMove")
	AdlibUnRegister("genTimer")
	AdlibUnRegister("moveTimer")
	AdlibUnRegister("soundTimer")
	AdlibUnRegister("fpsTimer")
	AdlibUnRegister("fpsTimer2")
	_SoundClose($aSound)
	For $e In $oGameTextures
		_GDIPlus_BitmapDispose($e)
	Next
	_GDIPlus_GraphicsDispose($hGuiBuffer)
	_GDIPlus_BitmapDispose($hGuiBitmap)
	_GDIPlus_GraphicsDispose($hGuiGraphics)
	_GDIPlus_Shutdown()
EndFunc

; Functions
Func _ToggleSound()
	If $bSoundE = True Then Return
	If $bSound = False Then
		$bSound = True
		$hSound = _SoundPlay($aSound)
		$bSoundE = True
		AdlibRegister("soundTimer",250)
	Else
		_SoundStop($aSound)
		$bSound = False
		$bSoundE = True
		AdlibRegister("soundTimer",250)
	EndIf
EndFunc
Func _CreateFontEx($sLabel,$sFontName,$iFontSize,$iFontStyle,$hGraphic,$iX,$iY,$iWidth,$iHeight,$iFontColor)
	Local $hFamily = _GDIPlus_FontFamilyCreate($sFontName)
	Local $hFont = _GDIPlus_FontCreate($hFamily,$iFontSize,$iFontStyle)
	Local $tLayout = _GDIPlus_RectFCreate($iX,$iY,$iGuiWidth,$iGuiHeight)
	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphic,$sLabel,$hFont,$tLayout,$hStringFormat)
	Local $hBrush = _GDIPlus_BrushCreateSolid($iFontColor)
	Local $iStringWidth = DllStructGetData($aInfo[0],"Width")
	Local $iStringHeight = DllStructGetData($aInfo[0],"Height")
	$tLayout = _GDIPlus_RectFCreate($iGuiWidth/2-$iStringWidth/2,$iY,$iGuiWidth,$iGuiHeight)
	$aInfo = _GDIPlus_GraphicsMeasureString($hGraphic,$sLabel,$hFont,$tLayout,$hStringFormat)
	_GDIPlus_GraphicsDrawStringEx($hGuiBuffer,$sLabel,$hFont,$aInfo[0],$hStringFormat,$hBrush)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
EndFunc
Func _CreateFont($sLabel,$sFontName,$iFontSize,$iFontStyle,$hGraphic,$iX,$iY,$iWidth,$iHeight,$iFontColor)
	Local $hFamily = _GDIPlus_FontFamilyCreate($sFontName)
	Local $hFont = _GDIPlus_FontCreate($hFamily,$iFontSize,$iFontStyle)
	Local $tLayout = _GDIPlus_RectFCreate($iX,$iY,$iGuiWidth,$iGuiHeight)
	Local $aInfo = _GDIPlus_GraphicsMeasureString($hGraphic,$sLabel,$hFont,$tLayout,$hStringFormat)
	Local $hBrush = _GDIPlus_BrushCreateSolid($iFontColor)
	_GDIPlus_GraphicsDrawStringEx($hGuiBuffer,$sLabel,$hFont,$aInfo[0],$hStringFormat,$hBrush)
	_GDIPlus_BrushDispose($hBrush)
	_GDIPlus_FontDispose($hFont)
	_GDIPlus_FontFamilyDispose($hFamily)
EndFunc
Func _Menu()
	$iGameState = -1
	$aSound = _SoundOpen($sGameDir & "\Resources\title.mp3")
	_ToggleSound()
	AdlibRegister("moveTimer")
	AdlibUnRegister("genTimer")
	AdlibUnRegister("onMove")
EndFunc
Func _Load($sFile)
	Local $hFile = FileOpen($sFile)
	Local $hRead = FileRead($hFile)
	FileClose($hFile)

	Local $inData = False
	Local $inStruct = False
	Local $inDeepStruct = False
	Local $iDeepStruct = -1

	Local $aSplit = StringSplit($hRead,@CRLF)

	For $i = 1 To $aSplit[0]
		$aSplit[$i] = StringStripWS($aSplit[$i],8)
		If StringLen($aSplit[$i]) = 0 Then ContinueLoop

		If StringInStr($aSplit[$i],"Data") Then
			$inData = True
			ContinueLoop
		EndIf
		If StringInStr($aSplit[$i],"Struct") Then
			$inStruct = True
			ContinueLoop
		EndIf
		If $inData = True Then
			If StringInStr($aSplit[$i],"}") Then
				$inData = False
			Else
				Local $aAssigns = StringSplit($aSplit[$i],"=")
				$oGameOptions($aAssigns[1]) = $aAssigns[2]
			EndIf
		EndIf
		If $inDeepStruct = True Then
			If StringInStr($aSplit[$i],"}") Then
				$inDeepStruct = False
				$inStruct = True
				ContinueLoop
			Else
				Local $aAssigns = StringSplit($aSplit[$i],"=")
				$aGameStruct[$aAssigns[1]][$iDeepStruct] = $aAssigns[2]
			EndIf
		EndIf

		If $inStruct = True Then
			If StringInStr($aSplit[$i],"}") Then
				$inStruct = False
			Else
				ReDim $aGameStruct[$oGameOptions("Width")][$oGameOptions("Height")]
				Local $aAssigns = StringSplit($aSplit[$i],"=")
				If @Error Then
					$inStruct = False
					$inDeepStruct = True
					$iDeepStruct = StringLeft($aSplit[$i],1)
				Else
					For $iX = 0 To $oGameOptions("Width") - 1
						$aGameStruct[$iX][$aAssigns[1]] = $aAssigns[2]
					Next
				EndIf
			EndIf
		EndIf
	Next
	$fPlayerPosX = $oGameOptions("SpawnX")
	$fPlayerPosY = $oGameOptions("SpawnY")

	For $iY = 0 To $oGameOptions("Height") - 1
		For $iX = 0 To $oGameOptions("Width") - 1
			If $aGameStruct[$iX][$iY] <> "" Then $oGameTextures($aGameStruct[$iX][$iY]) = _GDIPlus_ImageLoadFromFile($sGameDir & "\Resources\" & $oGameOptions($aGameStruct[$iX][$iY]))
		Next
	Next
	$iGameState = 1
	If $bSound = True Then _ToggleSound()
	AdlibUnRegister("moveTimer")
	AdlibRegister("genTimer",30)
	AdlibRegister("onMove",20)
EndFunc
Func _Paint()
	_GDIPlus_GraphicsDrawImageRect($hGuiGraphics,$hGuiBitmap,0,0,$iGuiWidth,$iGuiHeight)
	Return $GUI_RUNDEFMSG
EndFunc
Func _Exit()
	Exit
EndFunc