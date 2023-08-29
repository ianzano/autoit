#Include <StaticConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <ComboConstants.au3>
#Include <EditConstants.au3>
#Include <Misc.au3>

#AutoIt3Wrapper_Run_Au3Check=n

Opt("GuiOnEventMode", True)
Opt("MustDeclareVars", True)

Global $hGUI = GUICreate("Vocabulary Trainer", 490, 255)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

GUICtrlCreateLabel("Input", 5, 5, 100, 30, $SS_LEFT)
GUICtrlSetFont(-1, 15, Default, Default, "Segoe UI Light")

GUICtrlCreateLabel("Given", 385, 5, 100, 30, $SS_RIGHT)
GUICtrlSetFont(-1, 15, Default, Default, "Segoe UI Light")

Global $iInputCombo = GUICtrlCreateCombo("", 5, 35, 200, 40, $CBS_DROPDOWNLIST)
GUICtrlSetFont(-1, 11, Default, Default, "Segoe UI Light")
GUICtrlSetOnEvent(-1, "_InputCombo")

Global $iGivenCombo = GUICtrlCreateCombo("", 285, 35, 200, 40, $CBS_DROPDOWNLIST)
GUICtrlSetFont(-1, 11, Default, Default, "Segoe UI Light")
GUICtrlSetOnEvent(-1, "_GivenCombo")

Global $iInputEdit = GUICtrlCreateEdit("", 5, 70, 235, 150, 0)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetState(-1, $GUI_FOCUS)
GUICtrlSetFont(-1, 14, Default, Default, "Segoe UI Light")

Global $iGivenEdit = GUICtrlCreateEdit("", 250, 70, 235, 150, 0)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetFont(-1, 14, Default, Default, "Segoe UI Light")

Global $iSolutionButton = GUICtrlCreateButton("Display Solution", 5, 225, 115, 25)
GUICtrlSetOnEvent(-1, "_Solution")

Global $iSkipButton = GUICtrlCreateButton("Try again later", 125, 225, 115, 25)
GUICtrlSetOnEvent(-1, "_Skip")

GUICtrlCreateButton("Load file...", 250, 225, 115, 25)
GUICtrlSetOnEvent(-1, "_ChooseFile")

GUICtrlCreateButton("About", 370, 225, 115, 25)
GUICtrlSetOnEvent(-1, "_About")

Global $iInputInput = GUICtrlCreateInput("0", 210, 35, 30, 28, BitOR($ES_NUMBER, $ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetFont(-1, 11, Default, Default, "Segoe UI Light")

Global $iGivenInput = GUICtrlCreateInput("", 250, 35, 30, 28, BitOR($ES_NUMBER, $ES_CENTER))
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetFont(-1, 11, Default, Default, "Segoe UI Light")

GUISetState()

Local $sDefaultFile = "[LANG]" & @CRLF & "1=English" & @CRLF & "2=German" & @CRLF & "3=French" & @CRLF & "4=Italian" & @CRLF & @CRLF & _
					  "[VOCAB]" & @CRLF & "1=house,Haus,maison,casa" & @CRLF & "2=telephone,Telefon,telephone,telefono" & @CRLF & "3=car,Auto,voiture,macchina" & @CRLF & _
					  "4=to ring,klingeln,sonner,suonare" & @CRLF & "5=to drive,fahren,conduire,guidare" & @CRLF & "6=to say,sagen,dire,dire" & @CRLF & "7=motorcycle,Motorrad,moto,moto"

If Not FileExists(@MyDocumentsDir & "\My Vocabulary\") Then DirCreate(@MyDocumentsDir & "\My Vocabulary\")

Local $fDefault = FileOpen(@MyDocumentsDir & "\My Vocabulary\Example.vocab", 2)
FileWrite($fDefault, $sDefaultFile)
FileClose($fDefault)

Local $fOpen = FileOpenDialog("Open Vocabulary File...", @MyDocumentsDir & "\My Vocabulary\", "Vocabulary File (*.vocab)")
If @Error Then Exit
_LoadFile($fOpen)

While 1
	If Not WinActive($hGUI) Then ContinueLoop
	If _IsPressed("0D") Then _Enter()

	If $iRefresh = True Then
		Local $sInput = GUICtrlRead($iInputEdit)
		Local $sWord = $aWords[$iRandom][$iInputLanguage][0]
		Local $aSplit = StringSplit($sWord, "|")
		If StringReplace($sInput, ", ", "|") == $sWord Then
			GUICtrlSetState($iInputEdit, $GUI_DISABLE)
			GUICtrlSetState($iSkipButton, $GUI_DISABLE)
			GUICtrlSetData($iSolutionButton, "Next")
			$iRefresh = False
		Else
			For $i = 1 To $aSplit[0]
				If $sInput == $aSplit[$i] Then
					GUICtrlSetState($iInputEdit, $GUI_DISABLE)
					GUICtrlSetState($iSkipButton, $GUI_DISABLE)
					GUICtrlSetData($iSolutionButton, "Next")
					$iRefresh = False
				EndIf
			Next
		EndIf
	EndIf
WEnd

Func _Enter()
	If $iRefresh = False Then
		If $iFinished <> 0 Then
			$iRefresh = True
			GUICtrlSetState($iInputEdit, $GUI_ENABLE)
			GUICtrlSetData($iSolutionButton, "Display Solution")
			GUICtrlSetState($iSkipButton, $GUI_ENABLE)
			GUICtrlSetState($iInputEdit, $GUI_FOCUS)
			_Generate(True)
		EndIf
	EndIf
EndFunc   ;==>_Enter

Func _LoadFile($sPath)
	If Not FileExists($sPath) Then Return 0
	Global $iRandom = False
	Global $iRefresh = False
	Global $iFinished = 0
	Global $iGivenLanguage = 1
	Global $iInputLanguage = 2

	Global $aLanguages = IniReadSection($sPath, "LANG")
	Global $aVocab = IniReadSection($sPath, "VOCAB")
	Global $aWords[$aVocab[0][0] + 1][$aLanguages[0][0]][2]
	For $i = 1 To $aVocab[0][0]
		Local $aSplit = StringSplit($aVocab[$i][1], ",")
		For $ii = 1 To $aLanguages[0][0]
			If $aLanguages[$ii][0] == "Locked" Then
				If $aLanguages[$ii][1] == "Yes" Then
					GUICtrlSetState($iGivenCombo, $GUI_DISABLE)
					GUICtrlSetState($iInputCombo, $GUI_DISABLE)
				Else
					GUICtrlSetState($iGivenCombo, $GUI_ENABLE)
					GUICtrlSetState($iInputCombo, $GUI_ENABLE)
				EndIf
			Else
				$aSplit[$ii] = StringReplace($aSplit[$ii], "Ã¤", "ä")
				$aSplit[$ii] = StringReplace($aSplit[$ii], "Ã¼", "ü")
				$aSplit[$ii] = StringReplace($aSplit[$ii], "Ã¶", "ö")
				$aSplit[$ii] = StringReplace($aSplit[$ii], "ÃŸ", "ß")
				$aWords[$i][$ii][0] = $aSplit[$ii]
				$aWords[$i][0][1] = False
			EndIf
		Next
	Next

	GUICtrlSetData($iGivenEdit, "")
	GUICtrlSetData($iSolutionButton, "Display Solution")
	GUICtrlSetData($iInputInput, "0")
	GUICtrlSetData($iGivenInput, $aVocab[0][0])
	GUICtrlSetState($iSkipButton, $GUI_ENABLE)

	Local $sInputLanguages = ""
	Local $sGivenLanguages = ""
	For $i = 1 To $aLanguages[0][0] - 1
		If $i <> $iGivenLanguage Then
			$sGivenLanguages &= $aLanguages[$i][1]
			If $i <> $aLanguages[0][0] Then $sGivenLanguages &= "|"
		EndIf
		If $i <> $iInputLanguage Then
			$sInputLanguages &= $aLanguages[$i][1]
			If $i <> $aLanguages[0][0] Then $sInputLanguages &= "|"
		EndIf
	Next
	GUICtrlSetData($iInputCombo, "")
	GUICtrlSetData($iGivenCombo, "")
	GUICtrlSetData($iInputCombo, $aLanguages[$iInputLanguage][1])
	GUICtrlSetData($iGivenCombo, $aLanguages[$iGivenLanguage][1])
	GUICtrlSetData($iSolutionButton, "Start")
	GUICtrlSetState($iSkipButton, $GUI_DISABLE)
	GUICtrlSetData($iInputCombo, $sInputLanguages, $aLanguages[$iInputLanguage][1])
	GUICtrlSetData($iGivenCombo, $sGivenLanguages, $aLanguages[$iGivenLanguage][1])
EndFunc   ;==>_LoadFile

Func _Skip()
	_Generate(False)
	GUICtrlSetState($iInputEdit, $GUI_FOCUS)
EndFunc

Func _Generate($bDone)
	GUICtrlSetData($iInputEdit, "")
	GUICtrlSetData($iGivenEdit, "")
	If $bDone = True Then $aWords[$iRandom][0][1] = $bDone

	$iFinished = 0
	For $i = 1 To $aVocab[0][0]
		If $aWords[$i][0][1] = False Then
			$iFinished += 1
		EndIf
	Next

	GUICtrlSetData($iInputInput, $iFinished)

	If $iFinished = 0 Then
		GUICtrlSetState($iSkipButton, $GUI_DISABLE)
		GUICtrlSetState($iInputEdit, $GUI_DISABLE)
		GUICtrlSetData($iGivenEdit, "")
		GuiCtrlSetData($iSolutionButton, "Start")
		MsgBox(0, "Finished Lesson", "Congratulations! You finished your lesson successfully." & @CRLF & "If you wish to start the lesson again, press the 'Start'-Button.")
	Else
		Do
			$iRandom = Random(1, $aVocab[0][0] + 1)
		Until $aWords[$iRandom][0][1] = False
		GUICtrlSetState($iSkipButton, $GUI_ENABLE)
		GuiCtrlSetData($iGivenEdit, StringReplace($aWords[$iRandom][$iGivenLanguage][0], "|", @CRLF & @CRLF))
	EndIf
EndFunc   ;==>_Generate

Func _GivenCombo()
	If GUICtrlRead($iGivenCombo) <> $aLanguages[$iGivenLanguage][1] Then
		If $iRefresh = False And GUICtrlRead($iInputInput) <> "0" Then
			GUICtrlSetState($iInputEdit, $GUI_ENABLE)
			GUICtrlSetData($iSolutionButton, "Display Solution")
			$iRefresh = True
			_Generate(True)
		EndIf

		For $i = 1 To $aLanguages[0][0]
			If $aLanguages[$i][1] = GUICtrlRead($iGivenCombo) Then
				If GUICtrlRead($iInputCombo) = GUICtrlRead($iGivenCombo) Then
					GuiCtrlSetData($iInputCombo, $aLanguages[$iGivenLanguage][1])
					$iInputLanguage = $iGivenLanguage
				EndIf
				$iGivenLanguage = $i
				If GUICtrlRead($iInputInput) <> "0" Then _Generate(False)
				ExitLoop
			EndIf
		Next
	EndIf
	GUICtrlSetState($iInputEdit, $GUI_FOCUS)
EndFunc

Func _InputCombo()
	If GUICtrlRead($iInputCombo) <> $aLanguages[$iInputLanguage][1] Then
		If $iRefresh = False And GUICtrlRead($iInputInput) <> "0" Then
			GUICtrlSetState($iInputEdit, $GUI_ENABLE)
			GUICtrlSetData($iSolutionButton, "Display Solution")
			$iRefresh = True
			_Generate(True)
		EndIf
		For $i = 1 To $aLanguages[0][0]
			If $aLanguages[$i][1] = GUICtrlRead($iInputCombo) Then
				If GUICtrlRead($iInputCombo) = GUICtrlRead($iGivenCombo) Then
					GuiCtrlSetData($iGivenCombo, $aLanguages[$iInputLanguage][1])
					$iGivenLanguage = $iInputLanguage
				EndIf
				$iInputLanguage = $i
				If GUICtrlRead($iInputInput) <> "0" Then _Generate(False)
				ExitLoop
			EndIf
		Next
	EndIf
	GUICtrlSetState($iInputEdit, $GUI_FOCUS)
EndFunc

Func _Solution()
	If $iFinished = 0 Then
		For $i = 1 To $aVocab[0][0]
			$aWords[$i][0][1] = False
		Next
		GUICtrlSetData($iSolutionButton, "Display Solution")
		GUICtrlSetState($iInputEdit, $GUI_ENABLE)
		$iRefresh = True
		_Generate(False)
	ElseIf $iRefresh = True Then
		GuiCtrlSetData($iInputEdit, StringReplace($aWords[$iRandom][$iInputLanguage][0], "|", ", "))
	Else
		_Enter()
	EndIf
	GUICtrlSetState($iInputEdit, $GUI_FOCUS)
EndFunc

Func _ChooseFile()
	_LoadFile(FileOpenDialog("Open Vocabulary File...", @MyDocumentsDir & "\My Vocabulary\", "Vocabulary File (*.vocab)"))
	GUICtrlSetState($iInputEdit, $GUI_FOCUS)
EndFunc

Func _About()
	MsgBox(64, "About", "Copyright 2013-2015 by Antonio Ianzano." & @CRLF & "Thank you for using this vocabulary trainer.")
EndFunc

Func _Exit()
	Exit
EndFunc