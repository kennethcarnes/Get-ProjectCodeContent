function Get-ProjectCodeContent {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RootDirectory,  # The root directory to scan

        [string[]]$ExcludeDirectories = @(),  # Directories to exclude from the scan

        [switch]$ReturnOutput  # Switch to return output instead of setting clipboard content
    )

    process {
        try {
            # Resolve the RootDirectory to ensure it's an absolute path
            $resolvedRootDirectory = Resolve-Path -Path $RootDirectory -ErrorAction Stop
            Write-Verbose "Resolved root directory: $resolvedRootDirectory"

            # Check if the RootDirectory exists
            if (-not (Test-Path -Path $resolvedRootDirectory -PathType Container)) {
                throw [System.IO.DirectoryNotFoundException] "The specified root directory '$resolvedRootDirectory' does not exist. Please ensure the path is correct."
            }

            # Initialize an array to hold output
            $outputArray = @()

            # Get and store the tree structure
            Write-Verbose "Capturing directory structure..."
            $treeOutput = & tree /f $resolvedRootDirectory 2>&1 | Select-Object -Skip 2
            $outputArray += "File and Folder Structure"
            $outputArray += $treeOutput
            Write-Verbose "Directory structure captured."

            # Process directories
            Write-Verbose "Processing directories..."
            $allDirs = Get-ChildItem -Path $resolvedRootDirectory -Recurse -Directory | ForEach-Object { $_.FullName }
            Write-Verbose "All directories: $($allDirs -join ', ')"

            # Include the root directory and exclude specified directories
            $dirsToProcess = @($resolvedRootDirectory) + ($allDirs | Where-Object {
                $dirName = if ($_.Length -gt $resolvedRootDirectory.Length) {
                    $_.Substring($resolvedRootDirectory.Length).TrimStart('\')
                } else {
                    $_
                }
                $exclude = $false
                foreach ($excl in $ExcludeDirectories) {
                    if ($dirName -like "*$excl*") {
                        $exclude = $true
                        break
                    }
                }
                Write-Verbose "Checking directory: $_, Result: $(! $exclude)"
                -not $exclude
            })

            Write-Verbose "Directories to process: $($dirsToProcess -join ', ')"

            if ($dirsToProcess.Count -gt 0) {
                $fileContents = Get-FileContent -RootPath $resolvedRootDirectory -Directories $dirsToProcess -ExcludeDirectories $ExcludeDirectories
                $outputArray += $fileContents
            } else {
                Write-Warning "No directories to process after exclusion."
            }

            # Log output array
            Write-Verbose "Output array before returning or setting clipboard: $($outputArray -join '`r`n')"

            # Return or copy output
            if ($ReturnOutput) {
                return $outputArray
            } else {
                Write-Verbose "Setting clipboard content."
                Set-Clipboard -Value ($outputArray -join "`r`n")
                Write-Output "Clipboard content set successfully."  # Confirming clipboard setting
                Write-Verbose "Clipboard content set to: $($outputArray -join '`r`n')"
            }
        } catch {
            Write-Error "An error occurred: $_"
            throw $_
        }
    }
}

function Get-FileContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RootPath,  # The root path to scan

        [Parameter(Mandatory=$true)]
        [string[]]$Directories,  # Directories to include in the scan

        [string[]]$ExcludeDirectories = @()  # Directories to exclude from the scan
    )

    # Initialize an array to hold file content
    $contentArray = @()

    # Iterate through each directory
    foreach ($dir in $Directories) {
        $fullDirPath = $dir
        Write-Verbose "Processing directory: $fullDirPath"
        if (-not (Test-Path -Path $fullDirPath -PathType Container)) {
            Write-Warning "Directory '$fullDirPath' does not exist. Skipping..."
            continue
        }
        $files = Get-ChildItem -Path $fullDirPath -Recurse -File | Where-Object {
            $fileDirName = if ($_.DirectoryName.Length -gt $RootPath.Length) {
                $_.DirectoryName.Substring($RootPath.Length).TrimStart('\')
            } else {
                $_.DirectoryName
            }
            $excludeFile = $false
            foreach ($excl in $ExcludeDirectories) {
                if ($fileDirName -like "*$excl*") {
                    $excludeFile = $true
                    break
                }
            }
            Write-Verbose "Checking file: $($_.FullName), Result: $(! $excludeFile)"
            -not $excludeFile
        }

        # Iterate through each file in the directory
        foreach ($file in $files) {
            try {
                $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\')

                # Add content of each file to the array
                $contentArray += ""
                $contentArray += "--- Contents of $relativePath ---"
                $contentArray += (Get-Content -Path $file.FullName | ForEach-Object { "    $_" })
                $contentArray += "--- End of $relativePath ---"
                Write-Verbose "Processed file: $($file.FullName)"
            } catch {
                Write-Error "Could not read the contents of '$file'. Error: $_"
                continue
            }
        }
    }

    return $contentArray
}
