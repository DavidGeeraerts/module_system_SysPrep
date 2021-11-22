:: Title ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	module system SysPrep
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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
:: Windows 10 Build information
::	https://docs.microsoft.com/en-us/windows/release-health/release-information
:: Windows 11 Build information
::	https://docs.microsoft.com/en-us/windows/release-health/windows11-release-information
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Initialize the shell :::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo Off
SETLOCAL Enableextensions
SET $SCRIPT_NAME=module_system_SysPrep
SET $SCRIPT_VERSION=2.0.1
SET $SCRIPT_BUILD=20211122-0800
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=70
mode con:lines=40
Prompt $G
color 4E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables [Defaults]
::###########################################################################::

:: Default properties file name
SET $CONFIG_FILE=module_system_SysPrep.properties

::	Minimum properties file schema version
::	DO NOT MODIFY
SET $CONFIG_SCHEMA_VERSION_MIN=1.0.0

:: Timeout (seconds)
SET $TIMEOUT=5

::	Use Unatand.xml for SysPrep
::	No [0] Yes [1]
SET $UNATTEND_USE=0

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

::	Flushes the default user that is logged in
::	default user from unattend file
SET $DEFAULT_USER=Scientific

::	From the root of the volume
SET $DELPROF2_PATH=Tools


::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::

::	Log Directory
SET $LD=logs

::	Module log
SET $MODULE_LOG=%$SCRIPT_NAME%_%COMPUTERNAME%.log

:: Cache directory
SET $CACHE=cache

::	Image Information
::		No [0] Yes [1]
SET $IMAGE_USE=1
::	Image Directory
SET $IMAGE_DIRECTORY=%PROGRAMDATA%\CloneZilla
::	Image file name
SET $IMAGE_FILE=CloneZilla_Image.txt
::	Image type
::	Base = standard Windows image
::	<Specialized_Name> = a specific windows image, e.g. scientific
SET $IMAGE_TYPE=Base

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:SLT
	:: Start Time Start Date
	SET $START_TIME=%Time%
	SET $START_DATE=%Date%

:param	
	:: Capture Parameter 1 for properties file
	SET $PARAMETER1=%~1

:dir

	::	Volume
	CD /D "%~dp0" 2> nul
	SET $PATH=%~dp0
	Call :get-volume %$PATH%
:get-volume
	SET $VOLUME=%~d1
	SET "$WD=%$VOLUME%
	:: Not to use the root system, instead revert to Public directory  
	if %$VOLUME%==%SystemDrive% SET $WD=%PUBLIC%\%$SCRIPT_NAME%
	if not exist %$WD% MD %$WD%
	CD /D "%$WD%"
	:: Directory Checks
	::	cache
	IF NOT EXIST "%$WD%\%$CACHE%\%COMPUTERNAME%" MD "%$WD%\%$CACHE%\%COMPUTERNAME%"
	SET "$VD=%$WD%\%$CACHE%\%COMPUTERNAME%"
	:: log
	IF NOT EXIST "%$WD%\%$LD%\%COMPUTERNAME%" MD "%$WD%\%$LD%\%COMPUTERNAME%"
	SET "$LD=%$WD%\%$LD%\%COMPUTERNAME%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=0
SET $STEP_NUM=0
SET "$STEP_DESCRIP=Preperations"

:banner
cls
:: CONSOLE OUTPUT 
echo   ****************************************************************
echo. 
echo      %$SCRIPT_NAME% %$SCRIPT_VERSION%
echo.
echo      %$START_DATE% %$START_TIME%
echo.
echo.		Process #: %$STEP_NUM% ^(%$STEP_DESCRIP%^)
echo.
echo   ****************************************************************
echo.
echo.
IF %$BANNER% EQU 1 GoTo :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Configuration File :::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Param
	::	Properties file as a parameter
	IF DEFINED $PARAMETER1 echo %$PARAMETER1%> "%$VD%\Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 IF EXIST "%$VD%\Parameter-1.txt" SET /P $PARAMETER1= < "%$VD%\Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 GoTo skipParam
	SET $CONFIG_FILE=%$PARAMETER1%
:skipParam

IF NOT EXIST "%~dp0\%$CONFIG_FILE%" GoTo skipCF
SET "$STEP_DESCRIP=Reading properties file"
CALL :banner
echo Reading properties file...
:: CHECK the Config file Schema version meets the minimum requirement
SET $CONFIG_FILE_SCHEMA_CHECK=0
SET $CONFIG_FILE_SCHEMA_CHECK_MINOR=0
::	Get the schema version from the properties file
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$CONFIG_SCHEMA_VERSION" "%~dp0\%$CONFIG_FILE%"') DO SET "$CONFIG_SCHEMA_VERSION=%%V"

::  Parse schema version from configuration file
::		Revision number should never effect parsing ability, no check.
FOR /F "tokens=1 delims=." %%V IN ("%$CONFIG_SCHEMA_VERSION%") DO SET $CONFIG_SCHEMA_VERSION_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%$CONFIG_SCHEMA_VERSION%") DO SET $CONFIG_SCHEMA_VERSION_MINOR=%%V
::	Parse minimum schema version necessary to load properties
FOR /F "tokens=1 delims=." %%V IN ("%$CONFIG_SCHEMA_VERSION_MIN%") DO SET $CONFIG_SCHEMA_VERSION_MIN_MAJOR=%%V
FOR /F "tokens=2 delims=." %%V IN ("%$CONFIG_SCHEMA_VERSION_MIN%") DO SET $CONFIG_SCHEMA_VERSION_MIN_MINOR=%%V

::  actual check
IF %$CONFIG_SCHEMA_VERSION_MAJOR% GEQ %$CONFIG_SCHEMA_VERSION_MIN_MAJOR% (SET $CONFIG_FILE_SCHEMA_CHECK=1)
IF %$CONFIG_SCHEMA_VERSION_MINOR% GEQ %$CONFIG_SCHEMA_VERSION_MIN_MINOR% (SET $CONFIG_FILE_SCHEMA_CHECK_MINOR=1)
:: skip loading the properties file if it doesn't meet the minimum schema.
IF %$CONFIG_FILE_SCHEMA_CHECK% EQU 0 GoTo skipCF

::	NOTES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM Any configuration variable being pulled from the configuration file that is using another variable
REM needs to be reset so as not to take the string from the configuration file literally.
REM This solves the problem when build in variables are used such as %PROGRAMDATA%
REM EXAMPLE: FOR /F %%R IN ('ECHO %$VARIABLE%') DO SET $VARIABLE=%%R
REM FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$VARIABLE" "%~dp0\%CONFIG_FILE_NAME%"') DO SET "$VARIABLE=%%V"
REM FOR /F %%R IN ('ECHO %VARIABLE%') DO SET $VARIABLE=%%R
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: LOADING PROPERTIES
::	Timeout
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$TIMEOUT" "%~dp0\%$CONFIG_FILE%"') DO SET "$TIMEOUT=%%V"
echo $TIMEOUT: %$TIMEOUT%
::	Use unattend.xml for sysprep
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_USE" "%~dp0\%$CONFIG_FILE%"') DO SET "$UNATTEND_USE=%%V"
echo $UNATTEND_USE: %$UNATTEND_USE%
::	Cleanup unattend after SysPrep
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_CLEAN" "%~dp0\%$CONFIG_FILE%"') DO SET "$UNATTEND_CLEAN=%%V"
echo $UNATTEND_CLEAN: %$UNATTEND_CLEAN%
::	Folder name to store unattend xml files
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_DIR" "%~dp0\%$CONFIG_FILE%"') DO SET "$UNATTEND_DIR=%%V"
echo $UNATTEND_DIR: %$UNATTEND_DIR%
::	Unattend.xml file name
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_FILE" "%~dp0\%$CONFIG_FILE%"') DO SET "$UNATTEND_FILE=%%V"
echo $UNATTEND_FILE: %$UNATTEND_FILE%
:: Default user from unattend.xml file
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$DEFAULT_USER" "%~dp0\%$CONFIG_FILE%"') DO SET "$DEFAULT_USER=%%V"
echo $DEFAULT_USER: %$DEFAULT_USER%
::	where to find DelProf2 from working directory
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$DELPROF2_PATH" "%~dp0\%$CONFIG_FILE%"') DO SET "$DELPROF2_PATH=%%V"
echo $DELPROF2_PATH: %$DELPROF2_PATH%
::	where to store logs from the working directory
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$LD" "%~dp0\%$CONFIG_FILE%"') DO SET "$LD=%%V"
echo $LD: %$LD%
::	module log file for session
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$MODULE_LOG" "%~dp0\%$CONFIG_FILE%"') DO SET "$MODULE_LOG=%%V"
FOR /F %%R IN ('ECHO %$MODULE_LOG%') DO SET $MODULE_LOG=%%R
echo $MODULE_LOG: %$MODULE_LOG%
:: Use Image server Information
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_USE" "%~dp0\%$CONFIG_FILE%"') DO SET "$IMAGE_USE=%%V"
echo $IMAGE_USE: %$IMAGE_USE%
::	Image server directory
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_DIRECTORY" "%~dp0\%$CONFIG_FILE%"') DO SET "$IMAGE_DIRECTORY=%%V"
FOR /F %%R IN ('ECHO %$IMAGE_DIRECTORY%') DO SET $IMAGE_DIRECTORY=%%R
echo $IMAGE_DIRECTORY: %$IMAGE_DIRECTORY%
:: File name for image server
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_FILE" "%~dp0\%$CONFIG_FILE%"') DO SET "$IMAGE_FILE=%%V"
echo $IMAGE_FILE: %$IMAGE_FILE%
::	Image Server image type
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_TYPE" "%~dp0\%$CONFIG_FILE%"') DO SET "$IMAGE_TYPE=%%V"
echo $IMAGE_TYPE: %$IMAGE_TYPE%
echo End properties file parsing.
Timeout /T %$TIMEOUT%

:skipCF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

call :banner
echo Preparing to run the following:
echo.
IF NOT EXIST "%$LD%\0_DEFAULT_USER_Complete.txt" echo 0. Logged on user flush
IF NOT EXIST "%$LD%\1_Administrator_Complete.txt" echo 1. Administrator, local configuration
IF NOT EXIST "%$LD%\2_USER_Profiles_Complete.txt" echo 2. Users, cleanup local users
IF NOT EXIST "%$LD%\3_Scheduled_Task_Complete.txt" echo 3. Scheduled Task, cleanup
IF NOT EXIST "%$LD%\4_Winddows_Update_Complete.txt" echo 4. Windows Update
IF NOT EXIST "%$LD%\5_Disk_Check_Complete.txt" echo 5. Disk Check, for dirty bit
IF NOT EXIST "%$LD%\6_Disk_CleanMGR_Complete.txt" echo 6. CleanMgr, run disk cleanup
IF NOT EXIST "%$LD%\7_Final_Reboot_Complete.txt" echo 7. Final reboot, in preperation for running SysPrep
echo 8. SysPrep
echo.
Timeout /T %$TIMEOUT%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:ISO8601
	::	Make ISO timestamp
	IF EXIST "%$VD%\var_ISO8601_Date.txt" GoTo skipISO
	@powershell Get-Date -format "yyyy-MM-dd" > "%$VD%\var_ISO8601_Date.txt"
	:skipISO
	SET /P $ISO_DATE= < "%$VD%\var_ISO8601_Date.txt"

:DT
	IF EXIST "%$VD%\var_Time.txt" GoTo skipT 
	@powershell Get-Date -format "HHMM" > "%$VD%\var_Time.txt"
	:: Time for Script run for folder creation
	:skipT
	SET $TIME= < "%$VD%\var_Time.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OSR
	:: Windows recon
	::IF NOT EXIST "%$VD%\OS_Caption.txt" wmic OS GET CAPTION /VALUE > "%$VD%\OS_Caption.txt"
	::IF NOT EXIST "%$VD%\OS_BuildNumber.txt" wmic OS GET BUILDNUMBER /VALUE > "%$VD%\OS_BuildNumber.txt"
	::IF NOT EXIST "%$VD%\ver.txt" ver > "%$VD%\ver.txt"
	:: Parse Windows OS to elements
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ProductName"') DO SET $OS=%%P
	FOR /F "skip=1 tokens=4 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ProductName"') DO SET $OS_MAJOR=%%P
	if %$OS_MAJOR%=="Server" FOR /F "skip=1 tokens=5 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ProductName"') DO SET $OS_MAJOR=%%P
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "EditionID"') DO SET $OS_EDITION=%%P
	FOR /F "tokens=2 delims==" %%P IN ('wmic os GET CAPTION /VALUE') DO SET $OS_CAPTION=%%P
	::	Use ReleaseID if server
	::	{Client, Server}
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "InstallationType"') DO SET $OS_INSTALLATION_TYPE=%%P
	if %$OS_INSTALLATION_TYPE%==Server (for /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ReleaseId"') DO SET $OS_DISPLAY_VERSION=%%P) ELSE ( 
		FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "DisplayVersion"') DO SET $OS_DISPLAY_VERSION=%%P
	)
	FOR /F "tokens=2 delims==" %%P IN ('wmic os GET BUILDNUMBER /VALUE') DO SET $OS_BUILDNUMBER=%%P
	FOR /F "tokens=4 delims=[] " %%P IN ('ver') DO SET $OS_VERSION=%%P
	FOR /F "tokens=4 delims=.]" %%P IN ('ver') DO SET $OS_BUILD_REVISION=%%P
	for /f "tokens=2 delims==" %%P IN ('wmic path SoftwareLicensingService get OA3xOriginalProductKey /Value') DO set $OS_PRODUCT_KEY=%%P
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Open Directory
	@explorer "%$LD%"

:start
	IF EXIST "%$LD%\%$MODULE_LOG%" Goto skipStart
	echo %TIME% [INFO]	%DATE% Start... >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Script Name: %$SCRIPT_NAME% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Script Version: %$SCRIPT_VERSION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Script Build: %$SCRIPT_BUILD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Computer: %COMPUTERNAME% >> "%$LD%\%$MODULE_LOG%"	
	echo %TIME% [DEBUG]	Working directory [$WD]: %$WD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Log directory [$LD]: %$LD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Var directory [$VD]: %$VD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$DEFAULT_USER: %$DEFAULT_USER% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$TIMEOUT: %$TIMEOUT% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_USE: %$UNATTEND_USE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_CLEAN: %$UNATTEND_CLEAN% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_FILE: %$Unattend_FILE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_DIR: %$UNATTEND_DIR% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$DELPROF2_PATH: %$DELPROF2_PATH% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$IMAGE_USE: %$IMAGE_USE% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_DIRECTORY: %$IMAGE_DIRECTORY% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_FILE: %$IMAGE_FILE% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_TYPE: %$IMAGE_TYPE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Name: %$OS_CAPTION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Display Version: %$OS_DISPLAY_VERSION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Build Number: %$OS_BUILDNUMBER% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Version Number: %$OS_VERSION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Build Revision Number: %$OS_BUILD_REVISION% >> "%$LD%\%$MODULE_LOG%"	
	echo %TIME% [INFO]	OS Product Key: %$OS_PRODUCT_KEY% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Active session... >> "%$LD%\%$MODULE_LOG%"
:skipStart



:: Setup on Startup
REM This would need to be a scheduled task to run as an administrator
::	mostly automates Windows Updates for reboots
::	IF EXIST "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\module_system_SysPrep" GoTo skipSetupS
::	mklink "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup" "%$VOLUME%\modules\module_system_SysPrep\module_system_SysPrep.cmd"
:skipSetupS


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:check
	rem	speed up the process from reboots
	
	IF NOT EXIST "%$LD%\0_DEFAULT_USER_Complete.txt" GoTo DefaultUser
	IF NOT EXIST "%$LD%\1_Administrator_Complete.txt" GoTo Admin
	IF NOT EXIST "%$LD%\2_USER_Profiles_Complete.txt" GoTo UPC
	IF NOT EXIST "%$LD%\3_Scheduled_Task_Complete.txt" GoTo stc
	IF NOT EXIST "%$LD%\4_Winddows_Update_Complete.txt" GoTo WU
	IF NOT EXIST "%$LD%\5_Disk_Check_Complete.txt" GoTo fdc
	IF NOT EXIST "%$LD%\6_Disk_CleanMGR_Complete.txt" GoTo CM
	IF NOT EXIST "%$LD%\7_Final_Reboot_Complete.txt" GoTo FB
	IF NOT EXIST "%$LD%\8_SysPrep_Running.txt" GoTo sysprep
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#0
::	Get current user, which is likely default user
:DefaultUser
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Flush logged on user"
	CALL :banner
	IF EXIST "%$LD%\0_DEFAULT_USER_Complete.txt" GoTo skipDU

:skipDU

::	#1
::	Configure Local Administrator Account
:Admin
	SET	$STEP_NUM=1
	SET "$STEP_DESCRIP=Administrator, local configuration"
	CALL :banner
	IF EXIST "%$LD%\1_Administrator_Complete.txt" GoTo skipAdmin
	Echo Processing local Administrator...
	rem	there's a space between username and options which is the password (blank)
	NET USER Administrator  /ACTIVE:YES && (echo %DATE% %TIME% > %$LD%\1_Administrator_Complete.txt)
	NET USER >> "%$LD%\1_Administrator_Complete.txt"
	NET LOCALGROUP Administrators >> "%$LD%\1_Administrator_Complete.txt"
	NET USER Administrator >> "%$LD%\1_Administrator_Complete.txt"
	echo %TIME% [INFO]	1_Administrator_Complete! >> "%$LD%\%$MODULE_LOG%"
	NET USER %$DEFAULT_USER% /Active:No 2> nul
	Timeout /T %$TIMEOUT%
	::	no need to logoff if already logged in as Administrator
	IF "%USERNAME%"=="Administrator" GoTo skipAdmin
	shutdown /R /T 5 /f /c "Reboot to flush user profiles."
	GoTo End
:skipAdmin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
::	#2
::	DELETE Default USER ACCOUNT
::	"net user <userName> /DELETE" doesn't delete the user profile, just the account
::	Depends on DELPROF2
:UPC
	SET	$STEP_NUM=2
	SET "$STEP_DESCRIP=Users, cleanup local users"
	CALL :banner
	IF EXIST "%$LD%\2_USER_Profiles_Complete.txt" GoTo skipUPC
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
	FIND /I "%$DEFAULT_USER%" "%$LD%\Local_Users.txt" && (NET USER %$DEFAULT_USER% /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%")
	FIND /I "defaultuser0" "%$LD%\Local_Users.txt" && (NET USER defaultuser0 /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\defaultuser0" RD /S /Q "%SYSTEMDRIVE%\Users\defaultuser0")
	IF EXIST "%$LD%\0_DEFAULT_USER_Complete.txt" SET /P $DEFAULT_USER= < "%$LD%\0_DEFAULT_USER_Complete.txt"
	IF DEFINED $DEFAULT_USER FIND /I "%$DEFAULT_USER%" "%$LD%\Local_Users.txt" && (NET USER %$DEFAULT_USER% /DELETE) && (IF EXIST "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%" RD /S /Q "%SYSTEMDRIVE%\Users\%$DEFAULT_USER%")
	echo Done.
	rem	can check this file to make sure user(s) have been deleted. 
	net user > "%$LD%\Local_Users.txt"
	echo %DATE% %TIME% > "%$LD%\2_USER_Profiles_Complete.txt"
	echo %$DEFAULT_USER%> "%$LD%\0_DEFAULT_USER_Complete.txt"
	echo %TIME% [INFO]	User: %$DEFAULT_USER% just got deleted! >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	2_USER_PROFILES_Complete! >> "%$LD%\%$MODULE_LOG%"
	rem try again on next reboot if cleaning up user(s) failed
	FIND /I "%$DEFAULT_USER%" "%$LD%\Local_Users.txt" && DEL /F /Q "%$LD%\2_USER_Profiles_Complete.txt"
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
	IF EXIST "%$LD%\3_Scheduled_Task_Complete.txt" GoTo skipSTC
	echo Processing Scheduled Taks cleanup...
	FOR /F "tokens=2 delims=\" %%P IN ('SCHTASKS /QUERY /FO LIST ^| FIND /I "OneDrive"') DO SCHTASKS /DELETE /F /TN "%%P"
	echo %DATE% %TIME% > "%$LD%\3_Scheduled_Task_Complete.txt"
	echo %TIME% [INFO]	3_Scheduled_Task_Complete! >> "%$LD%\%$MODULE_LOG%"
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
	IF EXIST "%$LD%\4_Winddows_Update_Complete.txt" GoTo skipWU
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
	::	KB4481252 = SilverLight
	@powershell Install-WindowsUpdate -NotKBArticleID KB4481252 -AcceptAll -AutoReboot
	echo Reboot?
	@powershell Get-WURebootStatus | FIND /I "False" && echo %DATE% %TIME% > "%$LD%\4_Winddows_Update_Complete.txt"
	echo %TIME% [INFO]	4_Winddows_Update_Complete! >> "%$LD%\%$MODULE_LOG%"
	echo Done.
	Timeout /T %$TIMEOUT%
:skipWU
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#5
::	Check if System Drive is dirty
:fdc
	SET	$STEP_NUM=5
	SET "$STEP_DESCRIP=Disk Check, for dirty bit"
	CALL :banner
	IF EXIST "%$LD%\5_Disk_Check_Complete.txt" GoTo skipFDC
	echo Checking System Disk... 
	CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && echo y | chkdsk %systemdrive% /B
	echo %DATE% %TIME% > "%$LD%\5_Disk_Check_Complete.txt"
	echo %TIME% [INFO]	5_Disk_Check_Complete! >> "%$LD%\%$MODULE_LOG%"
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
	IF EXIST "%$LD%\6_Disk_CleanMGR_Complete.txt" GoTo skipCM
	echo Processing Clean Manager for disk space...
	REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /S /V StateFlags0100 1> nul 2> nul
	SET $CLEANER_STATUS=%ERRORLEVEL%
	IF %$CLEANER_STATUS% EQU 0 GoTo jumpCS
	CLEANMGR /SAGESET:100
	Timeout /T %$TIMEOUT%
:jumpCS
	echo Processing disk cleanup...
	CLEANMGR /SAGERUN:100
	echo %DATE% %TIME% > "%$LD%\6_Disk_CleanMGR_Complete.txt"
	echo %TIME% [INFO]	6_Disk_CleanMGR_Complete! >> "%$LD%\%$MODULE_LOG%"
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
	IF EXIST "%$LD%\7_Final_Reboot_Complete.txt" GoTo skipFB
	echo Processing final reboot...
	DEL /F /Q /S "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\module_system_SysPrep*" 2> nul
	echo %DATE% %TIME% > "%$LD%\7_Final_Reboot_Complete.txt"
	echo %TIME% [INFO]	7_Final_Reboot_Complete! >> "%$LD%\%$MODULE_LOG%"
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
	if exist "%$LD%\8_SysPrep_Running.txt" GoTo sysprepE1
	echo %DATE% %TIME% > "%$LD%\8_SysPrep_Running.txt"
	openfiles 1> nul 2> nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% NEQ 0 GoTo sysprepE
	echo %TIME% [INFO]	SysPrep activation! >> "%$LD%\%$MODULE_LOG%"

	::	Logging from executed location as of version 1.6.0
	::robocopy "%$LD%" "%SystemRoot%\System32\SysPrep\%$SCRIPT_NAME%\%$ISO_DATE%" /MOVE /S /E /R:1 /W:2
	:: Clean up Panther folder
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
	IF %$UNATTEND_USE% EQU 0 GoTo skipUS
	echo Seeding unattend.xml file...
	IF DEFINED $Unattend_FILE IF NOT EXIST "%SystemRoot%\Panther\Unattend" MD "%SystemRoot%\Panther\Unattend"
	DEL /Q /F "%SystemRoot%\Panther\Unattend\*"
	IF DEFINED $Unattend_FILE copy /Y "%$UNATTEND_DIR%\%$Unattend_FILE%" "%SystemRoot%\Panther\Unattend"
	IF NOT "%$Unattend_FILE%"=="unattend.xml" RENAME "%SystemRoot%\Panther\Unattend\%$Unattend_FILE%" "unattend.xml"
:skipUS

	:: Needs to run with Administrative privilege
	call :banner
	call :subAPX
	IF %$IMAGE_USE% EQU 1 call :subIU
	IF %$IMAGE_USE% EQU 1 set /P $IMAGE_NAME= < "%$IMAGE_DIRECTORY%\%$IMAGE_FILE%"
	IF %$IMAGE_USE% EQU 1 echo %TIME% [INFO]	Image Name: %$IMAGE_NAME% >> "%$LD%\%$MODULE_LOG%"
	echo Running SysPrep...
	CD /D "%SystemRoot%\System32\SysPrep"
	if %$UNATTEND_USE% EQU 1 (@sysprep /oobe /generalize /unattend:%$Unattend_FILE% /shutdown) ELSE (
		@sysprep /oobe /generalize /shutdown
		)
	SET %$SYSPREP_ERROR%=%ERRORLEVEL%
	echo %TIME% [DEBUG]	$SYSPREP_ERROR: %$SYSPREP_ERROR% >> "%$LD%\%$MODULE_LOG%"
	if exist "%$LD%\8_SysPrep_Running.txt" DEL /F /Q "%$LD%\8_SysPrep_Running.txt"
	echo %DATE% %TIME% > "%$LD%\8_SysPrep_Complete.txt"
	echo %TIME% [INFO]	8_SysPrep_Complete! >> "%$LD%\%$MODULE_LOG%"
	robocopy "%$LD%" "%$LD%\completed" *.txt /MOV /XF Local_Users.txt CloneZilla_Image.txt /R:1 /W:2
	robocopy "%WINDIR%\System32\Sysprep\Panther" "%$LD%\Panther" /S /E /R:1 /W:2 /NP
	if exist "%WINDIR%\System32\Sysprep\Panther\setuperr.txt" GoTo sysprepE1
	::IF %$SYSPREP_ERROR% NEQ 0 PAUSE
	GoTo end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	ERRORS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
:sysprepE
	echo FATAL: Not running with Administrative privilege!
	echo.
	echo Run as administrator!
	@explorer "%$LD%"
	PAUSE
	GoTo end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:sysprepE1
::	Color CE 
	echo ERROR!
	echo.
	echo Check the sysprep error log!
	@explorer "%WINDIR%\System32\Sysprep\Panther"
	PAUSE
	if exist "%$LD%\8_SysPrep_Running.txt" DEL /F /Q "%$LD%\8_SysPrep_Running.txt"
	GoTo end
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	Sub-routines
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:subAPX
::	Sub-routine for APX package(s)

	::	AppxPackage Cleanup that breaks sysprep
	::	since Windows 11
	::	Microsoft.OneDriveSync
	::	Current logged on user
	echo %TIME% [INFO]	AppxPackage Cleanup... >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Current User: %USERNAME% >> "%$LD%\%$MODULE_LOG%"
	SET $PACKAGE_NAME=
	FOR /F "tokens=3 delims= " %%P IN ('@powershell Get-AppxPackage Microsoft.OneDriveSync ^| FIND /I "PackageFullName"') DO SET $PACKAGE_NAME=%%P
	echo %TIME% [DEBUG]	$PACKAGE_NAME: %$PACKAGE_NAME% >> "%$LD%\%$MODULE_LOG%"
	IF NOT DEFINED $PACKAGE_NAME GoTo skipAPX1
	@powershell Remove-AppxPackage %$PACKAGE_NAME% 2> nul
	:skipAPX1
	::	MicrosoftWindows.Client.WebExperience
	SET $PACKAGE_NAME=
	FOR /F "tokens=3 delims= " %%P IN ('@powershell Get-AppxPackage MicrosoftWindows.Client.WebExperience ^| FIND /I "PackageFullName"') DO SET $PACKAGE_NAME=%%P
	echo %TIME% [DEBUG]	$PACKAGE_NAME: %$PACKAGE_NAME% >> "%$LD%\%$MODULE_LOG%"
	IF NOT DEFINED $PACKAGE_NAME GoTo skipAPX2
	@powershell Remove-AppxPackage %$PACKAGE_NAME% 2> nul
	:skipAPX2
	Goto :eof

::	Sub-routine for Use Image
:subIU
	IF NOT EXIST "%$IMAGE_DIRECTORY%" MD "%$IMAGE_DIRECTORY%"
	echo %$OS%-%$OS_MAJOR%-%$OS_EDITION%-%$OS_DISPLAY_VERSION%-%$OS_BUILDNUMBER%.%$OS_BUILD_REVISION%-%$IMAGE_TYPE%-img> "%$IMAGE_DIRECTORY%\%$IMAGE_FILE%"
	echo %$OS%-%$OS_MAJOR%-%$OS_EDITION%-%$OS_DISPLAY_VERSION%-%$OS_BUILDNUMBER%.%$OS_BUILD_REVISION%-%$IMAGE_TYPE%-img >  "%$LD%\%$IMAGE_FILE%"
	GoTo :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:end
if exist "%$LD%\8_SysPrep_Complete.txt" echo %TIME% [INFO]	End. >> "%$LD%\%$MODULE_LOG%"
ENDLOCAL
Exit
