
<img src="/images/module_system_sysprep_logo.png" alt="Logo generated using Midjourney Image Generator" title="module_system_sysprep logo" width="500" height="500"/>

# :arrows_clockwise: module_system_SysPrep


### :page_with_curl: Description

Please refer to [Microsoft documentation on sysprep](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview?view=windows-11).

Version 3 is a complete rewrite of the program.
It's now a menu driven interactive program, so you can choose what you want to do.
Automated processing of SysPrep for Windows 10 & 11; should work for Windows server that have only run basic Windows setup.
Log files will be stored where the program was executed from.


### :arrow_down: Download

Download the project as .zip file from [releases](https://github.com/DavidGeeraerts/module_system_SysPrep/releases/latest)


## :white_check_mark: Process List

<img src="/images/Main_menu.png" alt="Main menu" title="module_system_sysprep main menu" width="500" height="500"/>

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

- Add APPX packages to the list in this [file:](./config/APPX_List.txt) `APPX_List.txt`

- APPX packages can be added back after image depployment.


:five: Windows Update

- Process windows updates via powershell [PSWindowsUpdate](https://www.powershellgallery.com/packages/PSWindowsUpdate) module

- Can exclude KB's in the [properties file](./config/module_system_SysPrep.properties)

:six: Disk Check, for dirty bit

- [Check to see if system volume has dirty bit](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/chkntfs)


:seven: CleanMgr, run disk cleanup

- Cleans up the system volume using [cleanmgr](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cleanmgr)


:eight:  Bitlocker check

- Checks to see if bitlocker is on for an encrypted system volume, and if so, it will unencrpyt to prepare for iamge capture.

- "If you run Sysprep on an NTFS file system partition that contains encrypted files or folders, the data in those folders becomes completely unreadable and unrecoverable."

- Uses [manange-bde](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/manage-bde)


:nine: Reboot

- Careful when choosing to reboot. Some APPX packages are set to install on user login, including the local administrator. Once APPX package removal has run, that's the time to sysprep, which is to say that if you have a reason to reboot, run APPX package removal just before running sysprep. 


:zero: SysPrep

- Everything you need to know about [Sysprep](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview?view=windows-11).

#### Sysprep process overview

When Sysprep runs, it goes through the following process:

1. Sysprep verification. Verifies that Sysprep can run. Only an administrator can run Sysprep. Only one instance of Sysprep can run at a time. Also, Sysprep must run on the version of Windows that you used to install Sysprep.
2. Logging initialization. Initializes logging. For more information, see Sysprep Log Files.
3. Parsing command-line arguments. Parses command-line arguments. If a user does not provide command-line arguments, a System Preparation Tool window appears and enables users to specify Sysprep actions.
4. Processing Sysprep actions. Processes Sysprep actions, calls appropriate .dll files and executable files, and adds actions to the log file.
5. Verifying Sysprep processing actions. Verifies that all .dll files have processed all their tasks, and then either shuts down or restarts the system.


### :green_book: Instructions

Use a USB flash drive to run the program from, especially if you don't want to leave anything on the system when imaging. Can run from local storage if need be.
Best practice is to use external storage such as a USB Flash drive. All the logs and cache will be saved to USB so they can be referenced in the future.
Each sysprep run on a computer will be saved to its own directory.

- Manually run module\_system\_SysPrep with administrative privilege
	- Pass the config file name as a parameter if not using the default config.
	- default `module_system_SysPrep.properties`

#### :incoming_envelope: Passing Config file as Paramter

- Open shell/terminal with administrative privilege
- cd /D to module directory where module_system_SysPrep.cmd
- Pass config file name if not the default `module_system_SysPrep.properties`
- Can have different properties files for different systems, then just pass the [custom] properties file as a parameter.

Example:

- `module_system_SysPrep.cmd` `Custom.properties`

Most basic would do the following:
- Configure the local administrator and log out current user, which should be the unattend.xml first logon user.
- Log in with local Administrator account --no password. This will be automatic. 
- Run APPX package removal.
- Run sysprep

#### :orange_book: Dependencies

- Must be run with local Administrator account -- which is why it gets activated.
- cmd
- Powershell
- You must run Windows Setup before you use Sysprep.
- You need a tool to capture an image of the installation, such as DISM - Deployment Image Servicing and Management Technical Reference for Windows or other disk-imaging software.
	- [CloneZilla](https://clonezilla.org/) is recommended if not using DISM


##### :notebook: Notes (recent to old)

- Windows 8.1 and Windows Server 2012 or later, can sysprep up to 1001 times
- Sysprep cannot be run under the context of a System account. Running Sysprep under the context of System account by using Task Scheduler or PSExec, for example, is not supported.
- Remove APPX packages before deleting the local user used in unattend.xml
- Removes APPX packages that are known to break SysPrep in Window 10/11.
- [Microsoft has deprecated the GUI for SysPrep since Windows 8.1](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview) 
- SysPrep must be run with administrative privilege  
- module_system_SysPrep logs will be saved here for archive:
	- C:\Windows\System32\SysPrep\module_system_SysPrep\<ISO_DATE>
