# How to Use:
    1. Open softwarelist.txt to review the list of programs you want to install or exclude.
    2. Open applist.txt and remove the # symbol in front of any app you want to UNINSTALL by default.


# Information:
## Adding .reg Files
You can add additional .reg files to the `./regfiles/other` folder.

When adding a new .reg file, make sure to place the system-wide .reg file in `./regfiles/Sysprep` and the local .reg file in `./regfiles`.

- **System-wide .reg files**: These apply to all users and are used during the Sysprep process.
- **Local .reg files**: These only apply to the current user and should be placed in `./regfiles`.

## Adding Software Installers
You can add installation files such as `.exe`, `.msi`, etc., to the `./software` folder.  
Alternatively, you can list the installation files in the `softwarelist.txt` if you want to install software via winget or other commands.

## Install Software with Winget
If you want to install software using winget, you can edit the `softwarelist.txt` file.  
More details below: [#HowToAddWingetSoftware]

---

# How to Add Winget Software?
1. Open the `softwarelist.txt` file.
2. Remove the `#` symbol in front of any app name to uncomment it and include it for installation.
3. Any software listed here will be automatically installed when the script is run.

## Adding Custom Software
You can add software from the website (https://winstall.app/).  
Search for the app you want, click on it, and copy the ID (e.g., `Microsoft Edge`).  
Add this ID to `softwarelist.txt` to install the software via winget.

### Example
For instance, if you want to add "Visual Studio Code", you would add the following line to `softwarelist.txt`:

# Visual Studio Code
Microsoft.VisualStudioCode









