# module_system_SysPrep

[Download](https://raw.githubusercontent.com/DavidGeeraerts/module_system_SysPrep/main/module_system_SysPrep.cmd)

## Description

Automated processing of SysPrep


### Download

[Download](https://raw.githubusercontent.com/DavidGeeraerts/module_system_SysPrep/main/module_system_SysPrep.cmd) --right-click and "Save Link as..."


### Features

1. Administrator, local configuration

2. Users, cleanup local users

3. Scheduled Task, cleanup

4. Windows Update

5. Disk Check, for dirty bit

6. CleanMgr, run disk cleanup

7. Final reboot, in preperation for running SysPrep

8. SysPrep


#### Instructions

- Manually run module_system_SysPrep with administrative privilege
- First run will configure the local administrator and log out current user, which should be the unattend.xml user.
- Log in with local Administrator account --no password 
- CleanMgr will prompt if SAGE 100 is not set
- Final Reboot will reboot and auto-login Administrator
- Manually run module_system_SysPrep with privilege


#### Dependencies

- [Delprof2](https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/)
	- Useful tool that does a complete job. Better than Powershell:
	- *Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'UserA' } | Remove-CimInstance*
		- which leaves the user account on the system!

#### Passing Paramters

- Open shell/terminal with administrative privilege
- cd /D to module directory where module_system_SysPrep.cmd
1. Paramter 1 ($CUSTOM_USER)
	- String
	- The user configured in the unattend.xml file

2. Paramter 2 ($TIMEOUT)
	- Seconds
	- Console screen timeout. Default is 10 seconds

3. Paramter 3 ($UNATTEND_CLEAN)
	- {0,1}
	- Clean up all the unattend.xml files from the systemdrive before running SysPrep

4. Paramter 4 ($DELPROF2_PATH)
	- Directory path
	- Where delprof2.exe resides in relation to the volume where the module is run from
	- By default, Flash Drive Root\Tools

Example:
- *module_system_SysPrep.cmd Paramter1 Paramter2 Paramter3 Paramter4*
- *module_system_SysPrep.cmd UnattendUser 10 0 Tools*

**Parameters only need to be passed once for the session, as they are cached.**

##### Notes

- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
