function Get-CodeContent {
    param (
        [string]$RootDirectory = (Read-Host "Please enter the root directory path"),
        [string[]]$TargetDirectories = ((Read-Host "Please enter target directories separated by commas") -split ',' -ne ''),
        [switch]$SaveToFile = $false,
        [string]$OutputFile = "output.txt"
    )

    # Ensure TargetDirectories is not empty
    if ($null -eq $TargetDirectories -or $TargetDirectories.Length -eq 0) {
        Write-Error "You must specify at least one target directory. Separate multiple directories with commas."
        return
    }

    try {
        # Validate Root Directory
        if (-not (Test-Path $RootDirectory)) {
            Write-Error "The specified root directory ($RootDirectory) does not exist. Please ensure the path is correct."
            return
        }

        $outputArray = @()

        # Replace generic tree output header with something cleaner
        $outputArray += "File and Folder Structure"
        $treeOutput = & tree /f $RootDirectory 2>&1 | Select-Object -Skip 2
        $outputArray += $treeOutput

        # Fetch file contents
        $fileContents = Get-FileContents $RootDirectory $TargetDirectories
        $outputArray += $fileContents

        # Output
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
