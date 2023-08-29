#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>

Dim $aAlphabeth[27] = [26,"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

$hGui = GUICreate("Key Generator",500,150)

$hOptionGroup = GUICtrlCreateGroup("Options",10,15,250,120)

Dim $hOptionRadio[5]
$hOptionRadio[0] = GUICtrlCreateRadio("Key",25,30)
$hOptionRadio[1] = GUICtrlCreateRadio("Chain",65,30)
$hOptionRadio[2] = GUICtrlCreateRadio("Numbers",115,30)
$hOptionRadio[3] = GUICtrlCreateRadio("Letters",180,30)

$hLengthLabel = GUICtrlCreateLabel("Length: ",25,62)
$hLengthInput = GUICtrlCreateInput("",65,58,50,25,$ES_NUMBER)

$hCapsCheckbox = GUICtrlCreateCheckbox("Capital letters only",125,58,100)

$hGenerateButton = GUICtrlCreateButton("Generate!",25,100)

GUICtrlCreateGroup("", -99, -99, 1, 1)

$hOutputGroup = GUICtrlCreateGroup("Output",275,15,215,120)
$hOutputLabel = GUICtrlCreateLabel("XXXXXXXXXXXXXXXXXXXXXXXX",290,45)
$hCopyButton = GUICtrlCreateButton("Copy to clipboard",290,65)
$hDeleteButton = GUICtrlCreateButton("Remove Selected",385,65)

GUICtrlSetState($hCopyButton,$GUI_DISABLE)
GUICtrlSetState($hOptionRadio[0],$GUI_CHECKED)
GUISetState()

Do
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 Exit
	  Case $hDeleteButton
		 GUICtrlSetData($hOutputLabel,"XXXXXXXXXXXXXXXXXXXXXXXX")
		 GUICtrlSetState($hCopyButton,$GUI_DISABLE)
	  Case $hCopyButton
		 ClipPut(GUICtrlRead($hOutputLabel))
	  Case $hOptionRadio[0],$hOptionRadio[3]
		 GUICtrlSetData($hLengthLabel,"Length: ")
		 GUICtrlSetState($hCapsCheckbox,$GUI_ENABLE)
	  Case $hOptionRadio[1]
		 GUICtrlSetData($hLengthLabel,"Blocks: ")
		 GUICtrlSetState($hCapsCheckbox,$GUI_ENABLE)
	  Case $hOptionRadio[2]
		 GUICtrlSetData($hLengthLabel,"Digits: ")
		 GUICtrlSetState($hCapsCheckbox,$GUI_DISABLE + $GUI_UNCHECKED)
	  Case $hGenerateButton
		 $iLength = GUICtrlRead($hLengthInput)
		 $sReturn = ""
		 Switch $GUI_CHECKED
			Case GUICtrlRead($hOptionRadio[0])
			   If $iLength > 0 And $iLength < 33 Then
				  If Mod(Random(0,1000,1),2) = 0 Then
					 $sReturn &= Random(1,9,1)
				  Else
					 $sTempKey = $aAlphabeth[Random(1,26)]
					 If GUICtrlRead($hCapsCheckbox) = $GUI_UNCHECKED Then
						If Mod(Random(0,1000,1),2) = 0 Then
						   $sTempKey = StringLower($sTempKey)
						EndIf
					 EndIf
					 $sReturn &= $sTempKey
				  EndIf
				  For $i = 1 To $iLength-1
					 If Mod(Random(0,1000,1),2) = 0 Then
						$sTempKey = $aAlphabeth[Random(1,26)]
						If GUICtrlRead($hCapsCheckbox) = $GUI_UNCHECKED Then
						   If Mod(Random(0,1000,1),2) = 0 Then
							  $sTempKey = StringLower($sTempKey)
						   EndIf
						EndIf
						$sReturn &= $sTempKey
					 Else
						$sReturn &= Random(0,9,1)
					 EndIf
				  Next
				  GUICtrlSetState($hCopyButton,$GUI_ENABLE)
			   Else
 				  MsgBox(16,"Error","The length has to be more than 0 and less than 33!" & @CRLF & "Please try it again.")
			   EndIf
			Case GUICtrlRead($hOptionRadio[1])
			   If $iLength > 0 And $iLength < 9 Then
				  For $ii = 0 To 5-1
					 If Mod(Random(0,1000,1),2) = 0 Then
						$sReturn &= Random(1,9,1)
					 Else
						$sTempKey = $aAlphabeth[Random(1,26)]
						If GUICtrlRead($hCapsCheckbox) = $GUI_UNCHECKED Then
						   If Mod(Random(0,1000,1),2) = 0 Then
							  $sTempKey = StringLower($sTempKey)
						   EndIf
						EndIf
						$sReturn &= $sTempKey
					 EndIf
				  Next
				  For $i = 1 To $iLength-1
					 $sReturn &= "-"
					 For $ii = 0 To 5-1
						If Mod(Random(0,1000,1),2) = 0 Then
						   $sTempKey = $aAlphabeth[Random(1,26)]
						   If GUICtrlRead($hCapsCheckbox) = $GUI_UNCHECKED Then
							  If Mod(Random(0,1000,1),2) = 0 Then
								 $sTempKey = StringLower($sTempKey)
							  EndIf
						   EndIf
						   $sReturn &= $sTempKey
						Else
						   $sReturn &= Random(0,9,1)
						EndIf
					 Next
				  Next
				  GUICtrlSetState($hCopyButton,$GUI_ENABLE)
			   Else
 				  MsgBox(16,"Error","There have to be more than 0 and less than 9 blocks!" & @CRLF & "Please try it again.")
			   EndIf
			Case GUICtrlRead($hOptionRadio[2])
			   If $iLength > 0 And $iLength < 33 Then
				  $sReturn = Random(1,9,1)
				  For $i = 1 To $iLength-1
					 $sReturn &= Random(0,9,1)
				  Next
				  GUICtrlSetState($hCopyButton,$GUI_ENABLE)
			   Else
 				  MsgBox(16,"Error","The digits have to be more than 0 and less than 33!" & @CRLF & "Please try it again.")
			   EndIf
			Case GUICtrlRead($hOptionRadio[3])
			   If $iLength > 0 And $iLength < 33 Then
				  $sReturn = ""
				  For $i = 0 To $iLength-1
					 $sTempKey = $aAlphabeth[Random(1,26)]
					 If GUICtrlRead($hCapsCheckbox) = $GUI_UNCHECKED Then
						If Mod(Random(0,1000,1),2) = 0 Then
						   $sTempKey = StringLower($sTempKey)
						EndIf
					 EndIf
					 $sReturn &= $sTempKey
				  Next
				  GUICtrlSetState($hCopyButton,$GUI_ENABLE)
			   Else
 				  MsgBox(16,"Error","The length has to be more than 0 and less than 33!" & @CRLF & "Please try it again.")
			   EndIf
		 EndSwitch
		 GUICtrlSetData($hOutputLabel,$sReturn)
   EndSwitch
Until Not 1