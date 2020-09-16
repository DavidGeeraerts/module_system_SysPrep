:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
SETLOCAL Enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $SCRIPT_NAME=module_system_SysPrep
SET $SCRIPT_VERSION=0.1.0
SET $SCRIPT_BUILD=20200916-1500
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=81
mode con:lines=40
Prompt $G
color 4E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables
::###########################################################################::

SET $CUSTOM_USER=sc

::	Working Directory
SET $WD=%PUBLIC%\Documents\%$SCRIPT_NAME%

::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:SLT
::	Start Lapse Time
::	will be used to calculate how long the script runs for
	SET $START_TIME=%Time%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	Volume
	CD /D "%~dp0" 2> nul
	SET $VOLUME=%~d1

:: Directory Check
	IF NOT EXIST "%$WD%" MD "%$WD%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:banner
cls
:: CONSOLE OUTPUT 
ECHO  ****************************************************************
ECHO. 
ECHO      %$SCRIPT_NAME% %$SCRIPT_VERSION%
ECHO.
ECHO      %Date% %Time%
ECHO  ****************************************************************
ECHO.
ECHO.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	speed up the process from reboots
IF NOT EXIST "%$WD%\1_Administrator_Complete.txt" GoTo Admin
IF NOT EXIST "%$WD%\2_USER_Profiles_Complete.txt" GoTo UPC
IF NOT EXIST "%$WD%\3_Scheduled_Task_Complete.txt" GoTo stc
IF NOT EXIST "%$WD%\4_Winddows_Update_Complete.txt" GoTo WU
IF NOT EXIST "%$WD%\5_Disk_Check_Complete.txt" GoTo fdc
IF NOT EXIST "%$WD%\6_Disk_CleanMGR_Complete.txt" GoTo CM
IF NOT EXIST "%$WD%\7_Final_Reboot_Complete.txt" GoTo FB
IF NOT EXIST "%$WD%\8_SysPrep_Running.txt" GoTo sysprep


::	#1
::	Configure Local Administrator Account
::	there's a space between username and options which is the password (blank)
:Admin

	IF EXIST "%$WD%\1_Administrator_Complete.txt" GoTo skipAdmin
	Echo Processing local Administrator...
	NET USER Administrator  /ACTIVE:YES && (echo %DATE% %TIME% > %$WD%\1_Administrator_Complete.txt)
	logoff
	Exit
:skipAdmin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
::	#2
::	DELETE CUSTOM USER ACCOUNT
::	"net user <userName> /DELETE" doesn't delete the user profile, just the account
::	Depends on DELPROF2
:UPC

	IF EXIST "%$WD%\2_USER_Profiles_Complete.txt" GoTo skipUPC
	echo Processing User Profile cleanup...
	cd /D "%SYSTEMROOT%\System32"
	IF NOT EXIST "%SYSTEMDRIVE%\Windows\System32\delprof2.exe" Robocopy "%$VOLUME%\Tools" "%SYSTEMDRIVE%\Windows\System32" delprof2.exe /r:1 /w:2
	IF NOT EXIST "%SYSTEMROOT%\System32\DelProf2.exe" GoTo skipDP2
	delprof2 /l
	delprof2 /u /i /ed:admin*
	echo %DATE% %TIME% > "%$WD%\2_USER_Profiles_Complete.txt"
	echo Done.
:skipDP2
::	Fall back mode for no delprof2
	NET USER %$CUSTOM_USER% /DELETE
	IF EXIST "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%"
	echo %DATE% %TIME% > "%$WD%\2_USER_Profiles_Complete.txt"
	echo Done.
:skipUPC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#3
::	TASK SCHEDULER CLEANUP
::	OneDrive leaves orphaned scheduled tasks
:stc

	IF EXIST "%$WD%\3_Scheduled_Task_Complete.txt" GoTo skipSTC
	echo Processing Scheduled Taks cleanip...
	FOR /F "tokens=2 delims=\" %%P IN ('SCHTASKS /QUERY /FO LIST ^| FIND /I "OneDrive"') DO SCHTASKS /DELETE /F /TN "%%P"
	echo %DATE% %TIME% > "%$WD%\3_Scheduled_Task_Complete.txt"
	echo Done.
:skipSTC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#4
:: Process Windows Updates
:WU

	echo Processing Windows Updates...
	@powershell Get-ExecutionPolicy -list
	@powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -scope CurrentUser -Force 
:: Windows Update PowerShell Module
:: https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc
::	by default for non-domain joined computers, may require security config
	@powershell Install-PackageProvider -name NuGet -Force
	@powershell Install-Module -name PSWindowsUpdate -Force
	@powershell Import-Module PSWindowsUpdate
	@powershell Get-WindowsUpdate
	@powershell Install-WindowsUpdate -AcceptAll -AutoReboot
	@powershell Get-WURebootStatus | FIND /I "False" && echo %DATE% %TIME% > "%$WD%\4_Winddows_Update_Complete.txt"

::	UsoClient Windows 10 only
::		not finding UsoClient reliable
::	UsoClient StartScan
::	UsoClient StartDownload
::	UsoClient StartInstall
::	UsoClient RestartDevice
	echo Done.
	
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#5
::	Check if System Drive is dirty
:fdc

	IF EXIST "%$WD%\5_Disk_Check_Complete.txt" GoTo skipFDC
	echo Checking System Disk... 
	CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && echo y | chkdsk %systemdrive% /B
	echo %DATE% %TIME% > "%$WD%\5_Disk_Check_Complete.txt"
:skipFDC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#6
::	CLEANMGR
:CM

	IF EXIST "%$WD%\6_Disk_CleanMGR_Complete.txt" GoTo skipCM
	echo Processing Clean Manager for disk space...
	CLEANMGR /SAGESET:1
	Timeout /T 20
	CLEANMGR /SAGERUN:1
	echo %DATE% %TIME% > "%$WD%\6_Disk_CleanMGR_Complete.txt"
	Done.
:skipCM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#7
::	Final reboot
:FB

	IF EXIST "%$WD%\7_Final_Reboot_Complete.txt" GoTo skipFB
	echo Processing final reboot...
	echo %DATE% %TIME% > "%$WD%\7_Final_Reboot_Complete.txt"
	shutdown /R /T 5 /f /c "Final Shutdown for SysPrep."
	echo %DATE% %TIME% > "%$WD%\7_Final_Reboot_Complete.txt"
	echo Done.
	exit
:skipFB
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#8
::	SysPrep
:sysprep

	echo Processing SysPrep...
	echo %DATE% %TIME% > "%$WD%\8_SysPrep_Running.txt"
	CD /D "%SystemRoot%\System32\SysPrep"
	IF EXIST "%SystemRoot%\System32\SysPrep\Panther" RD /S /Q "%SystemRoot%\System32\SysPrep\Panther"
	cd
	sysprep /oobe /generalize /shutdown

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:End
ENDLOCAL
Exit /B

