function Get-CodeContent {
    param (
        [string]$RootDirectory = $null,
        [string[]]$TargetDirectories = $null,
        [switch]$SaveToFile = $false,
        [string]$OutputFile = "output.txt",
        [switch]$AllDirectories = $false
    )

    if ([string]::IsNullOrEmpty($RootDirectory)) {
        $RootDirectory = Read-Host "Please enter the root directory path"
    }

    if (-not $AllDirectories -and ($null -eq $TargetDirectories)) {
        $TargetDirectories = (Read-Host "Please enter target directories separated by commas") -split ',' -ne ''
    }

    if (-not $AllDirectories -and ($null -eq $TargetDirectories -or $TargetDirectories.Length -eq 0)) {
        Write-Error "You must specify at least one target directory or use -AllDirectories switch. Separate multiple directories with commas."
        return
    }         

    try {
        if (-not (Test-Path $RootDirectory)) {
            Write-Error "The specified root directory ($RootDirectory) does not exist. Please ensure the path is correct."
            return
        }

        $outputArray = @()
        $outputArray += "File and Folder Structure"
        $treeOutput = & tree /f $RootDirectory 2>&1 | Select-Object -Skip 2
        $outputArray += $treeOutput

        if ($AllDirectories) {
            $allDirs = Get-ChildItem -Path $RootDirectory -Recurse -Directory | ForEach-Object { $_.Name }
            $fileContents = Get-FileContents -RootPath $RootDirectory -Directories $allDirs
            $fileContents += Get-FileContents -RootPath $RootDirectory -Directories ""
        } else {
            $fileContents = Get-FileContents -RootPath $RootDirectory -Directories $TargetDirectories
        }

        $outputArray += $fileContents

        if ($SaveToFile) {
            Set-Content -Path $OutputFile -Value ($outputArray -join "`r`n")
            Write-Output "Directory structure and code contents saved to $OutputFile"
        } else {
            $outputArray -join "`r`n" | Set-Clipboard
            Write-Output "Directory structure and code contents copied to clipboard!"
        }
    } catch {
        Write-Error $_.Exception.Message
    }
}

function Get-FileContents {
    param (
        [string]$RootPath,
        [string[]]$Directories
    )

    $contentArray = @()

    foreach ($dir in $Directories) {
        $fullDirPath = Join-Path $RootPath $dir.Trim()

        $files = Get-ChildItem -Path $fullDirPath -Recurse -File

        foreach ($file in $files) {
            try {
                $relativePath = $file.FullName.Replace($RootPath, '').TrimStart('\')
                $contentArray += ""
                $contentArray += "--- Contents of $relativePath ---"
                $contentArray += (Get-Content $file.FullName | ForEach-Object { "    $_" })
                $contentArray += "--- End of $relativePath ---"
            }
            catch {
                Write-Error "Could not read the contents of $file. Error: $_"
                continue
            }
        } 
    }

    return $contentArray
}

# Call the main function
Get-CodeContent