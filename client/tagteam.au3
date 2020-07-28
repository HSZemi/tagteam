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

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode

Local $height = 150
If $secret == "" Then
   $height = 110
EndIf

Local $hMainGUI = GUICreate("TagTeam", 180, $height, -1, -1, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), $WS_EX_TOPMOST)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
Global $marcoProIndicatorLabel = GUICtrlCreateLabel("►", 15, 10, 10, 16)
Global $marcoNoobIndicatorLabel = GUICtrlCreateLabel("►", 15, 30, 10, 16)
Global $marcoProLabel = GUICtrlCreateLabel("", 30, 10, 90, 16)
Global $marcoNoobLabel = GUICtrlCreateLabel("", 30, 30, 90, 16)
Global $marcoProTimeLabel = GUICtrlCreateLabel("", 130, 10, 100, 16)

Global $poloProIndicatorLabel = GUICtrlCreateLabel("►", 15, 60, 10, 16)
Global $poloNoobIndicatorLabel = GUICtrlCreateLabel("►", 15, 80, 10, 16)
Global $poloProLabel = GUICtrlCreateLabel("", 30, 60, 90, 16)
Global $poloNoobLabel = GUICtrlCreateLabel("", 30, 80, 90, 16)
Global $poloProTimeLabel = GUICtrlCreateLabel("", 130, 60, 100, 16)

Global $marcoProActive = False
Global $poloProActive = False

Global $helpButton = -1
If $secret <> "" Then
   $helpButton = GUICtrlCreateButton("Help!", 30, 110, 120)
   GUICtrlSetOnEvent($helpButton, "helpButton")
EndIf

GUISetState(@SW_SHOW, $hMainGUI)

While 1
    Sleep(800) ; Sleep to reduce CPU usage
	updateGuiValues()
WEnd

Func helpButton()
    HttpPost("https://aoe2se.uber.space/tagteam/activate", "secret="&$secret&"&team="&$ownTeam)
EndFunc

Func CLOSEButton()
    Exit
EndFunc


Func updateGuiValues()
   $URL = "https://aoe2se.uber.space/tagteam/status"
   $data = _INetGetSource($URL)
   $object = Json_Decode($data)
   $marcoPro = Json_Get($object, ".marco.pro")
   $marcoNoob = Json_Get($object, ".marco.noob")
   $marcoProActiveFor = Json_Get($object, ".marco.proActiveFor")
   $marcoProCooldown = Json_Get($object, ".marco.proCooldown")
   $poloPro = Json_Get($object, ".polo.pro")
   $poloNoob = Json_Get($object, ".polo.noob")
   $poloProActiveFor = Json_Get($object, ".polo.proActiveFor")
   $poloProCooldown = Json_Get($object, ".polo.proCooldown")
   GUICtrlSetData($marcoProLabel, $marcoPro)
   GUICtrlSetData($marcoNoobLabel, $marcoNoob)
   GUICtrlSetData($poloProLabel, $poloPro)
   GUICtrlSetData($poloNoobLabel, $poloNoob)

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
   SplashImageOn($filename, $filename, -1, -1, -1, -1, $DLG_NOTITLE);
   Sleep(2000);
   SplashOff();
EndFunc