# Get-CodeContent PowerShell Script
## Description

The `Get-CodeContent` function captures the entire directory structure of a given root directory and also extracts the content of files within specified target directories. The results are conveniently copied to the clipboard for easy sharing.

## Features

- Outputs the entire directory structure of the provided root directory.
- Displays content of files within specified target directories relative to the root.
- Copies the result to the clipboard for easy sharing and pasting.

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

3. The script will then copy the directory structure and code content to your clipboard. You can paste it anywhere you need!

### With Parameters

To bypass the interactive prompts and directly provide the parameters:

```powershell
.\path_to_your_script.ps1 -RootDirectory "C:\code\azure-swa" -TargetDirectories @("infra", ".github")
```

## Acknowledgements

Thanks to OpenAI's GPT-4 for assistance in creating this utility.
