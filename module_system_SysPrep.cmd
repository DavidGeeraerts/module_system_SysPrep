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
SET $SCRIPT_VERSION=1.5.0
SET $SCRIPT_BUILD=20210709-1000
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=70
mode con:lines=40
Prompt $G
color 4E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables
::###########################################################################::

:: Timeout (seconds)
SET $TIMEOUT=10

::	Unattend.xml
::	Remove all Unattend.xml from the systemdrive
::	before running SysPrep
::	{No,Yes}
::	0 = No
::	1 = Yes
SET $UNATTEND_CLEAN=Yes

::	Unattend directory from the root of the volume
SET $UNATTEND_DIR=Unattend

::	Name of unattend file to seed
SET $Unattend_FILE=unattend.xml

SET $CUSTOM_USER=Scientific

::	From the root of the volume
SET $DELPROF2_PATH=Tools


::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::

::	Working Directory
SET $WD=%PUBLIC%\Documents\%$SCRIPT_NAME%

::	Module log
SET $MODULE_LOG=%$SCRIPT_NAME%.log


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SLT
	:: Start Time Start Date
	SET $START_TIME=%Time%
	SET $START_DATE=%Date%
	
:dir
	:: Directory Check
	IF NOT EXIST "%$WD%\var" MD "%$WD%\var"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $BANNER=0
SET $STEP_NUM=0
SET "$STEP_DESCRIP=Preperations"

:banner
cls
:: CONSOLE OUTPUT 
ECHO   ****************************************************************
ECHO. 
ECHO      %$SCRIPT_NAME% %$SCRIPT_VERSION% [%$SCRIPT_BUILD%]
ECHO.
ECHO      %$START_DATE% %$START_TIME%
echo.
echo.		Process #: %$STEP_NUM% (%$STEP_DESCRIP%)
echo.
ECHO   ****************************************************************
ECHO.
ECHO.
IF %$BANNER% EQU 1 GoTo :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

Echo Preparing to run the following:
echo.
IF NOT EXIST "%$WD%\1_Administrator_Complete.txt" echo 1. Administrator, local configuration
IF NOT EXIST "%$WD%\2_USER_Profiles_Complete.txt" echo 2. Users, cleanup local users
IF NOT EXIST "%$WD%\3_Scheduled_Task_Complete.txt" echo 3. Scheduled Task, cleanup
IF NOT EXIST "%$WD%\4_Winddows_Update_Complete.txt" echo 4. Windows Update
IF NOT EXIST "%$WD%\5_Disk_Check_Complete.txt" echo 5. Disk Check, for dirty bit
IF NOT EXIST "%$WD%\6_Disk_CleanMGR_Complete.txt" echo 6. CleanMgr, run disk cleanup
IF NOT EXIST "%$WD%\7_Final_Reboot_Complete.txt" echo 7. Final reboot, in preperation for running SysPrep
echo 8. SysPrep
echo.
Timeout /T %$TIMEOUT%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ISO8601
	::	Make ISO timestamp
	IF EXIST "%$WD%\var\var_ISO8601_Date.txt" GoTo skipISO
	@powershell Get-Date -format "yyyy-MM-dd" > "%$WD%\var\var_ISO8601_Date.txt"
	:skipISO
	SET /P $ISO_DATE= < "%$WD%\var\var_ISO8601_Date.txt"

:DT
	IF EXIST "%$WD%\var\var_Time.txt" GoTo skipT 
	@powershell Get-Date -format "HHMM" > "%$WD%\var\var_Time.txt"
	:: Time for Script run for folder creation
	:skipT
	SET $TIME= < "%$WD%\var\var_Time.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:Param

	::	Default User
	SET $PARAMETER1=%~1
	IF DEFINED $PARAMETER1 echo %$PARAMETER1%> "%$WD%\var\var_Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 IF EXIST "%$WD%\var\var_Parameter-1.txt" SET /P $PARAMETER1= < "%$WD%\var\var_Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 GoTo skipParam
	SET $CUSTOM_USER=%$PARAMETER1%
	::	Unattend.xml Cleanup
	SET $PARAMETER2=%~2
	IF DEFINED $PARAMETER2 echo %$PARAMETER3%> "%$WD%\var\var_Parameter-2.txt"
	IF NOT DEFINED $PARAMETER2 IF EXIST "%$WD%\var\var_Parameter-2.txt" SET /P $PARAMETER3= < "%$WD%\var\var_Parameter-2.txt"
	IF NOT DEFINED $PARAMETER2 GoTo skipParam
	SET $UNATTEND_CLEAN=%$PARAMETER2%
	echo %$UNATTEND_CLEAN%> "%$WD%\var\var_Parameter-2.txt"
	::	Unattend directory
	SET $PARAMETER3=%~3
	IF DEFINED $PARAMETER3 echo %$PARAMETER3%> "%$WD%\var\var_Parameter-3.txt" 
	IF NOT DEFINED $PARAMETER3 IF EXIST "%$WD%\var\var_Parameter-3.txt" SET /P $PARAMETER3= < "%$WD%\var\var_Parameter-3.txt" 
	IF NOT DEFINED $PARAMETER3 GoTo skipParam
	SET $UNATTEND_DIR=%$PARAMETER3%	
	::	Unattend file to seed
	SET $PARAMETER4=%~4
	IF DEFINED $PARAMETER4 echo %$PARAMETER4%> "%$WD%\var\var_Parameter-4.txt" 
	IF NOT DEFINED $PARAMETER4 IF EXIST "%$WD%\var\var_Parameter-4.txt" SET /P $PARAMETER4= < "%$WD%\var\var_Parameter-4.txt" 
	IF NOT DEFINED $PARAMETER4 GoTo skipParam
	SET $Unattend_FILE=%$PARAMETER4%
	::	Timeout
	SET $PARAMETER5=%~5
	IF DEFINED $PARAMETER5 echo %$PARAMETER5%> "%$WD%\var\var_Parameter-5.txt"
	IF NOT DEFINED $PARAMETER5 IF EXIST "%$WD%\var\var_Parameter-5.txt" SET /P $PARAMETER5= < "%$WD%\var\var_Parameter-5.txt"
	IF NOT DEFINED $PARAMETER5 GoTo skipParam
	SET $TIMEOUT=%$PARAMETER5%
	::	DelProf2 Path
	SET $PARAMETER6=%~6
	IF DEFINED $PARAMETER6 echo %$PARAMETER6%> "%$WD%\var\var_Parameter-6.txt" 
	IF NOT DEFINED $PARAMETER6 IF EXIST "%$WD%\var\var_Parameter-6.txt" SET /P $PARAMETER6= < "%$WD%\var\var_Parameter-6.txt" 
	IF NOT DEFINED $PARAMETER6 GoTo skipParam
	SET $DELPROF2_PATH=%$PARAMETER6%
:skipParam	

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Open Directory
	@explorer %$WD%

:start
	IF EXIST "%$WD%\%$MODULE_LOG%" Goto skipStart
	echo [INFO]	%DATE% %TIME% Start... >> "%$WD%\%$MODULE_LOG%"
	echo [INFO]	Script Version: %$SCRIPT_VERSION% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	script Build: %$SCRIPT_BUILD% >> "%$WD%\%$MODULE_LOG%"
	echo [INFO]	Computer: %COMPUTERNAME% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$CUSTOM_USER: %$CUSTOM_USER% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$TIMEOUT: %$TIMEOUT% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$UNATTEND_CLEAN: %$UNATTEND_CLEAN% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$UNATTEND_FILE: %$Unattend_FILE% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$UNATTEND_DIR: %$UNATTEND_DIR% >> "%$WD%\%$MODULE_LOG%"
	echo [DEBUG]	$DELPROF2_PATH: %$DELPROF2_PATH% >> "%$WD%\%$MODULE_LOG%"
	echo [INFO]	Active session... >> "%$WD%\%$MODULE_LOG%"
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


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:check
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

::	#0
::	Get current user, which is likely default user
:DefaultUser
	IF EXIST "%$WD%\0_DEFAULT_USER_Complete.txt" GoTo skipDU
	echo %USERNAME%> "%$WD%\0_DEFAULT_USER_Complete.txt"
:skipDU

::	#1
::	Configure Local Administrator Account
:Admin
	SET	$STEP_NUM=1
	SET "$STEP_DESCRIP=Administrator, local configuration"
	CALL :banner
	IF EXIST "%$WD%\1_Administrator_Complete.txt" GoTo skipAdmin
	Echo Processing local Administrator...
	rem	there's a space between username and options which is the password (blank)
	NET USER Administrator  /ACTIVE:YES && (echo %DATE% %TIME% > %$WD%\1_Administrator_Complete.txt)
	NET USER >> "%$WD%\1_Administrator_Complete.txt"
	NET LOCALGROUP Administrators >> "%$WD%\1_Administrator_Complete.txt"
	NET USER Administrator >> "%$WD%\1_Administrator_Complete.txt"
	NET USER %$CUSTOM_USER% /Active:No 2> nul
	Timeout /T %$TIMEOUT%
	::	no need to logoff if already logged in as Administrator
	IF "%USERNAME%"=="Administrator" GoTo skipAdmin
	shutdown /R /T 5 /f /c "Reboot to flush user profiles."
	GoTo End
:skipAdmin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
::	#2
::	DELETE CUSTOM USER ACCOUNT
::	"net user <userName> /DELETE" doesn't delete the user profile, just the account
::	Depends on DELPROF2
:UPC
	SET	$STEP_NUM=2
	SET "$STEP_DESCRIP=Users, cleanup local users"
	CALL :banner
	IF EXIST "%$WD%\2_USER_Profiles_Complete.txt" GoTo skipUPC
	echo Processing User Profile cleanup...
	IF NOT DEFINED $PARAMETER6 SET $DELPROF2_PATH=%$VOLUME%\%$DELPROF2_PATH%
	::	prefer where launched
	IF NOT EXIST "%SYSTEMROOT%\System32\delprof2.exe" Robocopy "%$DELPROF2_PATH%" "%SYSTEMROOT%\System32" delprof2.exe /r:1 /w:2
	IF EXIST "%$DELPROF2_PATH%" (CD /D "%$DELPROF2_PATH%") ELSE (cd /D "%SYSTEMROOT%\System32")
	delprof2 /l 2> nul
	delprof2 /u /i /ed:admin* 2> nul
	CALL :banner
	delprof2 /l 2> nul
	rem In case delprof fails, do it manaully
	FIND /I "%$CUSTOM_USER%" "%$WD%\Local_Users.txt" && (NET USER %$CUSTOM_USER% /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$CUSTOM_USER%")
	FIND /I "defaultuser0" "%$WD%\Local_Users.txt" && (NET USER defaultuser0 /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\defaultuser0" RD /S /Q "%SYSTEMDRIVE%\Users\defaultuser0")
	IF EXIST "%$WD%\0_DEFAULT_USER_Complete.txt" SET /P $DEFAULT_USER= < "%$WD%\0_DEFAULT_USER_Complete.txt"
	IF DEFINED $DEFAULT_USER FIND /I "%$DEFAULT_USER%" "%$WD%\Local_Users.txt" && (NET USER %$DEFAULT_USER% /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%")
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
	SET "$STEP_DESCRIP=Scheduled Task, cleanup"
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
	SET "$STEP_DESCRIP=Windows Update"
	CALL :banner
	echo Processing Windows Updates...
	@powershell Get-WindowsUpdate 2> nul
	IF %ERRORLEVEL% EQU 0 GoTo jumpWU
	@powershell Get-ExecutionPolicy -list
	::	by default for non-domain joined computers, may require security config
	@powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -scope CurrentUser -Force
	CALL :banner
	@powershell Get-ExecutionPolicy -list
	:: Windows Update PowerShell Module
	:: https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc
	@powershell Install-PackageProvider -name NuGet -Force
	@powershell Install-Module -name PSWindowsUpdate -Force
	@powershell Import-Module PSWindowsUpdate
	@powershell Get-WindowsUpdate
	:jumpWU
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
	SET "$STEP_DESCRIP=Disk Check, for dirty bit"
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
	SET "$STEP_DESCRIP=CleanMgr, run disk cleanup"
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
	SET "$STEP_DESCRIP=Final reboot, in preperation for running SysPrep"
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
	SET "$STEP_DESCRIP=SysPrep"
	CALL :banner
	echo Processing SysPrep...
	Timeout /T %$TIMEOUT%
	echo %DATE% %TIME% > "%$WD%\8_SysPrep_Running.txt"
	CD /D "%SystemRoot%\System32\SysPrep"
	CD
	openfiles 1> nul 2> nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% NEQ 0 GoTo sysprepE
	echo [INFO]	SysPrep activation %DATE% %TIME% >> "%$WD%\%$MODULE_LOG%"
	echo [INFO]	End. >> "%$WD%\%$MODULE_LOG%"
	robocopy "%$WD%" "%SystemRoot%\System32\SysPrep\%$SCRIPT_NAME%\%$ISO_DATE%" /MOVE /S /E /R:1 /W:2
	IF EXIST "%SystemRoot%\System32\SysPrep\Panther" RD /S /Q "%SystemRoot%\System32\SysPrep\Panther"
:UC
	echo Checking on Unattend.xml cleanup...
	IF /I "%$UNATTEND_CLEAN%"=="No" GoTo skipUC
	(REG QUERY "HKEY_LOCAL_MACHINE\System\Setup\UnattendFile" 2> nul) && (REG DELETE "HKEY_LOCAL_MACHINE\System\Setup\UnattendFile" /VA /f)
	IF EXIST "%WINDIR%\Panther\Unattend\Unattend.xml" DEL /F /Q "%WINDIR%\Panther\Unattend\Unattend.xml"
	IF EXIST "%WINDIR%\Panther\Unattend\Autounattend.xml" DEL /F /Q "%WINDIR%\Panther\Unattend\Autounattend.xml"
	IF EXIST "%WINDIR%\Panther\Unattend.xml" DEL /F /Q "%WINDIR%\Panther\Unattend.xml"
	IF EXIST "%WINDIR%\System32\Sysprep\Unattend.xml" DEL /F /Q "%WINDIR%\System32\Sysprep\Unattend.xml"
	IF EXIST "%SYSTEMDRIVE%\unattend.xml" DEL /F /Q "%SYSTEMDRIVE%\unattend.xml"
	IF EXIST "%SYSTEMDRIVE%\Autounattend.xml" DEL /F /Q "%SYSTEMDRIVE%\Autounattend.xml"
:skipUC

:US
	::	Unattend seed
	IF %$Unattend_FILE% EQU 0 GoTo skipUS
	echo Seeding unattend.xml file...
	IF DEFINED $Unattend_FILE IF NOT EXIST "%SystemRoot%\Panther\Unattend" MD "%SystemRoot%\Panther\Unattend"
	DEL /Q /F "%SystemRoot%\Panther\Unattend\*"
	IF DEFINED $Unattend_FILE copy /Y "%$UNATTEND_DIR%\%$Unattend_FILE%" "%SystemRoot%\Panther\Unattend"
	IF NOT "%$Unattend_FILE%"=="unattend.xml" RENAME "%SystemRoot%\Panther\Unattend\%$Unattend_FILE%" "unattend.xml"
:skipUS

	:: Needs to run with Administrative privilege
	CALL :banner
	echo Running SysPrep...
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
