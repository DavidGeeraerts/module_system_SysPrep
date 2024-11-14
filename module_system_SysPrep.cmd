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
SET $SCRIPT_VERSION=3.0.0
SET $SCRIPT_BUILD=20241113 1430
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=70
mode con:lines=40
Prompt $G
color 4E
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables [Defaults]
::###########################################################################::

::	Flushes the default user that is logged in
::	default user from unattend file
SET $LOCAL_USER=Scientific

:: [DELETE] Scheduled Task keyword search
:: Keyword search is used to search for scheduled tasks that are created for users.
:: The primary cleanup is for OneDrive.
:: Include others as they are added by Microsoft.
:: Keyword then space
:: I.g. $KEYWORD_SCHEDULED_TASK=OneDrive Google
SET "$KEYWORD_SCHEDULED_TASK=OneDrive" 

:: [DELETE] Microsoft APPX Packages
:: File that contains a list of APPX packages to delete using keywords
:: relative file path
SET $APPX_LIST=config\APPX_List.txt

::	Windows Update via powershell, KB exclusion
	::	NotKBArticleID with space between KB's
		:: E.g. SET "$NotKBArticleID=KB4481252 KB4481252" 
		::	KB4481252 = SilverLight
SET "$NotKBArticleID=KB4481252"	

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


:: Console Timeout (seconds)
SET $TIMEOUT=5


::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::

:: Default properties file name
SET $CONFIG_FILE=module_system_SysPrep.properties

::	Minimum properties file schema version
::	DO NOT MODIFY
SET $CONFIG_SCHEMA_VERSION_MIN=3.0.0

::	Log Directory
SET $LD=logs

::	Module log
SET $MODULE_LOG=%$SCRIPT_NAME%_%COMPUTERNAME%.log

:: Cache directory
SET $CACHE=cache

:: Process Titles
SET $PROCESS_T_0=SysPrep
SET $PROCESS_T_1=Administrator
SET $PROCESS_T_2=Local_Users
SET $PROCESS_T_3=Scheduled_Tasks
SET $PROCESS_T_4=APPX_Packages
SET $PROCESS_T_5=Windows_Update
SET $PROCESS_T_6=Disk_Check_Dirty_Bit
SET $PROCESS_T_7=BitLocker_Check_Unlock
SET $PROCESS_T_8=CleanMgr
SET $PROCESS_T_9=Reboot

:: Process Files
SET $PROCESS_0=%$PROCESS_T_0%.txt
SET $PROCESS_1=%$PROCESS_T_1%.txt
SET $PROCESS_2=%$PROCESS_T_2%.txt
SET $PROCESS_3=%$PROCESS_T_3%.txt
SET $PROCESS_4=%$PROCESS_T_4%.txt
SET $PROCESS_5=%$PROCESS_T_5%.txt
SET $PROCESS_6=%$PROCESS_T_6%.txt
SET $PROCESS_7=%$PROCESS_T_7%.txt
SET $PROCESS_8=%$PROCESS_T_8%.txt
SET $PROCESS_9=%$PROCESS_T_9%.txt

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

echo Initializing...
echo reading configuration file...

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
	SET "$CD=%$WD%\%$CACHE%\%COMPUTERNAME%"
	:: log
	IF NOT EXIST "%$WD%\%$LD%\%COMPUTERNAME%" MD "%$WD%\%$LD%\%COMPUTERNAME%"
	SET "$LD=%$WD%\%$LD%\%COMPUTERNAME%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:ISO8601
	::	Make ISO timestamp
	@powershell Get-Date -format "yyyy-MM-dd" > "%$CD%\ISO8601_Date.txt"
	SET /P $ISO_DATE= < "%$CD%\ISO8601_Date.txt"

:DT
	@powershell Get-Date -format "HHMM" > "%$CD%\Time.txt"
	:: Time for Script run
	SET $TIME= < "%$CD%\Time.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Configuration File :::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Param
	::	Properties file as a parameter
	IF DEFINED $PARAMETER1 echo %$PARAMETER1%> "%$CD%\Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 IF EXIST "%$CD%\Parameter-1.txt" SET /P $PARAMETER1= < "%$CD%\Parameter-1.txt"
	IF NOT DEFINED $PARAMETER1 GoTo skipParam
	SET $CONFIG_FILE=%$PARAMETER1%
:skipParam

IF NOT EXIST "%~dp0\config\%$CONFIG_FILE%" GoTo skipCF
SET "$STEP_DESCRIP=Reading properties file"
echo Reading properties file...
:: CHECK the Config file Schema version meets the minimum requirement
SET $CONFIG_FILE_SCHEMA_CHECK=0
SET $CONFIG_FILE_SCHEMA_CHECK_MINOR=0
::	Get the schema version from the properties file
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$CONFIG_SCHEMA_VERSION" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$CONFIG_SCHEMA_VERSION=%%V"

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
:: [DELETE] Scheduled Tasks
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$KEYWORD_SCHEDULED_TASK" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$KEYWORD_SCHEDULED_TASK=%%V"
echo $KEYWORD_SCHEDULED_TASK: %$KEYWORD_SCHEDULED_TASK%
:: Windows Update KB exclusion
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$NotKBArticleID" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$NotKBArticleID=%%V"
echo $NotKBArticleID: %$NotKBArticleID%
::	Timeout
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$TIMEOUT" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$TIMEOUT=%%V"
echo $TIMEOUT: %$TIMEOUT%
::	Use unattend.xml for sysprep
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_USE" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$UNATTEND_USE=%%V"
echo $UNATTEND_USE: %$UNATTEND_USE%
::	Cleanup unattend after SysPrep
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_CLEAN" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$UNATTEND_CLEAN=%%V"
echo $UNATTEND_CLEAN: %$UNATTEND_CLEAN%
::	Folder name to store unattend xml files
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_DIR" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$UNATTEND_DIR=%%V"
echo $UNATTEND_DIR: %$UNATTEND_DIR%
::	Unattend.xml file name
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$UNATTEND_FILE" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$UNATTEND_FILE=%%V"
echo $UNATTEND_FILE: %$UNATTEND_FILE%
:: Default user from unattend.xml file
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$LOCAL_USER" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$LOCAL_USER=%%V"
echo $LOCAL_USER: %$LOCAL_USER%
::	where to store logs from the working directory
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$LD" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$LD=%%V"
echo $LD: %$LD%
::	module log file for session
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$MODULE_LOG" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$MODULE_LOG=%%V"
FOR /F %%R IN ('ECHO %$MODULE_LOG%') DO SET $MODULE_LOG=%%R
echo $MODULE_LOG: %$MODULE_LOG%
:: Use Image server Information
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_USE" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$IMAGE_USE=%%V"
echo $IMAGE_USE: %$IMAGE_USE%
::	Image server directory
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_DIRECTORY" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$IMAGE_DIRECTORY=%%V"
FOR /F %%R IN ('ECHO %$IMAGE_DIRECTORY%') DO SET $IMAGE_DIRECTORY=%%R
echo $IMAGE_DIRECTORY: %$IMAGE_DIRECTORY%
:: File name for image server
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_FILE" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$IMAGE_FILE=%%V"
echo $IMAGE_FILE: %$IMAGE_FILE%
::	Image Server image type
FOR /F "tokens=2 delims=^=" %%V IN ('FINDSTR /BC:"$IMAGE_TYPE" "%~dp0\config\%$CONFIG_FILE%"') DO SET "$IMAGE_TYPE=%%V"
echo $IMAGE_TYPE: %$IMAGE_TYPE%
echo End properties file parsing.


:skipCF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	log	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Update log path after reading config file
SET "$LD=%$WD%\%$LD%\%COMPUTERNAME%" 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:OSR
	:: Windows recon
	::IF NOT EXIST "%$CACHE%\OS_Caption.txt" wmic OS GET CAPTION /VALUE > "%$CACHE%\OS_Caption.txt"
	::IF NOT EXIST "%$CACHE%\OS_BuildNumber.txt" wmic OS GET BUILDNUMBER /VALUE > "%$CACHE%\OS_BuildNumber.txt"
	::IF NOT EXIST "%$CACHE%\ver.txt" ver > "%$CACHE%\ver.txt"
	:: Parse Windows OS to elements
	:: Getting this info from registry is not reliable as Microsoft mainatins the OS info to 10 even when 11 for backwards capatability.
	@powershell -command "(Get-WmiObject -Class Win32_OperatingSystem | Format-List -Property Caption)" > %$CD%\Windows_Caption.txt
	for /f "tokens=3 delims= " %%P IN (%$CD%\Windows_Caption.txt) do SET $COMPANY=%%P
	for /f "tokens=4 delims= " %%P IN (%$CD%\Windows_Caption.txt) do SET $OS=%%P
	for /f "tokens=5 delims= " %%P IN (%$CD%\Windows_Caption.txt) do SET $OS_MAJOR=%%P
	for /f "tokens=3-5 delims= " %%P IN (%$CD%\Windows_Caption.txt) do SET "$CAPTION=%%P %%Q %%R"
	:: Server
	if %$OS_MAJOR%=="Server" FOR /F "skip=1 tokens=5 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ProductName"') DO SET $OS_MAJOR=%%P
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "EditionID"') DO SET $OS_EDITION=%%P
	:: WMIC deprecated with Windows 11 24H2
	::FOR /F "tokens=2 delims==" %%P IN ('wmic os GET CAPTION /VALUE') DO SET $OS_CAPTION=%%P
	::	Use ReleaseID if server
	::	{Client, Server}
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "InstallationType"') DO SET $OS_INSTALLATION_TYPE=%%P
	if %$OS_INSTALLATION_TYPE%==Server (for /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "ReleaseId"') DO SET $OS_DISPLAY_VERSION=%%P) ELSE ( 
		FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "DisplayVersion"') DO SET $OS_DISPLAY_VERSION=%%P
	)
	FOR /F "skip=1 tokens=3 delims= " %%P IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion" /V "CurrentBuildNumber"') DO SET $OS_CurrentBuildNumber=%%P
	FOR /F "tokens=4 delims=.]" %%P IN ('ver') DO SET $OS_BUILD_REVISION=%%P
	REM deprecated
	::for /f "tokens=2 delims==" %%P IN ('wmic path SoftwareLicensingService get OA3xOriginalProductKey /Value') DO set $OS_PRODUCT_KEY=%%P
	:: OS Product Key
	@powershell -command "(Get-WmiObject -Query \"SELECT OA3xOriginalProductKey FROM SoftwareLicensingService\").OA3xOriginalProductKey" > %$CD%\OS_PRODUCT_KEY.txt
	SET /P $OS_PRODUCT_KEY= < %$CD%\OS_PRODUCT_KEY.txt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:start
	echo %TIME% [INFO]	%DATE% Start... >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Script Name: %$SCRIPT_NAME% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Script Version: %$SCRIPT_VERSION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Script Build: %$SCRIPT_BUILD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Computer: %COMPUTERNAME% >> "%$LD%\%$MODULE_LOG%"	
	echo %TIME% [DEBUG]	Working directory [$WD]: %$WD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Log directory [$LD]: %$LD% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	Var directory [$VD]: %$CACHE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$LOCAL_USER: %$LOCAL_USER% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$TIMEOUT: %$TIMEOUT% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_USE: %$UNATTEND_USE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_CLEAN: %$UNATTEND_CLEAN% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_FILE: %$Unattend_FILE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$UNATTEND_DIR: %$UNATTEND_DIR% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [DEBUG]	$IMAGE_USE: %$IMAGE_USE% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_DIRECTORY: %$IMAGE_DIRECTORY% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_FILE: %$IMAGE_FILE% >> "%$LD%\%$MODULE_LOG%"
	if %$IMAGE_USE% EQU 1 echo %TIME% [DEBUG]	$IMAGE_TYPE: %$IMAGE_TYPE% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Name: %$OS_CAPTION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Display Version: %$OS_DISPLAY_VERSION% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Build Number: %$OS_CurrentBuildNumber% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	OS Build Revision Number: %$OS_BUILD_REVISION% >> "%$LD%\%$MODULE_LOG%"	
	echo %TIME% [INFO]	OS Product Key: %$OS_PRODUCT_KEY% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME% [INFO]	Active session... >> "%$LD%\%$MODULE_LOG%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::



SET $BANNER=0
SET $STEP_NUM=0
SET "$STEP_DESCRIP=Menu selection"

:banner
cls
:: CONSOLE OUTPUT 
echo   ****************************************************************
echo. 
echo      %$SCRIPT_NAME% %$SCRIPT_VERSION%
echo      %$START_DATE% %$START_TIME%
echo.
echo	Process list: Step: %$STEP_NUM%
echo	Description: %$STEP_DESCRIP%
echo ----------------------------------------------------------------------
echo.
If NOT exist %$CD%\%$PROCESS_1% (echo [ ]1. %$PROCESS_T_1%) else (echo [x]1. %$PROCESS_T_1%)
If NOT exist %$CD%\%$PROCESS_2% (echo [ ]2. %$PROCESS_T_2%) else (echo [x]2. %$PROCESS_T_2%)
If NOT exist %$CD%\%$PROCESS_3% (echo [ ]3. %$PROCESS_T_3%) else (echo [x]3. %$PROCESS_T_3%)
If NOT exist %$CD%\%$PROCESS_4% (echo [ ]4. %$PROCESS_T_4%) else (echo [x]4. %$PROCESS_T_4%)
If NOT exist %$CD%\%$PROCESS_5% (echo [ ]5. %$PROCESS_T_5%) else (echo [x]5. %$PROCESS_T_5%)
If NOT exist %$CD%\%$PROCESS_6% (echo [ ]6. %$PROCESS_T_6%) else (echo [x]6. %$PROCESS_T_6%)
If NOT exist %$CD%\%$PROCESS_7% (echo [ ]7. %$PROCESS_T_7%) else (echo [x]7. %$PROCESS_T_7%)
If NOT exist %$CD%\%$PROCESS_8% (echo [ ]8. %$PROCESS_T_8%) else (echo [x]8. %$PROCESS_T_8%)
If NOT exist %$CD%\%$PROCESS_9% (echo [ ]9. %$PROCESS_T_9%) else (echo [x]9. %$PROCESS_T_9%)
If NOT exist %$CD%\%$PROCESS_0% (echo [ ]0. %$PROCESS_T_0%) else (echo [x]0. %$PROCESS_T_0%)
echo [ ]X. Exit
echo.
echo ----------------------------------------------------------------------
echo.
IF %$BANNER% EQU 1 GoTo :EOF
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $BANNER=1
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: User Menu
:Menu
call :banner
echo Choose a process:
echo ^(X to exit^)
Choice /c 0123456789X
Echo.
	If ERRORLevel 11 GoTo exit
	If ERRORLevel 10 GoTo P9
	If ERRORLevel 9 GoTo P8
	If ERRORLevel 8 GoTo P7
	If ERRORLevel 7 GoTo P6
	If ERRORLevel 6 GoTo P5
	If ERRORLevel 5 GoTo P4
	If ERRORLevel 4 GoTo P3
	If ERRORLevel 3 GoTo P2
	If ERRORLevel 2 GoTo P1
	If ERRORLevel 1 GoTo P0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: PRCOCESSES
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	Template	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::P#
::	SET $STEP_NUM=#
::	SET $STEP_DESCRIP=%$Process_T_#%
::	CALL :banner
::	IF EXIST "%$CD%\%$PROCESS_#%" GoTo skipP#
::	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
::	Echo Processing %$STEP_DESCRIP% ...
::
::	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
::	echo %$STEP_DESCRIP% Done.
::	Timeout /T %$TIMEOUT%
:::skipP#
::	SET	$STEP_NUM=0
::	SET "$STEP_DESCRIP=Menu selection"
::	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#1
::	Configure Local Administrator Account
:P1
	SET	$STEP_NUM=1
	SET $STEP_DESCRIP=%$Process_T_1%
	CALL :banner
	IF EXIST "%$CD%\$%PROCESS_1%" GoTo skipP1
	Echo Processing %$STEP_DESCRIP% ...
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	rem	there's a space between username and options which is the password (blank)
	NET USER Administrator  /ACTIVE:YES && (echo %DATE% %TIME% > "%$CD%\%$PROCESS_1%")
	NET USER >> "%$CD%\%$PROCESS_1%""
	NET LOCALGROUP Administrators >> "%$CD%\%$PROCESS_1%"
	NET USER Administrator >> "%$CD%\%$PROCESS_1%"
	echo %TIME% [INFO]	%$STEP_DESCRIP%! >> "%$LD%\%$MODULE_LOG%"
	IF DEFINED $LOCAL_USER NET USER %$LOCAL_USER% /Active:No 2> nul
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	::	no need to logoff if already logged in as Administrator
	IF "%USERNAME%"=="Administrator" GoTo skipP1
	shutdown /R /T 5 /f /c "Reboot to flush logged on user profile and log in with Administrator account."
	GoTo Exit
:skipP1
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	#2
::	Delete User profile used for Windows imaging; confired in config file
:P2
	SET $STEP_NUM=2
	SET $STEP_DESCRIP=%$Process_T_2%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_2%" GoTo skipP2	
	Echo Processing %$STEP_DESCRIP% ...
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	@powershell -command "(Get-WmiObject Win32_UserProfile | Select-Object LocalPath, SID | Out-String -Width 100)" >  "%$CD%\User_Profiles.txt"
	IF NOT DEFINED $LOCAL_USER GoTo skipP2
	FINDSTR /I /C:"%$LOCAL_USER%" "%$CD%\User_Profiles.txt" 2> nul > "%$CD%\Default_User.txt"
	IF %ERRORLEVEL% EQU 1 GoTo skipP2
	for /f "tokens=2 delims= " %%P IN (%$CD%\Default_User.txt) do echo %%P> "%$CD%\User_SID.txt"
	SET /P $USER_SID= < "%$CD%\User_SID.txt"
	@powershell -command "(Get-WmiObject Win32_UserProfile | where {$_.SID -like '%$USER_SID%'} |  Remove-WmiObject)"
	echo %TIME% [INFO]	%$PROCESS_T_2% completed! >> "%$LD%\%$MODULE_LOG%"
	type "%$CD%\User_Profiles.txt" > "%$CD%\%$PROCESS_2%"
	NET USER %$LOCAL_USER% >> "%$CD%\%$PROCESS_2%"
	NET USER %$LOCAL_USER% /DELETE >> "%$CD%\%$PROCESS_2%"
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
:skipP2
	type "%$CD%\User_Profiles.txt" > "%$CD%\%$PROCESS_2%"
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: #3
:: Clean up task scheduler, OneDrive
:P3
	SET $STEP_NUM=3
	SET $STEP_DESCRIP=%$Process_T_3%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_3%" GoTo skipP3	
	Echo Processing %$STEP_DESCRIP% ...
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	echo %DATE% %TIME% > "%$CD%\%$PROCESS_3%"
	SET $TOKEN=1
:STL
	:: Scheduled task loop
	SET $KEYWORD=
	IF DEFINED $KEYWORD_SCHEDULED_TASK FOR /F "tokens=%$TOKEN% delims= " %%P IN ("%$KEYWORD_SCHEDULED_TASK%") DO SET $KEYWORD=%%P
	IF NOT DEFINED $KEYWORD GoTo skipP3
	echo The following scheduled tasks will be delted: >> "%$CD%\%$PROCESS_3%"
	SCHTASKS /QUERY /FO LIST | FIND /I "%$KEYWORD%" 2> nul >> "%$CD%\%$PROCESS_3%"
	IF %ERRORLEVEL% NEQ 0 GoTo skipP3
	FOR /F "tokens=2 delims=\" %%P IN ('SCHTASKS /QUERY /FO LIST ^| FIND /I "%$KEYWORD%"') DO SCHTASKS /DELETE /F /TN "%%P"
	echo. >> "%$CD%\%$PROCESS_3%"
	SET /A  $TOKEN=%$TOKEN% + 1
	GoTo STL
:skipP3
	echo %TIME% [INFO]	%$PROCESS_T_3% completed! >> "%$LD%\%$MODULE_LOG%"
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	APPX Packages	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:P4
	SET $STEP_NUM=4
	SET $STEP_DESCRIP=%$Process_T_4%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_4%" GoTo skipP4
	Echo Processing %$STEP_DESCRIP% ...
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"
	echo %date% %TIME% >> "%$CD%\%$PROCESS_4%"
	::	Get list of all APPX packages	
	echo Installed APPX packages: >> "%$CD%\%$PROCESS_4%"
	@powershell Get-AppxPackage -allusers | Findstr /I /B "Name" | sort >> "%$CD%\%$PROCESS_4%"
	IF exist "%$CD%\APPX_List_FullPackage.txt" (
		type "%$CD%\APPX_List_FullPackage.txt" >> type "%$CD%\APPX_List_FullPackage.log"
		del /Q "%$CD%\APPX_List_FullPackage.txt"
		)
	for /f %%P in (%$APPX_LIST%) DO @powershell Get-AppxPackage %%P -allusers | FIND /I "PackageFullName" >> "%$CD%\APPX_List_FullPackage.txt"
	echo Removing APPX packages from APPX list...
	type %$APPX_LIST%
	FOR /F "tokens=3 delims= " %%P IN (%$CD%\APPX_List_FullPackage.txt) do (
		echo removing %%P
		@powershell Remove-AppxPackage -AllUsers -Package %%P 2> nul
		)
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
:skipP4
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Windows Updates via Powershell	:::::::::::::::::::::::::::::::::::::::::::
:P5
	SET $STEP_NUM=5
	SET $STEP_DESCRIP=%$Process_T_5%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_5%" GoTo jumpWU
	Echo Processing %$STEP_DESCRIP% ...
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	:: Test if dependencies are already installed
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
	echo %Date% %TIME% >> "%$CD%\%$PROCESS_5%"
	@powershell Get-WindowsUpdate >> "%$CD%\%$PROCESS_5%"
:jumpWU
	CALL :banner
	@powershell Write-Host "If required, computer will auto-reboot!" -ForegroundColor Yellow
	echo %TIME% [INFO]	Processing %$Process_T_5%... >> "%$LD%\%$MODULE_LOG%"
	echo %Date% %TIME% >> "%$CD%\%$PROCESS_5%"
	IF DEFINED $NotKBArticleID (
		@powershell Install-WindowsUpdate -NotKBArticleID %$NotKBArticleID% -AcceptAll -AutoReboot) else (
			@powershell Install-WindowsUpdate -AcceptAll -AutoReboot
		)
	@powershell Get-WURebootStatus
	@powershell Get-WURebootStatus | FIND /I "True" 1> nul 2> nul && @powershell Write-Host "Computer needs to reboot!" -ForegroundColor Yellow
	@powershell Get-WURebootStatus | FIND /I "False" 1> nul 2> nul && @powershell Write-Host "Computer reboot not required!" -ForegroundColor Yellow
	echo %TIME% [INFO]	%$Process_T_5% Completed! >> "%$LD%\%$MODULE_LOG%"
	echo Windows update via powershell has completed!
	Timeout /T %$TIMEOUT%
:skipP5
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Dirty Bit Disk Check	:::::::::::::::::::::::::::::::::::::::::::::::::::
:P6
	SET $STEP_NUM=6
	SET $STEP_DESCRIP=%$Process_T_6%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_6%" GoTo skipP6
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	Echo Processing %$STEP_DESCRIP% ...
	CHKNTFS %SYSTEMDRIVE% | FIND "%SYSTEMDRIVE% is dirty." && echo y | chkdsk %systemdrive% /B
	echo %DATE% %TIME% > "%$CD%\%$PROCESS_6%"
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	echo %$STEP_DESCRIP% Done.
	Timeout /T %$TIMEOUT%
:skipP6
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Bitlocker check UNLOCK	:::::::::::::::::::::::::::::::::::::::::::::::::::
:P7
	SET $STEP_NUM=7
	SET $STEP_DESCRIP=%$Process_T_7%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_7%" GoTo skipP7
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	Echo Processing %$STEP_DESCRIP% ...
	REM Added to support Windows Server, failed to skip
	where Manage-bde.exe & SET $BITLOCKER_STATUS=%ERRORLEVEL%
	IF %$BITLOCKER_STATUS% EQU 1 GoTo skipP7
	Manage-bde.exe -status %SYSTEMDRIVE% 2> nul || GoTo skipP7
	Manage-bde.exe -status %SYSTEMDRIVE% > "%$CD%\%$PROCESS_7%"
	FIND /I "Percentage Encrypted:" "%$CACHE%\Bitlocker.txt" >> "%$CD%\%$PROCESS_7%"
	FIND /I "Protection Status:" "%$CACHE%\Bitlocker.txt" >> "%$CD%\%$PROCESS_7%"
	SET $BITLOCKER=0
	FIND /I "Percentage Encrypted: 0.0" "%$CD%\%$PROCESS_7%" 2>nul || SET $BITLOCKER=1
	FIND /I "Protection On" "%$CD%\%$PROCESS_7%"  && SET $BITLOCKER=1
	FIND /I "Encryption in Progress" "%$CD%\%$PROCESS_7%" 2>nul && SET $BITLOCKER=1
	IF %$BITLOCKER% EQU 0 GoTo skipP7
	Manage-bde.exe -off %SYSTEMDRIVE%
	echo Bitlocker is being turned off, disk decryption in process...
	:BLS
	CALL :banner
	echo Bitlocker is being turned off, disk decryption in process...
	echo.
	Manage-bde.exe -status %SYSTEMDRIVE%
	Manage-bde.exe -status %SYSTEMDRIVE% | FIND /I "Fully Decrypted" 2>nul && GoTo skipBLS
	Timeout /T %$TIMEOUT%	
	GoTo BLS
	:skipBLS
	echo %DATE% %TIME% >> "%$CD%\%$PROCESS_7%"
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	echo %$STEP_DESCRIP% Done.
	Timeout /T %$TIMEOUT%
:skipP7
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	CLEANMGR	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:P8
	SET $STEP_NUM=8
	SET $STEP_DESCRIP=%$Process_T_8%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_8%" GoTo skipP8
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /S /V StateFlags0100 1> nul 2> nul
	SET $CLEANER_STATUS=%ERRORLEVEL%
	IF %$CLEANER_STATUS% EQU 0 GoTo jumpCS
	Echo Processing %$STEP_DESCRIP% setup...
	CLEANMGR /SAGESET:100
	:jumpCS
	echo Processing %$STEP_DESCRIP%...
	echo %DATE% %TIME% Start... > "%$CD%\%$PROCESS_8%" 
	CLEANMGR /SAGERUN:100
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	echo %DATE% %TIME% End. >> "%$CD%\%$PROCESS_8%" 
	echo %$STEP_DESCRIP% Done.
	Timeout /T %$TIMEOUT%
:skipP8
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Final Reboot B4 SysPrep	:::::::::::::::::::::::::::::::::::::::::::::::::::
:P9
	SET $STEP_NUM=9
	SET $STEP_DESCRIP=%$Process_T_9%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_9%" GoTo skipP9
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	Echo Processing %$STEP_DESCRIP% ...
	echo %DATE% %TIME% > "%$CD%\%$PROCESS_9%"
	shutdown /R /T %$TIMEOUT% /f /c "Final Shutdown for SysPrep."
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	echo %$STEP_DESCRIP% Done.
	GoTo exit
:skipP9
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	SysPrep	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:P0
	SET $STEP_NUM=0
	SET $STEP_DESCRIP=%$Process_T_0%
	CALL :banner
	IF EXIST "%$CD%\%$PROCESS_0%" GoTo skipP0
	echo %TIME% [INFO]	Processing %$STEP_DESCRIP%... >> "%$LD%\%$MODULE_LOG%"	
	Echo Processing %$STEP_DESCRIP% ...
	echo %DATE% %TIME%	%$STEP_DESCRIP% > "%$CD%\%$PROCESS_0%"
	openfiles 1> nul 2> nul
	SET $ADMIN_STATUS=%ERRORLEVEL%
	IF %$ADMIN_STATUS% NEQ 0 GoTo sysprepE
	IF %$IMAGE_USE% EQU 1 call :subIU
	IF %$IMAGE_USE% EQU 1 set /P $IMAGE_NAME= < "%$IMAGE_DIRECTORY%\%$IMAGE_FILE%"
	IF %$IMAGE_USE% EQU 1 echo %TIME% [INFO]	Image Name: %$IMAGE_NAME% >> "%$LD%\%$MODULE_LOG%"
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

	echo Running SysPrep...
	echo %DATE% %TIME% > "%$CD%\%$PROCESS_0%"
	CD /D "%SystemRoot%\System32\SysPrep"
	if %$UNATTEND_USE% EQU 1 (@sysprep /oobe /generalize /unattend:%$Unattend_FILE% /shutdown) ELSE (
		@sysprep /oobe /generalize /shutdown
		)
	FIND /I "Error" "%WINDIR%\System32\Sysprep\Panther\setuperr.log" 1> nul 2> nul && SET $SYSPREP_ERROR=1
	echo %TIME% [DEBUG]	$SYSPREP_ERROR: %$SYSPREP_ERROR% >> "%$LD%\%$MODULE_LOG%"
	echo %TIME%	SysPrep error level: %$SYSPREP_ERROR% >> "%$CD%\%$PROCESS_0%"
	echo %TIME% [INFO]	%$STEP_DESCRIP% completed! >> "%$LD%\%$MODULE_LOG%"
	echo %$STEP_DESCRIP% Done.
::	robocopy "%$LD%" "%$LD%\completed" *.txt /MOV /XF Local_Users.txt CloneZilla_Image.txt /R:1 /W:2 1> nul 2> nul
	robocopy "%WINDIR%\System32\Sysprep\Panther" "%$LD%\Panther" /S /E /R:1 /W:2 /NP 1> nul 2> nul
	IF %$SYSPREP_ERROR% EQU 1 GoTo sysprepE1
	IF %$SYSPREP_ERROR% EQU 0 GoTo exit
:skipP0
	SET	$STEP_NUM=0
	SET "$STEP_DESCRIP=Menu selection"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Trap to avoid everything below here!	:::::::::::::::::::::::::::::::::::
::	shouldn't be here!
GoTo exit


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	ERRORS
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	
:sysprepE
	echo ERROR: Not running with Administrative privilege!
	echo.
	echo Run as administrator!
	if exist "%$CD%\%$PROCESS_0%" DEL /F /Q "%$CD%\%$PROCESS_0%"
	PAUSE
	GoTo exit
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:sysprepE1
::	Color CE 
	echo ERROR!
	echo.
	echo Check the sysprep error log!
	@explorer "%WINDIR%\System32\Sysprep\Panther\setuperr.log"
	PAUSE
	if exist "%$CD%\%$PROCESS_0%" DEL /F /Q "%$CD%\%$PROCESS_0%"
	GoTo Menu
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::	Sub-routines
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::	Sub-routine for Use Image	:::::::::::::::::::::::::::::::::::::::::::::::
:subIU
	echo Processing image name for image server...

	IF NOT EXIST "%$IMAGE_DIRECTORY%" MD "%$IMAGE_DIRECTORY%"
	echo %$OS%-%$OS_MAJOR%-%$OS_EDITION%-%$OS_DISPLAY_VERSION%-%$OS_CurrentBuildNumber%.%$OS_BUILD_REVISION%-%$IMAGE_TYPE%-img> "%$IMAGE_DIRECTORY%\%$IMAGE_FILE%"
	echo %$OS%-%$OS_MAJOR%-%$OS_EDITION%-%$OS_DISPLAY_VERSION%-%$OS_CurrentBuildNumber%.%$OS_BUILD_REVISION%-%$IMAGE_TYPE%-img >  "%$LD%\%$IMAGE_FILE%"
	GoTo :eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:exit
echo %TIME% [INFO]	Session end. >> "%$LD%\%$MODULE_LOG%"
:: Open Directory
@explorer "%$LD%"
ENDLOCAL
Exit
