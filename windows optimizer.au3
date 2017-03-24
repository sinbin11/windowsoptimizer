#RequireAdmin
#Region
	#AutoIt3Wrapper_Icon=icon.ico
	#AutoIt3Wrapper_UseX64=n
	#AutoIt3Wrapper_Res_Description=TheSinBin
	#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
	#AutoIt3Wrapper_Res_LegalCopyright=TheSinBin
	#AutoIt3Wrapper_Res_Field=Author|Ferit Etem
#EndRegion
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)
OnAutoItExitRegister("_EXIT")
_errors()
Global $regkey = "Windows Optimizer"
Global $interval = 100
$process = ProcessList()
Global $list = ""
For $i = 3 To $process[0][0]
	$list = $list & $process[$i][0] & "|"
Next
$list = StringTrimRight($list, 1)
Global $processlist = StringSplit($list, "|")
$startup = TrayCreateItem("Başlangıçta Çalıştır")
TrayItemSetOnEvent(-1, "_STARTUP_WINDOWS")
$reg_read = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", $regkey)
If $reg_read <> "" Then TrayItemSetState($startup, 1)
TrayCreateItem("Çıkış")
TrayItemSetOnEvent(-1, "_EXIT")
TraySetState()
While 1
	If @error <> 0 Then ContinueLoop
	For $i = 1 To UBound($processlist) - 1
		$pid = ProcessExists($processlist[$i])
		If $pid Then _reducememory($pid)
	Next
	_reducememory()
	Sleep($interval)
WEnd

Func _reducememory($i_pid = -1)
	If $i_pid <> -1 Then
		Local $ai_handle = DllCall("kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", False, "int", $i_pid)
		Local $ai_return = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", $ai_handle[0])
		DllCall("kernel32.dll", "int", "CloseHandle", "int", $ai_handle[0])
	Else
		Local $ai_return = DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
	EndIf
	Return $ai_return[0]
EndFunc

Func _startup_windows()
	Local $get_state = TrayItemGetState($startup)
	If $get_state = 64 + 1 Then
		RegWrite("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", $regkey, "REG_SZ", @ScriptFullPath)
	Else
		RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", $regkey)
	EndIf
EndFunc

Func _errors()
	If UBound(ProcessList(@ScriptName)) > 2 Then
		MsgBox(16, "Hata!", " " & @ScriptName & " zaten çalışıyor! ", 5)
		Exit 0
	EndIf
EndFunc

Func _exit()
	Exit
EndFunc
