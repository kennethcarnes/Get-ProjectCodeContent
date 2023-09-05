# Get-CodeContent.Tests.ps1

# Use BeforeAll to set up preconditions for tests
# Import the PowerShell script containing the function to be tested by dot-sourcing it.
BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

# Test suite for Get-CodeContent
Describe "Get-CodeContent" {

    # Group for basic tests
    Context "Basic Tests" {

        # Test: Should error for non-existing directory
        It "Should return an error for a non-existing directory" {
            { Get-CodeContent -RootDirectory "C:\NonExistingDirectory" -ErrorAction Stop } | Should -Throw "The specified root directory does not exist."
        }

        # Test: Should not error for existing directory
        It "Should not throw an error for an existing directory" {
            { Get-CodeContent -RootDirectory "C:\Test-RootDirectory" -ErrorAction Stop } | Should -Not -Throw
        }
    }

    # Group for advanced tests
    Context "Advanced Tests" {

        # Test: Should throw an error if no target directories are specified and -AllDirectories is not set
        It "Should throw an error for no target directories" {
            { Get-CodeContent -RootDirectory "C:\Test-RootDirectory" -TargetDirectories @() -ErrorAction Stop } | Should -Throw "You must specify at least one target directory or use -AllDirectories switch."
        }

        # Test: Should not throw an error if -AllDirectories is set
        It "Should not throw an error for -AllDirectories" {
            { Get-CodeContent -RootDirectory "C:\Test-RootDirectory" -AllDirectories -ErrorAction Stop } | Should -Not -Throw
        }
    }
}
