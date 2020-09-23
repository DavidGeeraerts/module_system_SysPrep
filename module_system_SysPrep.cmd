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
SET $SCRIPT_VERSION=1.1.0
SET $SCRIPT_BUILD=20200923-0900
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=70
mode con:lines=40
Prompt $G
color 4E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables
::###########################################################################::

SET $CUSTOM_USER=Scientific

::	Working Directory
SET $WD=%PUBLIC%\Documents\%$SCRIPT_NAME%

::	Module log
SET $MODULE_LOG=%$SCRIPT_NAME%.log


::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::

:: Timeout (seconds)
SET $TIMEOUT=10

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:SLT
::	Start Time
	SET $START_TIME=%Time%
	SET $START_DATE=%Date%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Directory Check
	IF NOT EXIST "%$WD%" MD "%$WD%"

:: Open Directory
	@explorer %$WD%

:start
	IF EXIST "%$WD%\%$MODULE_LOG%" Goto skipStart
	echo %DATE% %TIME% Start... >> "%$WD%\%$MODULE_LOG%"
	echo Script Version: %$SCRIPT_VERSION% >> "%$WD%\%$MODULE_LOG%"
	echo script Build: %$SCRIPT_BUILD% >> "%$WD%\%$MODULE_LOG%"
	echo Computer: %COMPUTERNAME% >> "%$WD%\%$MODULE_LOG%"
	echo Active session... >> "%$WD%\%$MODULE_LOG%"
:skipStart

::	Volume
	CD /D "%~dp0" 2> nul
	SET $PATH=%~dp0
	Call :get-volume %$PATH%
:get-volume
	SET $VOLUME=%~d1

:: Setup on Startup
::	mostly automates Windows Updates for reboots
	IF EXIST "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\module_system_SysPrep" GoTo skipSetupS
	mklink "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" "%$VOLUME%\modules\module_system_SysPrep\module_system_SysPrep.cmd"
:skipSetupS


::	Step number
SET	$STEP_NUM=0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=0

:banner
cls
:: CONSOLE OUTPUT 
ECHO   ****************************************************************
ECHO. 
ECHO      %$SCRIPT_NAME% %$SCRIPT_VERSION% [%$SCRIPT_BUILD%]
ECHO.
ECHO      %$START_DATE% %$START_TIME%
echo.
echo.		Step #: %$STEP_NUM%
echo.
ECHO   ****************************************************************
ECHO.
ECHO.
IF %$BANNER% EQU 1 GoTo :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=1

rem	speed up the process from reboots
IF NOT EXIST "%$WD%\1_Administrator_Complete.txt" GoTo Admin
IF NOT EXIST "%$WD%\2_USER_Profiles_Complete.txt" GoTo UPC
IF NOT EXIST "%$WD%\3_Scheduled_Task_Complete.txt" GoTo stc
IF NOT EXIST "%$WD%\4_Winddows_Update_Complete.txt" GoTo WU
IF NOT EXIST "%$WD%\5_Disk_Check_Complete.txt" GoTo fdc
IF NOT EXIST "%$WD%\6_Disk_CleanMGR_Complete.txt" GoTo CM
IF NOT EXIST "%$WD%\7_Final_Reboot_Complete.txt" GoTo FB
IF NOT EXIST "%$WD%\8_SysPrep_Running.txt" GoTo sysprep
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#1
::	Configure Local Administrator Account

:Admin
	SET	$STEP_NUM=1
	CALL :banner
	IF EXIST "%$WD%\1_Administrator_Complete.txt" GoTo skipAdmin
	Echo Processing local Administrator...
	rem	there's a space between username and options which is the password (blank)
	NET USER Administrator  /ACTIVE:YES && (echo %DATE% %TIME% > %$WD%\1_Administrator_Complete.txt)
	NET USER >> "%$WD%\1_Administrator_Complete.txt"
	NET LOCALGROUP Administrators >> "%$WD%\1_Administrator_Complete.txt"
	NET USER Administrator >> "%$WD%\1_Administrator_Complete.txt"
	Timeout /T %$TIMEOUT%
	::	no need to logoff if already logged in as Administrator
	IF "%USERNAME%"=="Administrator" GoTo skipAdmin
	logoff
	GoTo End
:skipAdmin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
::	#2
::	DELETE CUSTOM USER ACCOUNT
::	"net user <userName> /DELETE" doesn't delete the user profile, just the account
::	Depends on DELPROF2
:UPC
	SET	$STEP_NUM=2
	CALL :banner
	IF EXIST "%$WD%\2_USER_Profiles_Complete.txt" GoTo skipUPC
	echo Processing User Profile cleanup...
	::	prefer where launched
	IF NOT EXIST "%SYSTEMROOT%\System32\delprof2.exe" Robocopy "%$VOLUME%\Tools" "%SYSTEMROOT%\System32" delprof2.exe /r:1 /w:2
	IF EXIST "%$VOLUME%\Tools" (CD /D "%$VOLUME%\Tools") ELSE (cd /D "%SYSTEMROOT%\System32")
	delprof2 /l
	delprof2 /u /i /ed:admin*
	delprof2 /l
	rem In case delprof fails, do it manaully
	FIND /I "%$CUSTOM_USER%" "%$WD%\Local_Users.txt" && (NET USER %$CUSTOM_USER% /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%")
	FIND /I "defaultuser0" "%$WD%\Local_Users.txt" && (NET USER defaultuser0 /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\defaultuser0" RD /S /Q "%SYSTEMDRIVE%\Users\defaultuser0")
	echo Done.
	rem	can check this file to make sure user(s) have been deleted. 
	net user > "%$WD%\Local_Users.txt"
	echo %DATE% %TIME% > "%$WD%\2_USER_Profiles_Complete.txt"
	rem try again on next reboot if cleaning up user(s) failed
	FIND /I "%$CUSTOM_USER%" "%$WD%\Local_Users.txt" && DEL /F /Q "%$WD%\2_USER_Profiles_Complete.txt"
	Timeout /T %$TIMEOUT%
:skipUPC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#3
::	TASK SCHEDULER CLEANUP
::	OneDrive leaves orphaned scheduled tasks
:stc
	SET	$STEP_NUM=3
	CALL :banner
	IF EXIST "%$WD%\3_Scheduled_Task_Complete.txt" GoTo skipSTC
	echo Processing Scheduled Taks cleanup...
	FOR /F "tokens=2 delims=\" %%P IN ('SCHTASKS /QUERY /FO LIST ^| FIND /I "OneDrive"') DO SCHTASKS /DELETE /F /TN "%%P"
	echo %DATE% %TIME% > "%$WD%\3_Scheduled_Task_Complete.txt"
	echo Done.
	Timeout /T %$TIMEOUT%
:skipSTC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#4
:: Process Windows Updates
:WU
	SET	$STEP_NUM=4
	CALL :banner
	echo Processing Windows Updates...
	@powershell Get-ExecutionPolicy -list
	::	by default for non-domain joined computers, may require security config
	@powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -scope CurrentUser -Force 
	:: Windows Update PowerShell Module
	:: https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc
	@powershell Install-PackageProvider -name NuGet -Force
	@powershell Install-Module -name PSWindowsUpdate -Force
	@powershell Import-Module PSWindowsUpdate
	@powershell Get-WindowsUpdate
	@powershell Install-WindowsUpdate -AcceptAll -AutoReboot
	echo Reboot?
	@powershell Get-WURebootStatus | FIND /I "False" && echo %DATE% %TIME% > "%$WD%\4_Winddows_Update_Complete.txt"
	echo Done.
	Timeout /T %$TIMEOUT%
	
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#5
::	Check if System Drive is dirty
:fdc
	SET	$STEP_NUM=5
	CALL :banner
	IF EXIST "%$WD%\5_Disk_Check_Complete.txt" GoTo skipFDC
	echo Checking System Disk... 
	CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && echo y | chkdsk %systemdrive% /B
	echo %DATE% %TIME% > "%$WD%\5_Disk_Check_Complete.txt"
	echo Done.
	Timeout /T %$TIMEOUT%
:skipFDC
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#6
::	CLEANMGR
:CM
	SET	$STEP_NUM=6
	CALL :banner
	IF EXIST "%$WD%\6_Disk_CleanMGR_Complete.txt" GoTo skipCM
	echo Processing Clean Manager for disk space...
	REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /S /V StateFlags0100 1> nul 2> nul
	SET $CLEANER_STATUS=%ERRORLEVEL%
	IF %$CLEANER_STATUS% EQU 0 GoTo jumpCS
	CLEANMGR /SAGESET:100
	Timeout /T %$TIMEOUT%
:jumpCS	
	CLEANMGR /SAGERUN:100
	echo %DATE% %TIME% > "%$WD%\6_Disk_CleanMGR_Complete.txt"
	echo Done.
	Timeout /T %$TIMEOUT%
:skipCM
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#7
::	Final reboot
:FB
	SET	$STEP_NUM=7
	CALL :banner
	IF EXIST "%$WD%\7_Final_Reboot_Complete.txt" GoTo skipFB
	echo Processing final reboot...
	DEL /F /Q /S "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\module_system_SysPrep*" 2> nul
	echo %DATE% %TIME% > "%$WD%\7_Final_Reboot_Complete.txt"
	shutdown /R /T 5 /f /c "Final Shutdown for SysPrep."
	echo Done.
	::	remove from startup
	::	there's no point in running after reboot since sysprep requires admin privilege
	exit
:skipFB
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#8
::	SysPrep
:sysprep
	SET	$STEP_NUM=8
	CALL :banner
	echo Processing SysPrep...
	Timeout /T %$TIMEOUT%
	echo %DATE% %TIME% > "%$WD%\8_SysPrep_Running.txt"
	CD /D "%SystemRoot%\System32\SysPrep"
	CD
	openfiles 1> nul 2> nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% NEQ 0 GoTo sysprepE
	echo SysPrep activation %DATE% %TIME% >> "%$WD%\%$MODULE_LOG%"
	echo End. >> "%$WD%\%$MODULE_LOG%"
	robocopy "%$WD%" "%SystemRoot%\System32\SysPrep\%$SCRIPT_NAME%" /MOVE /R:1 /W:2
	IF EXIST "%SystemRoot%\System32\SysPrep\Panther" RD /S /Q "%SystemRoot%\System32\SysPrep\Panther"
	:: Needs to run with Administrative privilege
	sysprep /oobe /generalize /shutdown
	exit
:sysprepE
	Echo FATAL: Not running with Administrative privilege!
	ECHO.
	echo Run as administrator!
	@explorer %$PATH%
	PAUSE

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:End
ENDLOCAL
Exit /B
