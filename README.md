# module_system_SysPrep


## Description

Automated processing of SysPrep

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

- Manually run module_system_SysPrep with privilege
- First run will configure the local administrator and log out current user.
- Log in with lcoal Administrator account --no password 
- CleanMgr will prompt if SAGE 100 is not set
- Final Reboot will reboot and auto-login Administrator
- Manually run module_system_SysPrep with privilege

##### Notes

- Microsoft has deprecated the GUI for SysPrep since Windows 10 [<version>]
- SysPrep must be run with administrative privilege  