
;Idee: Der Tag hat 10 Stunden, Eine stunde hat 100 Minuten und diese jeweils 100 Sekunden
;Vorteil: Alles ist dezimal umrechenbar (200 Minuten sind einfach 2h und nicht 3h und 20Min)
;Sekunden sind etwas schneller als die "standard" Sekunden.

Global $hGUI = GUICreate('DezimalUhr', 120, 80)
GUISetState(@SW_SHOW)

Global $Stunden = 10, $Minuten = 10, $Sekunden = 10, $Zehntel = 10

Global $Label_Stunden = GUICtrlCreateLabel('Stunden: ' & $Stunden, 10, 10, 200)
GUICtrlSetFont(-1, 11)
Global $Label_Minuten = GUICtrlCreateLabel('Minuten: ' & $Minuten, 10, 30, 200)
GUICtrlSetFont(-1, 11)
Global $Label_Sekunden = GUICtrlCreateLabel('Sekunden: ' & $Sekunden, 10, 50, 200)
GUICtrlSetFont(-1, 11)

Global $Zeit = Int((@HOUR * 60 * 60 + @MIN * 60 + @SEC) / 0.864)
Global $Timer = TimerInit()

ConsoleWrite($Zeit)

While Not (GUIGetMsg() = -3)
	$Zeit = Int((@HOUR * 60 * 60 + @MIN * 60 + @SEC + @MSEC / 1000) / 0.864)
	If TimerDiff($Timer) > 90 Then ; alle 90 standard Millisekunden
		$Timer = TimerInit()
		$Stunden = Int($Zeit / 10000)
		$Zeit -= $Stunden * 10000
		$Minuten = Int($Zeit / 100)
		$Zeit -= $Minuten * 100
		$Sekunden = $Zeit
		GUICtrlSetData($Label_Stunden, 'Stunden: ' & $Stunden)
		GUICtrlSetData($Label_Minuten, 'Minuten: ' & $Minuten)
		GUICtrlSetData($Label_Sekunden, 'Sekunden: ' & $Sekunden)
	EndIf
WEnd
