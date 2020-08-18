#include<AutoItConstants.au3>
#include <Inet.au3>
#include "Json.au3"
#include "WinHttp.au3"
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <ColorConstants.au3>

Global $ownTeam = IniRead("tagteam.ini", "tagteam", "team", "")
Global $secret = IniRead("tagteam.ini", "tagteam", "secret", "")
Global $urlprefix = IniRead("tagteam.ini", "tagteam", "urlprefix", "http://localhost")

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Local $height = 125
If $secret == "" Then
   $height = 110
EndIf

Global $hMainGUI = GUICreate("TagTeam", 130, $height, -1, -1, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), $WS_EX_TOPMOST)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
Global $marcoProIndicatorLabel = GUICtrlCreateLabel("►", 5, 5, 10, 16)
Global $marcoNoobIndicatorLabel = GUICtrlCreateLabel("►", 5, 25, 10, 16)
Global $marcoProLabel = GUICtrlCreateLabel("", 20, 5, 65, 16)
Global $marcoNoobLabel = GUICtrlCreateLabel("", 20, 25, 65, 16)
Global $marcoProTimeLabel = GUICtrlCreateLabel("", 90, 5, 35, 16)
Global $marcoCounterLabel = GUICtrlCreateLabel("", 90, 25, 35, 16)

Local $x = 5
Local $y = 45
Local $h = 1
Local $w = 120
GUICtrlCreateLabel("", $x, $y, $w, $h)
GUICtrlSetBkColor(-1, 0x999999)
GUICtrlCreateLabel("", $x + 1, $y, $w, 1)
GUICtrlSetBkColor(-1, 0x999999)
GUICtrlCreateLabel("", $x + 1, $y + 1, $w, $h)
GUICtrlSetBkColor(-1, 0xffffff)

Global $poloProIndicatorLabel = GUICtrlCreateLabel("►", 5, 50, 10, 16)
Global $poloNoobIndicatorLabel = GUICtrlCreateLabel("►", 5, 70, 10, 16)
Global $poloProLabel = GUICtrlCreateLabel("", 20, 50, 65, 16)
Global $poloNoobLabel = GUICtrlCreateLabel("", 20, 70, 65, 16)
Global $poloProTimeLabel = GUICtrlCreateLabel("", 90, 50, 35, 16)
Global $poloCounterLabel = GUICtrlCreateLabel("", 90, 70, 35, 16)

Global $marcoProActive = False
Global $poloProActive = False

Global $helpButton = -1
If $secret <> "" Then
   $helpButton = GUICtrlCreateButton("Help!", 5, 95, 120)
   GUICtrlSetOnEvent($helpButton, "helpButton")
EndIf

GUISetState(@SW_SHOW, $hMainGUI)

While 1
    Sleep(800) ; Sleep to reduce CPU usage
	updateGuiValues()
WEnd

Func helpButton()
    HttpPost($urlprefix&"/activate", "secret="&$secret&"&team="&$ownTeam)
EndFunc

Func CLOSEButton()
    Exit
EndFunc


Func updateGuiValues()
   $URL = $urlprefix&"/status"
   $data = _INetGetSource($URL)
   $object = Json_Decode($data)
   $marcoPro = Json_Get($object, ".marco.pro")
   $marcoNoob = Json_Get($object, ".marco.noob")
   $marcoProActiveFor = Json_Get($object, ".marco.proActiveFor")
   $marcoProCooldown = Json_Get($object, ".marco.proCooldown")
   $marcoCounter = Json_Get($object, ".marco.counter")
   $poloPro = Json_Get($object, ".polo.pro")
   $poloNoob = Json_Get($object, ".polo.noob")
   $poloProActiveFor = Json_Get($object, ".polo.proActiveFor")
   $poloProCooldown = Json_Get($object, ".polo.proCooldown")
   $poloCounter = Json_Get($object, ".polo.counter")
   GUICtrlSetData($marcoProLabel, $marcoPro)
   GUICtrlSetData($marcoNoobLabel, $marcoNoob)
   GUICtrlSetData($marcoCounterLabel, "# "&$marcoCounter)
   GUICtrlSetData($poloProLabel, $poloPro)
   GUICtrlSetData($poloNoobLabel, $poloNoob)
   GUICtrlSetData($poloCounterLabel, "# "&$poloCounter)

   If $marcoProActiveFor > 0 Then
	  GUICtrlSetData($marcoProIndicatorLabel, "►")
	  GUICtrlSetData($marcoNoobIndicatorLabel, "")
	  GUICtrlSetData($marcoProTimeLabel, formatTime($marcoProActiveFor))
	  GUICtrlSetBkColor($marcoProLabel, $COLOR_GREEN)
	  GUICtrlSetColor($marcoProLabel, $COLOR_WHITE)
	  GUICtrlSetColor($marcoProTimeLabel, $COLOR_BLACK)
	  disableHelpButton("marco")
	  If Not $marcoProActive Then
		 $marcoProActive = True
		 showPlayer("marco-on.jpg")
	  EndIf
   Else
	  GUICtrlSetData($marcoProIndicatorLabel, "")
	  GUICtrlSetData($marcoNoobIndicatorLabel, "►")
	  GUICtrlSetBkColor($marcoProLabel, $GUI_BKCOLOR_TRANSPARENT)
	  GUICtrlSetColor($marcoProLabel, $COLOR_BLACK)
	  GUICtrlSetColor($marcoProTimeLabel, $COLOR_GRAY)
	  If $marcoProCooldown > 0 Then
		 GUICtrlSetData($marcoProTimeLabel, formatTime($marcoProCooldown))
		 disableHelpButton("marco")
	  Else
		 GUICtrlSetData($marcoProTimeLabel, "")
		 enableHelpButton("marco")
	  EndIf
	  If $marcoProActive Then
		 $marcoProActive = False
		 showPlayer("marco-off.jpg")
	  EndIf
   EndIf

   If $poloProActiveFor > 0 Then
	  GUICtrlSetData($poloProIndicatorLabel, "►")
	  GUICtrlSetData($poloNoobIndicatorLabel, "")
	  GUICtrlSetData($poloProTimeLabel, formatTime($poloProActiveFor))
	  GUICtrlSetBkColor($poloProLabel, $COLOR_GREEN)
	  GUICtrlSetColor($poloProLabel, $COLOR_WHITE)
	  GUICtrlSetColor($poloProTimeLabel, $COLOR_BLACK)
	  disableHelpButton("polo")
	  If Not $poloProActive Then
		 $poloProActive = True
		 showPlayer("polo-on.jpg")
	  EndIf
   Else
	  GUICtrlSetData($poloProIndicatorLabel, "")
	  GUICtrlSetData($poloNoobIndicatorLabel, "►")
	  GUICtrlSetBkColor($poloProLabel, $GUI_BKCOLOR_TRANSPARENT)
	  GUICtrlSetColor($poloProLabel, $COLOR_BLACK)
	  GUICtrlSetColor($poloProTimeLabel, $COLOR_GRAY)
	  If $poloProCooldown > 0 Then
		 GUICtrlSetData($poloProTimeLabel, formatTime($poloProCooldown))
		 disableHelpButton("polo")
	  Else
		 GUICtrlSetData($poloProTimeLabel, "")
		 enableHelpButton("polo")
	  EndIf
	  If $poloProActive Then
		 $poloProActive = False
		 showPlayer("polo-off.jpg")
	  EndIf
   EndIf

EndFunc

Func formatTime($seconds)
   Local $m = Int($seconds / 60)
   Local $s = Mod($seconds, 60)
   return StringFormat("%02i:%02i", $m, $s)
EndFunc

Func enableHelpButton($team)
   If $team == $ownTeam And $secret <> "" Then
	  GUICtrlSetState($helpButton, $GUI_ENABLE)
   EndIf
EndFunc

Func disableHelpButton($team)
   If $team == $ownTeam And $secret <> "" Then
	  GUICtrlSetState($helpButton, $GUI_DISABLE)
   EndIf
EndFunc


Func showPlayer($filename)
   $pos = WinGetPos($hMainGUI)
   $xpos = $pos[0] - (200 - $pos[2]) / 2
   $ypos = $pos[1] - (200 - $pos[3]) / 2
   SplashImageOn($filename, $filename, 200, 200, $xpos, $ypos, $DLG_NOTITLE)
   Beep(500, 2000)
   SplashOff()
EndFunc