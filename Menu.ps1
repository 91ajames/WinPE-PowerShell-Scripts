$ScriptsPath = "X:\Scripts"

while ($true) {
    Clear-Host
    Write-Host "====================================="
    Write-Host "        WinPE Script Launcher"
    Write-Host "====================================="
    Write-Host ""

    # Get script files
    $scripts = Get-ChildItem -Path $ScriptsPath -Filter *.ps1 -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "WinPE-Menu.ps1" } |
        Sort-Object Name

    # Get text files
    $textFiles = Get-ChildItem -Path $ScriptsPath -Filter *.txt -File -ErrorAction SilentlyContinue |
        Sort-Object Name

    $hasScripts = $scripts -and $scripts.Count -gt 0
    $hasTextFiles = $textFiles -and $textFiles.Count -gt 0

    if (-not $hasScripts -and -not $hasTextFiles) {
        Write-Host "No scripts or text files found in $ScriptsPath"
        Write-Host ""
        Write-Host "P. Open PowerShell"
        Write-Host "R. Refresh"
        Write-Host "X. Exit"
        Write-Host ""

        $choice = Read-Host "Select option"

        switch ($choice.ToUpper()) {
            "P" { powershell.exe -NoExit }
            "R" { }
            "X" { break }
            default {
                Write-Host "Invalid selection..."
                Start-Sleep 1
            }
        }
        continue
    }

    # Display scripts first
    if ($hasScripts) {
        Write-Host "Scripts:"
        for ($i = 0; $i -lt $scripts.Count; $i++) {
            Write-Host "$($i + 1). $($scripts[$i].Name)"
        }
        Write-Host ""
    }

    # Display text files at bottom
    if ($hasTextFiles) {
        Write-Host "Text Files:"
        for ($i = 0; $i -lt $textFiles.Count; $i++) {
            Write-Host "N$($i + 1). $($textFiles[$i].Name)"
        }
        Write-Host ""
    }

    Write-Host "P. Open PowerShell"
    Write-Host "R. Refresh"
    Write-Host "X. Exit"
    Write-Host ""

    $choice = Read-Host "Select option"

    # ------------------------------
    # Run script by number
    # ------------------------------
    if ($choice -match '^\d+$') {
        $index = [int]$choice - 1

        if ($hasScripts -and $index -ge 0 -and $index -lt $scripts.Count) {
            $selectedScript = $scripts[$index].FullName

            Clear-Host
            Write-Host "====================================="
            Write-Host "Running: $($scripts[$index].Name)"
            Write-Host "====================================="
            Write-Host ""

            try {
                & powershell.exe -ExecutionPolicy Bypass -File $selectedScript
            }
            catch {
                Write-Host "Error running script:"
                Write-Host $_
            }

            Write-Host ""
            Write-Host "Press Enter to return to menu..."
            Read-Host | Out-Null
        }
        else {
            Write-Host "Invalid script number..."
            Start-Sleep 1
        }

        continue
    }

    # ------------------------------
    # Open text file in Notepad
    # Example: N1, N2, N3
    # ------------------------------
    if ($choice -match '^[Nn](\d+)$') {
        $textIndex = [int]$Matches[1] - 1

        if ($hasTextFiles -and $textIndex -ge 0 -and $textIndex -lt $textFiles.Count) {
            $selectedTextFile = $textFiles[$textIndex].FullName

            Clear-Host
            Write-Host "====================================="
            Write-Host "Opening in Notepad: $($textFiles[$textIndex].Name)"
            Write-Host "====================================="
            Write-Host ""

            try {
                Start-Process notepad.exe $selectedTextFile -Wait
            }
            catch {
                Write-Host "Error opening text file:"
                Write-Host $_
                Write-Host ""
                Write-Host "Press Enter to return to menu..."
                Read-Host | Out-Null
            }
        }
        else {
            Write-Host "Invalid text file selection..."
            Start-Sleep 1
        }

        continue
    }

    # ------------------------------
    # Other options
    # ------------------------------
    switch ($choice.ToUpper()) {
        "P" {
            powershell.exe -NoExit
        }
        "R" {
            # refresh loop
        }
        "X" {
            break
        }
        default {
            Write-Host "Invalid selection..."
            Start-Sleep 1
        }
    }
}