# Get-ProjectCodeContent.Tests.ps1

Describe "Get-ProjectCodeContent" {

    BeforeAll {
        # Ensure the main script exists in the same directory as the test script
        $mainScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Get-ProjectCodeContent.ps1"
        if (-Not (Test-Path -Path $mainScriptPath)) {
            throw "Main script 'Get-ProjectCodeContent.ps1' not found in the directory $PSScriptRoot"
        }
        # Load the main script
        . "$mainScriptPath"

        # Set up test directory structure
        $testRoot = Join-Path -Path (Get-Location) -ChildPath "Test-Get-ProjectCodeContent"

        # Remove existing test directory structure if it exists
        if (Test-Path -Path $testRoot) {
            Write-Verbose "Removing existing test directory structure at $testRoot"
            Remove-Item -Path $testRoot -Recurse -Force
        }

        # Create test directory structure
        Write-Verbose "Creating test directory structure at $testRoot"
        New-Item -ItemType Directory -Path $testRoot -Force
        New-Item -ItemType Directory -Path "$testRoot\subfolder1" -Force
        New-Item -ItemType Directory -Path "$testRoot\subfolder2" -Force
        New-Item -ItemType Directory -Path "$testRoot\.github" -Force
        New-Item -ItemType Directory -Path "$testRoot\node_modules" -Force

        # Create test files in the test directory structure
        New-Item -ItemType File -Path "$testRoot\file1.txt" -Force | Set-Content -Value "This is file 1"
        New-Item -ItemType File -Path "$testRoot\subfolder1\file2.txt" -Force | Set-Content -Value "This is file 2"
        New-Item -ItemType File -Path "$testRoot\subfolder2\file3.txt" -Force | Set-Content -Value "This is file 3"
        New-Item -ItemType File -Path "$testRoot\.github\file4.txt" -Force | Set-Content -Value "This is file 4"
        New-Item -ItemType File -Path "$testRoot\node_modules\file5.txt" -Force | Set-Content -Value "This is file 5"

        # Verify that the test directory structure was created successfully
        if (-Not (Test-Path -Path $testRoot)) {
            Write-Error "Test directory was not created successfully."
        } else {
            Write-Verbose "Test directory structure created successfully at $testRoot"
        }
    }

    AfterAll {
        # Remove the test directory structure after tests are complete
        if (Test-Path -Path $testRoot) {
            Write-Verbose "Removing test directory structure at $testRoot"
            Remove-Item -Path $testRoot -Recurse -Force
        }
    }

    # Test: Ensure both the main script and the test script are in the same directory
    It "Should find the main script in the same directory" {
        $mainScriptPath | Should -BeExactly "$PSScriptRoot\Get-ProjectCodeContent.ps1"
    }

    # Test: Should exclude specified directories
    It "Should exclude specified directories" {
        $output = Get-ProjectCodeContent -RootDirectory $testRoot -ExcludeDirectories @(".github", "node_modules") -ReturnOutput
        Write-Verbose "Output after exclusion test: $($output -join '`n')"
        $output | Should -Not -Contain "--- Contents of .github\file4.txt ---"
        $output | Should -Not -Contain "--- Contents of node_modules\file5.txt ---"
    }

    # Test: Should include files in the root directory
    It "Should include files in the root directory" {
        $output = Get-ProjectCodeContent -RootDirectory $testRoot -ReturnOutput
        Write-Verbose "Output after root directory test: $($output -join '`n')"
        $output | Should -Contain "--- Contents of file1.txt ---"
    }

    # Test: Should include files in subdirectories
    It "Should include files in subdirectories" {
        $output = Get-ProjectCodeContent -RootDirectory $testRoot -ReturnOutput
        Write-Verbose "Output after subdirectory test: $($output -join '`n')"
        $output | Should -Contain "--- Contents of subfolder1\file2.txt ---"
        $output | Should -Contain "--- Contents of subfolder2\file3.txt ---"
    }
}
