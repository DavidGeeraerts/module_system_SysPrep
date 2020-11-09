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

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
SETLOCAL Enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::
::	Major.Minor.Revision
::	Added BUILD number which is used during development and testing.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $SCRIPT_NAME=module_Flash_Sync
SET $SCRIPT_VERSION=0.2.0
SET $SCRIPT_BUILD=20201109-0800

Title %$SCRIPT_NAME% %$SCRIPT_VERSION%
Prompt mrE$G

mode con:cols=85
mode con:lines=50
Prompt $G
color 0B
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
::	All User variables are set within here.
::		(configure variables)
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Repository Locations
SET "$REPO_MODULES=D:\Projects\Script Code\modules\module_system_SysPrep"
SET "$REPO_UNATTEND=D:\Projects\Script Code\Windows Post-Flight"


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: CONSOLE OUTPUT
ECHO  ******************************************************************
ECHO. 
ECHO      		%$SCRIPT_NAME% %$SCRIPT_VERSION%
ECHO.
ECHO  ******************************************************************
ECHO.
echo %DATE% %TIME%
ECHO Processing...
ECHO.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::	Volume
:volume
	CD /D "%~dp0" 2> nul
	SET $PATH=%~dp0
	Call :get-volume %$PATH%
	
:get-volume
	SET $VOLUME=%~d1
	CD /D %$VOLUME%\

:sync
	attrib -A /S
	robocopy "%$REPO_MODULE%" "%$VOLUME%\module_system_SysPrep" /A+:A /MIR /S /E /R:1 /W:5 /XD .git /XF *.old modules_system_SysPrep_Sync.cmd .gitignore
	robocopy "%$REPO_UNATTEND%" %$VOLUME%\Unattend *unattend.xml /A+:A /R:1 /W:5
	IF %ERRORLEVEL% EQU 0 GoTo skipU
:skipU

:end
	echo %DATE% %TIME% > LastUpdated.txt
	cls
	echo.
	dir /S /A:A-S-D /O-D "%$VOLUME%\" 2> nul
	TIMEOUT /T 30
	Exit