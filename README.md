# Get-CodeContent PowerShell Script
[![Lint and Test](https://github.com/kennethcarnes/Get-CodeContent/actions/workflows/lint-and-test.yml/badge.svg)](https://github.com/kennethcarnes/Get-CodeContent/actions/workflows/lint-and-test.yml)

`Get-CodeContent` is a PowerShell script that captures a code project's directory structure and file contents, then copies it to the clipboard. Ideal for sharing code projects with ChatGPT.

## Features
- Captures full directory structure
- Extracts content of specified directories
- Clipboard or file output
- Error handling and user prompts

## Quick Start

1. Clone the repo
    ```powershell
    git clone https://github.com/kennethcarnes/Get-CodeContent
    ```
2. Navigate to the script directory in PowerShell

3. Run the script and follow the prompts
    ```powershell
    .\Get-CodeContent.ps1
    ```
### Parameter Usage

You can specify parameters directly:
```powershell
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -TargetDirectories @("subfolder1", "subfolder2")
```

Use -AllDirectories to include root and all subdirectories:
```powershell
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -AllDirectories
```

By default, the script copies the output to the clipboard. If you'd like to save the results to a file instead:
```powershell
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -SaveToFile
```
Specify a custom output file with -OutputFile:
```powershell
.\Get-CodeContent.ps1 -RootDirectory "C:\path\to\root" -SaveToFile -OutputFile "desired_filename.txt"
```
## Project Overview
### Continuous Integration and Continuous Deployment (CI/CD)

Utilizing GitHub Actions, the project has a CI/CD pipeline defined in `lint-and-test.yml`. When a new version of the script is pushed to the `main` branch, automated linting and unit tests ensure the script maintains high standard of quality and functionality.
#### Linting with PSScriptAnalyzer

PSScriptAnalyzer, a static code checker for PowerShell modules and scripts will automatically scan and flag code quality issues.

#### Unit Testing with Pester
Pester, a PowerShell testing framework, validates the core functionality of the script through the `Get-CodeContent.Tests.ps1` test script.



