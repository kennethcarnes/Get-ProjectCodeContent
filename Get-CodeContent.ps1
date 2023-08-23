<#
.SYNOPSIS
    Retrieves and displays the directory structure and contents of specified files.

.DESCRIPTION
    This function outputs the directory structure of a specified root directory and
    the content of files within specified target directories relative to the root.
    The results are copied to the clipboard for easy sharing.

.PARAMETER RootDirectory
    The path to the root directory.

.PARAMETER TargetDirectories
    A list of directories relative to the root whose file contents will be displayed.

.EXAMPLE
    Get-CodeContent -RootDirectory "C:\code\azure-swa" -TargetDirectories @("infra", ".github")
#>
function Get-CodeContent {
    param (
        [string]$RootDirectory = (Read-Host "Please enter the root directory path"),
        [string[]]$TargetDirectories = (Read-Host "Please enter target directories separated by commas").Split(',')
    )

    # Validate Root Directory
    if (-not (Test-Path $RootDirectory)) {
        Write-Error "The specified root directory ($RootDirectory) does not exist. Please ensure the path is correct."
        return
    }

    $outputArray = @()
    $outputArray += Get-DirectoryStructure $RootDirectory
    $outputArray += Get-FileContents $RootDirectory $TargetDirectories

    # Copy result to clipboard
    $outputArray -join "`r`n" | Set-Clipboard
    Write-Output "Directory structure and code contents copied to clipboard!"
}

function Get-DirectoryStructure {
    param (
        [string]$DirectoryPath
    )

    & tree /f $DirectoryPath
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
            $relativePath = $file.FullName.Replace($RootPath, '').TrimStart('\')
            $contentArray += "File: $relativePath"
            $contentArray += "--- Contents of $relativePath ---"
            $contentArray += (Get-Content $file.FullName | ForEach-Object { "    $_" })
            $contentArray += "--- End of $relativePath ---"
        }
    }

    return $contentArray
}

# Call the main function
Get-CodeContent
