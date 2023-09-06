<#
.SYNOPSIS
Captures a code project's directory structure and file contents.

.DESCRIPTION
This function gets the directory structure and file contents under a given root directory 
and copies it to the clipboard or saves it to a file. Ideal for sharing code projects.

.PARAMETER RootDirectory
The root directory whose structure and file content you want to capture.

.PARAMETER TargetDirectories
The subdirectories under the root you specifically want to target.

.PARAMETER SaveToFile
If set, will save the directory structure and file contents to a file instead of the clipboard.

.PARAMETER OutputFile
If SaveToFile is set, this specifies the name of the output file.

.EXAMPLE
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -TargetDirectories @("subfolder1", "subfolder2")

.EXAMPLE
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -SaveToFile -OutputFile "desired_filename.txt"
#>
function Get-CodeContent {
    param (
        [string]$RootDirectory = $(throw "RootDirectory is a required parameter"),
        [string[]]$TargetDirectories = @(),
        [switch]$SaveToFile = $false,
        [string]$OutputFile = "output.txt"
    )

    # Check if the RootDirectory exists
    if (-not (Test-Path $RootDirectory)) {
        throw "The specified root directory ($RootDirectory) does not exist. Please ensure the path is correct."
    }

    try {
        # Initialize an array to hold output
        $outputArray = @()
        
        # Get and store the tree structure
        $outputArray += "File and Folder Structure"
        $treeOutput = & tree /f $RootDirectory 2>&1 | Select-Object -Skip 2
        $outputArray += $treeOutput

        # Get file contents from target directories or all if not specified
        if ($TargetDirectories.Length -eq 0) {
            $allDirs = Get-ChildItem -Path $RootDirectory -Recurse -Directory | ForEach-Object { $_.Name }
            $fileContents = Get-FileContent -RootPath $RootDirectory -Directories $allDirs
            $fileContents += Get-FileContent -RootPath $RootDirectory -Directories "."
        } else {
            $fileContents = Get-FileContent -RootPath $RootDirectory -Directories $TargetDirectories
        }

        $outputArray += $fileContents

        # Save output to file or clipboard
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

<#
.SYNOPSIS
Captures file contents under specified directories.

.DESCRIPTION
This function is a helper for Get-CodeContent. It fetches the file contents from 
specified directories under a given root path.

.PARAMETER RootPath
The root directory path.

.PARAMETER Directories
The directories under the root path from which to fetch file contents.
#>
function Get-FileContent {
    param (
        [string]$RootPath,
        [string[]]$Directories
    )

    # Initialize an array to hold file content
    $contentArray = @()

    # Iterate through each directory
    foreach ($dir in $Directories) {
        $fullDirPath = Join-Path $RootPath $dir.Trim()
        $files = Get-ChildItem -Path $fullDirPath -Recurse -File

        # Iterate through each file in the directory
        foreach ($file in $files) {
            try {
                $relativePath = $file.FullName.Replace($RootPath, '').TrimStart('\')
                
                # Add content of each file to the array
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
