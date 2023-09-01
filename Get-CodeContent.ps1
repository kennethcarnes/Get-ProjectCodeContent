<#
.SYNOPSIS
    Retrieves and displays the directory structure and contents of specified files.

.DESCRIPTION
    This function outputs the directory structure of a specified root directory and
    the content of files within specified target directories relative to the root.
    The results are copied to the clipboard for easy sharing or saved to a file.

.PARAMETER RootDirectory
    The path to the root directory.

.PARAMETER TargetDirectories
    A list of directories relative to the root whose file contents will be displayed.

.PARAMETER SaveToFile
    Switch to indicate whether to save output to a file instead of copying to clipboard.

.PARAMETER OutputFile
    The file where the output should be saved. Only used if SaveToFile is specified.

.EXAMPLE
    Get-CodeContent -RootDirectory "C:\code\azure-swa" -TargetDirectories @("infra", ".github")
#>
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

function Get-FileContents {
    param (
        [string]$RootPath,
        [string[]]$Directories
    )

    $contentArray = @()

    foreach ($dir in $Directories) {
        $fullDirPath = Join-Path $RootPath $dir.Trim()

        if (-not (Test-Path $fullDirPath)) {
            Write-Error "The directory ($dir) does not exist within the root directory."
            continue
        }

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
