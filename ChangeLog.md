# ChangeLog: module_system_SysPrep


## Features Heading
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Fixed` for any bug fixes.
- `Removed` for now removed features.
- `Security` in case of vulnerabilities.
- `Deprecated` for soon-to-be removed features.

[//]: # (Copy paste pallette)
[//]: # (#### Added)
[//]: # (#### Changed)
[//]: # (#### Fixed)
[//]: # (#### Removed)
[//]: # (#### Security)
[//]: # (#### Deprecated)

---

## Version 2.0.2 (2022-01-12)
#### Fixed
- needing to reset log path after reading properties file


---


## Version 2.0.1 (2021-11-22)
#### Fixed
- properties file check

#### Changed
- var to cache


## Version 2.0.0 (2021-11-08)
#### Added
- properties file
- check for properties schema meeting minimum requirement

#### Fixed
- missing Windows update check

#### Removed
- parameters for individual variables.


## Version 1.6.0 (2021-11-03)
#### Added
- Windows build information
- switch for unattend use file
- Windows recon info
- Imaging tool and auto generate image name
- time stamps to logs
- APX sub-routines for APX removal that break Sysprep
- Error catching
- panther folder copied to log folder

### Changed
- Default timeout to 5 sec 
- name to default user
- Logging names and variables
- How flash drive is handled
- banner
- log formatting
- Logging happens where program is executed.

### Removed
- Auto start for script

## Version 1.5.0 (2021-07-09)
### Changed
- Order of the parameters: Customer User is now Param #1

## Version 1.4.0 (2020-11-09)
#### Added
- $DEFAULT_USER which is first time log in user; will resort to manual delete if need be.
- Sync tool for Flash drives

### Changed
- Order of the parameters
- Order of variables in commandlet
- Default is to cleanup unattend files and cache

#### Fixed
- Readme typos


## Version 1.3.0 (2020-09-28)
#### Added
- variable $Unattend_FILE
- Parameter for $Unattend_FILE
- variable for $UNATTEND_DIR
- Parameter for $UNATTEND_DIR
- log tags

### Changed
- Console output for what will run
- $Unattend_Clean to Yes or No (instead of 0 or 1)

#### Fixed
- output if default user doesn't exist for disable
- Delprof2 path based to parameter6

## Version 1.2.1 (2020-09-25)
### Changed
- Step 1 log-off to reboot to flush custom user profile


## Version 1.2.0 (2020-09-24)
### Added
- variable where delprof2 directory path
- option for Unattend.xml cleanup 
- ISO_Date
- Banner description
- Parameters input
- cached parameters
- more information in module log
- var directory

### Changed
- start banner 
- Windows-update module check for speed


## Version 1.1.0 (2020-09-23)
### Added
- script info to session log
- Check on user cleanup

### Changed
- Start link back to user profile instead of system
- comments with rem
- handling of cleaning up users


## Version 1.0.0 (2020-09-22)
- First Release