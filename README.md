# :arrows_clockwise: module_system_SysPrep


### :page_with_curl: Description

Automated processing of SysPrep.
Likes to be on a [USB] flash drive; can run from other local storage.
Log files will be stored where the program was executed from.


### :arrow_down: Download

Can download just the commandlet:
[Download](https://raw.githubusercontent.com/DavidGeeraerts/module_system_SysPrep/main/module_system_SysPrep.cmd) --right-click and "Save Link as..."


## :white_check_mark: Process List

:zero: Flush logged on user --usually the default user.

:one: Administrator, local configuration

:two: Users, cleanup local users

:three: Scheduled Task, cleanup

:four: Windows Update

:five: Disk Check, for dirty bit

:six: CleanMgr, run disk cleanup

:seven: Final reboot, in preparation for running SysPrep

:eight: SysPrep


### :green_book: Instructions

Best practice is to use external storage such as a USB Flash drive.

- Manually run module\_system\_SysPrep with administrative privilege
	- Pass the config file name as a parameter.
	- default `module_system_SysPrep.properties`
- First run will configure the local administrator and log out current user, which should be the unattend.xml first logon user.
- Log in with local Administrator account --no password 
- CleanMgr will prompt if SAGE 100 is not set
- Final Reboot will reboot and auto-login Administrator
- Manually run module_system_SysPrep with admin privilege for the final SysPrep run.


#### :orange_book: Dependencies

- [Delprof2](https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/)
	- Useful tool that does a complete job. Better than Powershell:
	- *`Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'UserA' } | Remove-CimInstance`*
		- which leaves the user account on the system!

#### :incoming_envelope: Passing Config file as Paramter

- Open shell/terminal with administrative privilege
- cd /D to module directory where module_system_SysPrep.cmd
- Pass config file name if not the default `module_system_SysPrep.properties`
- Can have different properties files for different systems, then just pass the [custom] properties file as a parameter.


Example:

- `module_system_SysPrep.cmd` `Custom.config`


##### :notebook: Notes (recent to old)

- Looks for APX packages that are known to break SysPrep in Window 11
- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
