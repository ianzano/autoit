#include <EditConstants.au3>
#include <ComboConstants.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>

Opt("GUIOnEventMode",True)

Global $oNumbers = ObjCreate("Scripting.Dictionary")
$oNumbers("0") = "0"
$oNumbers("1") = "1"
$oNumbers("2") = "2"
$oNumbers("3") = "3"
$oNumbers("4") = "4"
$oNumbers("5") = "5"
$oNumbers("6") = "6"
$oNumbers("7") = "7"
$oNumbers("8") = "8"
$oNumbers("9") = "9"
$oNumbers("10") = "A"
$oNumbers("11") = "B"
$oNumbers("12") = "C"
$oNumbers("13") = "D"
$oNumbers("14") = "E"
$oNumbers("15") = "F"
$oNumbers("A") = "10"
$oNumbers("B") = "11"
$oNumbers("C") = "12"
$oNumbers("D") = "13"
$oNumbers("E") = "14"
$oNumbers("F") = "15"

Global $hGUI = GUICreate("Number System Converter",490,280)
Global $iLabelSource = GUICtrlCreateLabel("Source",5,5,100,30,$SS_LEFT)
Global $iComboSource = GUICtrlCreateCombo("Decimal",5,35,200,40,$CBS_DROPDOWNLIST)
Global $iInputSource = GUICtrlCreateInput("10",210,35,30,28,BitOR($ES_NUMBER,$ES_CENTER))
Global $iEditSource = GUICtrlCreateEdit("11111111",5,70,235,200,$ES_UPPERCASE)
Global $iLabelTarget = GUICtrlCreateLabel("Target",385,5,100,30,$SS_RIGHT)
Global $iComboTarget = GUICtrlCreateCombo("Binary",285,35,200,40,$CBS_DROPDOWNLIST)
Global $iInputTarget = GUICtrlCreateInput("2",250,35,30,28,BitOR($ES_NUMBER,$ES_CENTER))
Global $iEditTarget = GUICtrlCreateEdit("",250,70,235,200,$ES_READONLY)

Global $sBackup = "11111111"
Global $bBackup = True

GUICtrlSetData($iComboSource,"Binary|Octal|Hexadecimal|Custom","Decimal")
GUICtrlSetFont($iComboSource,11,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iLabelSource,15,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iInputSource,11,Default,Default,"Segoe UI Light")
GUICtrlSetState($iInputSource,$GUI_DISABLE)
GUICtrlSetOnEvent($iComboSource, "_ComboSource")

GUICtrlSetData($iComboTarget, "Decimal|Octal|Hexadecimal|Custom","Binary")
GUICtrlSetFont($iComboTarget,11,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iEditSource,9,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iLabelTarget,15,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iEditTarget,9,Default,Default,"Segoe UI Light")
GUICtrlSetFont($iInputTarget,11,Default,Default,"Segoe UI Light")
GUICtrlSetState($iInputTarget,$GUI_DISABLE)
GUICtrlSetOnEvent($iComboTarget,"_ComboTarget")

OnAutoItExitRegister("_Exit")
GUISetOnEvent($GUI_EVENT_CLOSE,"_doExit")
GUISetState()

While 1
	If ($bBackup) Or ($sBackup <> GUICtrlRead($iEditSource)) Then
		$sBackup = GuiCtrlRead($iEditSource)
		If StringLen(GUICtrlRead($iEditSource)) Then
			If GUICtrlRead($iInputSource) == 10 Then
				GUICtrlSetData($iEditTarget,_ToSys(GUICtrlRead($iInputTarget),GUICtrlRead($iEditSource)))
			Else
				$iDez = _ToDez(GUICtrlRead($iInputSource),GUICtrlRead($iEditSource))
				GUICtrlSetData($iEditTarget,_ToSys(GUICtrlRead($iInputTarget),$iDez))
			EndIf
			$bBackup = False
		Else
			GUICtrlSetData($iEditTarget,"")
		EndIf
	EndIf
WEnd

Func _ComboSource()
	Switch GUICtrlRead($iComboSource)
		Case "Decimal"
			GUICtrlSetState($iInputSource,$GUI_DISABLE)
			GUICtrlSetData($iInputSource,"10")
		Case "Binary"
			GUICtrlSetState($iInputSource,$GUI_DISABLE)
			GUICtrlSetData($iInputSource,"2")
		Case "Octal"
			GUICtrlSetState($iInputSource,$GUI_DISABLE)
			GUICtrlSetData($iInputSource,"8")
		Case "Hexadecimal"
			GUICtrlSetState($iInputSource,$GUI_DISABLE)
			GUICtrlSetData($iInputSource,"16")
		Case Else
			GUICtrlSetState($iInputSource,$GUI_ENABLE)
			GUICtrlSetState($iInputSource,$GUI_FOCUS)
	EndSwitch
	$bBackup = True
EndFunc

Func _ComboTarget()
	Switch GUICtrlRead($iComboTarget)
		Case "Decimal"
			GUICtrlSetState($iInputTarget,$GUI_DISABLE)
			GUICtrlSetData($iInputTarget,"10")
		Case "Binary"
			GUICtrlSetState($iInputTarget,$GUI_DISABLE)
			GUICtrlSetData($iInputTarget,"2")
		Case "Octal"
			GUICtrlSetState($iInputTarget,$GUI_DISABLE)
			GUICtrlSetData($iInputTarget,"8")
		Case "Hexadecimal"
			GUICtrlSetState($iInputTarget,$GUI_DISABLE)
			GUICtrlSetData($iInputTarget,"16")
		Case Else
			GUICtrlSetState($iInputTarget,$GUI_ENABLE)
			GUICtrlSetState($iInputTarget,$GUI_FOCUS)
	EndSwitch
	$bBackup = True
EndFunc

Func _ToSys($iSystem,$iValue)
	Local $sRest = ""
	Local $sReverse = ""
	Do
		$sRest = $oNumbers(String(Floor(Mod($iValue,$iSystem)))) & $sRest
		$iValue = $iValue / $iSystem
	Until Floor($iValue) = 0
	Return $sRest
EndFunc

Func _ToDez($iSystem,$iValue)
	Local $iCounter = 1
	Local $iResult = 0
	For $i = StringLen($iValue) To 0 Step -1
		$iResult += $oNumbers(StringMid($iValue,$i,1)) * $iCounter
		$iCounter *= $iSystem
	Next
	Return $iResult
EndFunc

Func _Exit()
EndFunc

Func _doExit()
	Exit
EndFunc