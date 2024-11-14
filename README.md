
<img src="/images/module_system_sysprep_logo.png" alt="Logo generated using Midjourney Image Generator" title="module_system_sysprep logo" width="500" height="500"/>

# :arrows_clockwise: module_system_SysPrep


### :page_with_curl: Description

Version 3 is a complete rewrite of the program.
It's now interactive, and you can choose what you want to do.

Automated processing of SysPrep.
Log files will be stored where the program was executed from.


### :arrow_down: Download

Download the project as .zip file from [releases](https://github.com/DavidGeeraerts/module_system_SysPrep/releases/)


## :white_check_mark: Process List

:one: Configure the local administrator

	- This will enable and set a blank password for the local administrator account.
	- Computer will reboot to flush the local user profile so it can be deleted, after running APPX process.


:two: Cleanup local user

	- Deletes the local user profile used to initiialy log into windows; this is most often the same account used in [unattend.xml](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11)

	- Uses both powershell and cmd to properly remove user profile from registry and system.


:three: Cleanup Scheduled tasks 

	- Cleans up scheduled tasks created by the local user, such as OneDrive sync, etc.

	- Use [config file](./config/module_system_SysPrep.properties) to add additional keywords.


:four: Windows APPX packages

	- Removes [APPX](https://learn.microsoft.com/en-us/powershell/module/appx/get-appxpackage?view=windowsserver2022-ps) packages that are known to break sysprep

	- APPX packages can be added back after image depployment.


:five: Windows Update

	- Process windows updates via powershell [PSWindowsUpdate](https://www.powershellgallery.com/packages/PSWindowsUpdate) module

	- Can exclude KB's in the [config file](./config/module_system_SysPrep.properties)

:six: Disk Check, for dirty bit

	- [Check to see if system volume has dirty bit](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/chkntfs)


:seven: CleanMgr, run disk cleanup

	- Cleans up the system volume using [cleanmgr](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)


:eight:  Bitlocker check

	- Checks to see if bitlocker is on for an encrypted system volume, and if so, it will unencrpyt to prepare for iamge capture.

	- Uses [manange-bde](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde)


:nine: Reboot

	- Careful when choosing to reboot. Some APPX packages are set to install on user login, including the local administrator. Once APPX package removal has run, that's the time to sysprep, which is to say that if you have a reason to reboot, run APPX package removal just before running sysprep. 


:zero: SysPrep

	- Everything you need to know about [Sysprep](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview?view=windows-11). A.k.a, read the documentation. 


### :green_book: Instructions

Use a USB flash drive to run the program from, especially if you don't want to leave anything on the system when imaging. Can run from local storage if need be.
Best practice is to use external storage such as a USB Flash drive. All the logs and cache will be saved to USB so they can be referenced in the future.
Each sysprep run on a computer will be saved to its own directory.

- Manually run module\_system\_SysPrep with administrative privilege
	- Pass the config file name as a parameter if not using the default config.
	- default `module_system_SysPrep.properties`

Most basic would do the following:
- Configure the local administrator and log out current user, which should be the unattend.xml first logon user.
- Log in with local Administrator account --no password. This will be automatic. 
- Run APPX package removal.
- Run sysprep

#### :orange_book: Dependencies

- cmd
- Powershell


#### :incoming_envelope: Passing Config file as Paramter

- Open shell/terminal with administrative privilege
- cd /D to module directory where module_system_SysPrep.cmd
- Pass config file name if not the default `module_system_SysPrep.properties`
- Can have different properties files for different systems, then just pass the [custom] properties file as a parameter.


Example:

- `module_system_SysPrep.cmd` `Custom.config`


##### :notebook: Notes (recent to old)

- Remove APPX packages before deleting the local user used in unattend.xml
- Looks for APPX packages that are known to break SysPrep in Window 11
- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
