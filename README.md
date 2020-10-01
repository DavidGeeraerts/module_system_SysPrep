# module_system_SysPrep


## Description

Automated processing of SysPrep


### Download

[Download](https://raw.githubusercontent.com/DavidGeeraerts/module_system_SysPrep/main/module_system_SysPrep.cmd) --right-click and "Save Link as..."


### Process List

1. Administrator, local configuration

2. Users, cleanup local users

3. Scheduled Task, cleanup

4. Windows Update

5. Disk Check, for dirty bit

6. CleanMgr, run disk cleanup

7. Final reboot, in preperation for running SysPrep

8. SysPrep


#### Instructions

Flash drive friendly

- Manually run module_system_SysPrep with administrative privilege
	- Pass any parameters in order, each subsequent parameter is dependent on the previous parameter being passed.
	- meaning, if you want PARAMETER6, you have to pass all the parametrs 1-5
- First run will configure the local administrator and log out current user, which should be the unattend.xml first logon user.
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
- parameters are seperated by a space; use double quotes if parameter has a space: *"parameter with space"*

1. Paramter 1 ($CUSTOM_USER)
	- String
	- The user configured in the unattend.xml file

2. Paramter 2 ($TIMEOUT)
	- Seconds
	- Console screen timeout. Default is 10 seconds

3. Paramter 3 ($UNATTEND_CLEAN)
	- {No,Yes}
	- Clean up all the unattend.xml files from the systemdrive before running SysPrep
	- Useful for cleanup if seeding unattend.xml file
	- will flush Windows cache for unattend.xml/Autounattend.xml

4. Parameter 4 ($Unattend_FILE)
	- Unattend file name to seed
	- can be set to 0 to bypass, otherwise if defined the unattend file will be seeded

5. Parameter 5 ($UNATTEND_DIR)
	- Full path to the directory
	- defualt is Unattend (i.e. <Volume>:\Unattend)

6. Paramter 6 ($DELPROF2_PATH)
	- Directory path
	- Where delprof2.exe resides in relation to the volume where the module is run from
	- By default, Flash Drive Root\Tools

Example:
- *module_system_SysPrep.cmd Paramter1 Paramter2 Paramter3 Paramter4 Paramter5 Paramter6*
- *module_system_SysPrep.cmd UnattendUser 10 1 SysPrep_unattned.xml Unattend Tools*

**Parameters only need to be passed once for the session, as they are cached.**

##### Notes

- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
