Describe "Get-CodeContent" {
    Context "Basic Tests" {
        It "Should return an error for a non-existing directory" {
            { Get-CodeContent -RootDirectory "C:\NonExistingDirectory" } | Should -Throw
        }

        It "Should not throw an error for an existing directory" {
            { Get-CodeContent -RootDirectory "C:\Test-RootDirectory" } | Should -Not -Throw
        }
    }
}
