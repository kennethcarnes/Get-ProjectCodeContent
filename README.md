# Get-CodeContent PowerShell Script
## Description

The `Get-CodeContent` function captures the entire directory structure of a given root directory and also extracts the content of files within specified target directories. The results are conveniently copied to the clipboard for easy sharing.

## Features

- Outputs the entire directory structure of the provided root directory.
- Displays content of files within specified target directories relative to the root.
- Copies the result to the clipboard for easy pasting and sharing.
- Provides useful error messages for easier troubleshooting when reading file contents.
- Requires the user to specify at least one target directory.

## Installation

1. Clone this repository or download the PowerShell script.
   ```powershell
   git clone https://github.com/kennethcarnes/Get-CodeContent
   ```

2. Open PowerShell in the directory containing the script.

3. If needed, modify execution policy to allow the script to run:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## Usage

### Interactive

1. Execute the PowerShell script:
   ```bash
   .\path_to_your_script.ps1
   ```

2. Follow the on-screen prompts:
   - Enter the root directory path (e.g., `C:\code\azure-swa`).
   - Enter target directories relative to the root (e.g., `infra,.github`).
   - You must specify at least one target directory for the script to proceed. Leaving this blank will result in an error message.
   - If your target directories have spaces or special characters, enclose each directory name in quotes: `"folder one","folder two"`

3. The script will then copy the directory structure and code content to your clipboard. You can paste it anywhere you need!

### With Parameters

To bypass the interactive prompts and directly provide the parameters:

```powershell
.\path_to_your_script.ps1 -RootDirectory "C:\path\to\root" -TargetDirectories @("folder1", "folder2")
```

### `-AllDirectories` Switch
When the `-AllDirectories` switch is used, the script will ignore the `TargetDirectories` parameter and automatically include all directories under the `RootDirectory` for content extraction.


To use the `-AllDirectories` switch:
```powershell
.\path_to_your_script.ps1 -RootDirectory "C:\path\to\root" -AllDirectories
```
