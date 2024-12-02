# Globale Variablen für Navigation
$selectedIndex = 0
$key = ""

# Navigationsfunktion
function Handle-KeyPress {
    param ($key, $maxIndex)
    
    if ($key -eq 38) { $selectedIndex = ($selectedIndex - 1 + $maxIndex) % $maxIndex }  # Arrow Up
    elseif ($key -eq 40) { $selectedIndex = ($selectedIndex + 1) % $maxIndex }  # Arrow Down
    elseif ($key -eq 8) { Show-Menu; return $null }  # Backspace zurück zum Hauptmenü

    return $selectedIndex
}

function Show-Menu {
    cls
    $menuOptions = @(
        "Create Register Backup [Recommended]",
        "Install Software",
        "Uninstall Bloatware",
        "Change Privacy and more",
        "Exit"
    )

    while ($true) {
        cls
        Write-Host "==================================================================================================="
        Write-Host "   Windows 11 Cleanup - A winget bloatware removal tool and Privacy Helper." -ForegroundColor Cyan
        Write-Host "==================================================================================================="
        Write-Host ""
        # Zeige das Menü mit der aktuellen Auswahl an
        for ($i = 0; $i -lt $menuOptions.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  --> $($menuOptions[$i]) <--" -ForegroundColor Yellow
            } else {
                Write-Host "      $($menuOptions[$i])"
            }
        }
        Write-Host ""
        Write-Host "==================================================================================================="
        Write-Host "Use Arrow Up/Down to navigate and Enter to select an option."

        # Eingabe des Benutzers abwarten
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # Verwende Handle-KeyPress für Navigation und Eingabe
        $selectedIndex = Handle-KeyPress -key $key -maxIndex $menuOptions.Length

        # Falls Backspace gedrückt wurde, gehe zurück zum Hauptmenü
        if ($selectedIndex -eq $null) { return }

        # Auswahl mit Enter
        if ($key -eq 13) {  # Enter
            switch ($selectedIndex) {
                0 { Backup-Registry }
                1 { Install-Software }
                2 { Uninstall-Bloatware }
                3 { Change-Privacy }
                4 { Write-Host "Exiting the program." exit }
            }
        }
    }
}


function Backup-Registry {
    Write-Host ""
    Write-Host "Creating registry backup, please wait..."

    # Setze den Pfad zum _backupRegistry-Ordner im Hauptverzeichnis des Skripts
    $backupPath = [System.IO.Path]::Combine($PSScriptRoot, '_backupRegistry')

    # Erstelle den Ordner, wenn er noch nicht existiert
    if (-Not (Test-Path -Path $backupPath)) {
        New-Item -Path $backupPath -ItemType Directory
    }

    # Exportiere die Registry-Schlüssel für HKLM und HKCU
    $hkmlBackup = [System.IO.Path]::Combine($backupPath, 'RegistryBackupA.reg')
    $hkcuBackup = [System.IO.Path]::Combine($backupPath, 'RegistryBackupB.reg')

    if (-Not (Test-Path -Path $hkmlBackup)) {
        Write-Host "Exporting HKLM registry to $hkmlBackup"
        reg export "HKLM" $hkmlBackup /y
        Write-Host
    } else {
        Write-Host "Backup for HKLM already exists. Skipping..."
    }

    if (-Not (Test-Path -Path $hkcuBackup)) {
        Write-Host "Exporting HKCU registry to $hkcuBackup"
        reg export "HKCU" $hkcuBackup /y
        Write-Host
    } else {
        Write-Host "Backup for HKCU already exists. Skipping..."
        Write-Host
    }

    Write-Host
    Write-Host "Registry backups completed in the '_backupRegistry' folder."
    Write-Host
}


function Uninstall-Bloatware {
    Write-Host ""
    Write-Host "Running Uninstall-Bloatware process..."

    # Load the apps from the applist.txt file
    $appListFile = "$PSScriptRoot\applist.txt"
    
    if (Test-Path -Path $appListFile) {
        $apps = Get-Content -Path $appListFile
        foreach ($app in $apps) {
            Write-Host "Uninstalling $app..."
            try {
                winget uninstall $app --accept-source-agreements --silent
                Write-Host "$app uninstalled successfully." -ForegroundColor Green
            } catch {
                Write-Host "Failed to uninstall $app." -ForegroundColor Red
            }
        }
        # Warten auf Bestätigung mit Enter
        Write-Host ""
        Write-Host "Bloatware successfully uninstalled. Press Enter to return to the main menu."
        Write-Host " Putrefy, rot, spoil, and fester..." -ForegroundColor DarkRed
        $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")  # Warten auf Enter-Taste
    } else {
        Write-Host "The applist.txt file does not exist. Please create the file with the list of apps." -ForegroundColor Red
    }

    Show-Menu
}



function Change-Privacy {
    cls
    Write-Host "==================================================================================================="
    Write-Host "     Change Privacy Settings" -ForegroundColor Cyan
    Write-Host "==================================================================================================="
    Write-Host ""

    # Liste der .reg-Dateien im regfiles-Ordner
    $regFiles = Get-ChildItem -Path "$PSScriptRoot\regfiles" -Filter "*.reg" | Select-Object -ExpandProperty Name

    # Initialisiere den Index und die Tasteneingabe
    $selectedIndex = 0
    $key = ""

    while ($true) {
        cls
        Write-Host "==================================================================================================="
        Write-Host "     Change Privacy Settings" -ForegroundColor Cyan
        Write-Host "==================================================================================================="
        Write-Host ""

        # Zeige die verfügbaren .reg-Dateien an
        for ($i = 0; $i -lt $regFiles.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  --> $($regFiles[$i]) <--" -ForegroundColor Yellow
            } else {
                Write-Host "      $($regFiles[$i])"
            }
        }

        Write-Host ""
        Write-Host "==================================================================================================="
        Write-Host "Use Arrow Up/Down to select a file, Enter to apply, Backspace to return to the main menu." -ForegroundColor Cyan
        Write-Host ""
        Write-Host ""

        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # Handle Navigation und Backspace
        $selectedIndex = Handle-KeyPress -key $key -maxIndex $regFiles.Length
        if ($selectedIndex -eq $null) { return }

        # Wende die .reg-Datei an, wenn Enter gedrückt wird
        if ($key -eq 13) {
            $selectedFile = $regFiles[$selectedIndex]
            Write-Host "Applying selected registry file: $selectedFile"
        
            try {
                & reg import "$PSScriptRoot\regfiles\$selectedFile"
                Write-Host "Registry file applied successfully." -ForegroundColor Green
                Write-Host ""
            } catch {
                Write-Host "Error applying registry file: $_" -ForegroundColor Red
            }

            # Sysprep-File anwenden, wenn vorhanden
            $sysprepFile = "$PSScriptRoot\regfiles\Sysprep\$selectedFile"
            if (Test-Path $sysprepFile) {
                Write-Host "Applying sysprep registry file: $sysprepFile"
                try {
                    & reg import $sysprepFile
                    Write-Host "Sysprep registry file applied successfully." -ForegroundColor Green
                    Write-Host ""
                    Write-Host ""
                } catch {
                    Write-Host "Error applying sysprep registry file: $_" -ForegroundColor Red
                    Write-Host ""
                }
            } else {
                Write-Host "Sysprep registry file not found for: $selectedFile" -ForegroundColor Red
            }

            if ($selectedFile -eq "Disable_AI_Recall.reg") {    # Falls "Disable_AI_Recall.reg" ausgewählt wurde, Recall-Feature deaktivieren
                try {
                    dism /Online /Disable-Feature /FeatureName:"Recall"
                    Write-Host ""
                    Write-Host "ACHIEVEMENT UNLOCKED: Such a Good Boy!" -ForegroundColor Green -NoNewline
	                Write-Host " - " -ForegroundColor Black -NoNewline
	                Write-Host "You disabled Microsoft Recall <3"
                    Write-Host ""
                } catch {
                    Write-Host "Error: cannot disable feature -> Recall <-" -ForegroundColor Red
                    Write-Host ""
                }
            }

            pause
        }
    }
}





function Install-Software {
    cls
    $options = @(
        "Install Software List (Default: Discord, Steam, Epic Games, Ubisoft Connect)",
        "Install Software from Software-Folder [PREVIEW]"
    )

    while ($true) {
        cls
        Write-Host "==================================================================================================="
        Write-Host "     Install Software" -ForegroundColor Cyan
        Write-Host "==================================================================================================="
        Write-Host ""   
        # Zeige die Optionen mit der Auswahl
        for ($i = 0; $i -lt $options.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  --> $($options[$i]) <--" -ForegroundColor Yellow
            } else {
                Write-Host "      $($options[$i])"
            }
        }
        Write-Host ""
        Write-Host "==================================================================================================="
        Write-Host "Use Arrow Up/Down to navigate and Enter to select an option."

        # Eingabe des Benutzers abwarten
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode

        # Verwende Handle-KeyPress für Navigation und Eingabe
        $selectedIndex = Handle-KeyPress -key $key -maxIndex $options.Count

        # Falls Backspace gedrückt wurde, gehe zurück ins Hauptmenü
        if ($selectedIndex -eq $null) { return }

        # Auswahl mit Enter
        if ($key -eq 13) { 
            switch ($selectedIndex) {
                0 { Install-Softwarelist }
                1 { Install-CustomSoftware }
            }
        }
    }
}

function Install-Softwarelist {
    cls
    Write-Host "==================================================================================================="
    Write-Host "     Installing Software from softwarelist.txt" -ForegroundColor Cyan
    Write-Host "==================================================================================================="
    Write-Host ""
    $softwareListFile = "$PSScriptRoot\softwarelist.txt"

    if (-not (Test-Path $softwareListFile)) {
        Write-Host "Error: 'softwarelist.txt' not found in the script directory." -ForegroundColor Red
        Pause; Install-Software
    }

    foreach ($software in Get-Content $softwareListFile) {
        Write-Host "Installing $software..."
        try {
            winget install $software --accept-source-agreements --silent
            Write-Host "$software installed successfully." -ForegroundColor Green
            Write-Host ""
        } catch {
            Write-Host "Failed to install $software." -ForegroundColor Red
            Write-Host ""
        }
    }
    Write-Host ""
    Write-Host "ACHIEVEMENT UNLOCKED: Gommemode!" -ForegroundColor Green -NoNewline
    Write-Host " - " -ForegroundColor Black -NoNewline
    Write-Host "You are not a Stinky Goblin <3 You have Discord, Steam, Epic Games and Ubisoft Connect what a GOAT"
    Write-Host ""
    Pause; Install-Software
}

function Install-CustomSoftware {
    cls
    Write-Host "==================================================================================================="
    Write-Host "     Installing Custom Software [PREVIEW]" -ForegroundColor Cyan
    Write-Host "==================================================================================================="
    Write-Host ""

    $softwareFiles = Get-ChildItem "$PSScriptRoot\software" -Recurse | Where-Object { $_.Extension -in @(".exe", ".msi") }

    if (-not $softwareFiles) {
        Write-Host "No .exe or .msi files found in the 'software' folder." -ForegroundColor Red
        Pause; Install-Software
        return
    }

    # Installiere jede Datei im Ordner im Hintergrund (Silent Mode)
    foreach ($file in $softwareFiles) {
        Write-Host "Installing $($file.Name)..."

        # Bestimme den Silent-Parameter abhängig von der Dateiendung
        $arguments = ""

        if ($file.Extension -eq ".msi") {
            $arguments = "/quiet"
        } elseif ($file.Extension -eq ".exe") {
            # Hier kann je nach Installer-Software angepasst werden
            $arguments = "/S"  # Beispiel für viele .exe-Installationen
        }

        try {
            # Starte den Prozess im Hintergrund mit Silent-Option
            Start-Process -FilePath $file.FullName -ArgumentList $arguments -Wait -WindowStyle Hidden
            Write-Host "$($file.Name) installed successfully." -ForegroundColor Green
            Write-Host ""
        } catch {
            Write-Host "Failed to install $($file.Name)." -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "All installations completed!" -ForegroundColor Green
    Pause
}




    


# Main script loop to handle user input
do {
    # Display the menu and get user input
    $selection = Show-Menu


    # Ask if the user wants to perform another action
    $continue = Read-Host "Do you want to perform another action? (y/n)"
} while ($continue -eq "y")