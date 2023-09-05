function Get-CodeContent {
    param (
        [string]$RootDirectory = $(throw "RootDirectory is a required parameter"),
        [string[]]$TargetDirectories = @(),
        [switch]$SaveToFile = $false,
        [string]$OutputFile = "output.txt"
    )

    # Check if the RootDirectory exists
    if (-not (Test-Path $RootDirectory)) {
        Write-Error "The specified root directory ($RootDirectory) does not exist. Please ensure the path is correct."
        return
    }

    try {
        $outputArray = @()
        $outputArray += "File and Folder Structure"
        $treeOutput = & tree /f $RootDirectory 2>&1 | Select-Object -Skip 2
        $outputArray += $treeOutput

        # If no TargetDirectories specified, default to all including the root
        if ($TargetDirectories.Length -eq 0) {
            $allDirs = Get-ChildItem -Path $RootDirectory -Recurse -Directory | ForEach-Object { $_.Name }
            $fileContents = Get-FileContent -RootPath $RootDirectory -Directories $allDirs
            $fileContents += Get-FileContent -RootPath $RootDirectory -Directories "."
        } else {
            $fileContents = Get-FileContent -RootPath $RootDirectory -Directories $TargetDirectories
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

function Get-FileContent {
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
