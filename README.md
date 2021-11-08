# module_system_SysPrep


### Description

Automated processing of SysPrep.
Likes to be on a [USB] flash drive; can run from other local storage.
Log files will be stored where the program was executed from.


### Download

Can download just the commandlet:
[Download](https://raw.githubusercontent.com/DavidGeeraerts/module_system_SysPrep/main/module_system_SysPrep.cmd) --right-click and "Save Link as..."


## Process List

0. Flush logged on user --usually the default user.

1. Administrator, local configuration

2. Users, cleanup local users

3. Scheduled Task, cleanup

4. Windows Update

5. Disk Check, for dirty bit

6. CleanMgr, run disk cleanup

7. Final reboot, in preparation for running SysPrep

8. SysPrep


### Instructions

Best practice is to use external storage such as a USB Flash drive.

- Manually run module\_system\_SysPrep with administrative privilege
	- Pass the config file name as a parameter.
	- default `module_system_SysPrep.properties`
- First run will configure the local administrator and log out current user, which should be the unattend.xml first logon user.
- Log in with local Administrator account --no password 
- CleanMgr will prompt if SAGE 100 is not set
- Final Reboot will reboot and auto-login Administrator
- Manually run module_system_SysPrep with admin privilege for the final SysPrep run.


#### Dependencies

- [Delprof2](https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/)
	- Useful tool that does a complete job. Better than Powershell:
	- *`Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'UserA' } | Remove-CimInstance`*
		- which leaves the user account on the system!

#### Passing Config file as Paramter

- Open shell/terminal with administrative privilege
- cd /D to module directory where module_system_SysPrep.cmd
- Pass config file name if not the default `module_system_SysPrep.properties`
- Can have different properties files for different systems, then just pass the [custom] properties file as a parameter.


Example:

- `module_system_SysPrep.cmd` `Custom.config`


##### Notes (recent to old)

- Looks for APX packages that are known to break SysPrep in Window 11
- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
