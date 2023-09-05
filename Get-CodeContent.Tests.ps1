# Get-CodeContent.Tests.ps1

# Use BeforeAll to set up preconditions for tests
# Import the PowerShell script containing the function to be tested by dot-sourcing it.
BeforeAll {
    . $PSScriptRoot\Get-CodeContent.ps1
}

# Test suite for Get-CodeContent
Describe "Get-CodeContent" {

    # Test: Should error for non-existing directory
    It "Should return an error for a non-existing directory" {
        { Get-CodeContent -RootDirectory "C:\NonExistingDirectory" -ErrorAction Stop } | Should -Throw "The specified root directory (*NonExistingDirectory) does not exist.*"
    }


    # Test: Should not error for existing directory
    It "Should not throw an error for an existing directory" {
        { Get-CodeContent -RootDirectory "C:\Test-RootDirectory" -ErrorAction Stop } | Should -Not -Throw
    }

    # Test: Should error for not specifying the root directory
    It "Should throw an error for not specifying the root directory" {
        { Get-CodeContent -ErrorAction Stop } | Should -Throw "RootDirectory is a required parameter"
    }
}
