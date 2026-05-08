BeforeAll {
    Remove-Item 'Function:Test-DnsResolution' `
        -ErrorAction 'SilentlyContinue'
    . "$PSScriptRoot\..\..\Public\Test-DnsResolution.ps1"
}

Describe "Test-DnsResolution" {

    BeforeEach {
        [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', $null)
        [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null)
    }

    AfterEach {
        [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', $null)
        [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null)
    }

    Context "IS_JUST_PESTER_TEST marker" {
        It "writes the generic unit-test marker when IS_JUST_PESTER_TEST is True" {
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True')
            $output = Test-DnsResolution 6>&1 | ForEach-Object { "$_" }
            $output | Should -Contain 'Yes, unit test, we reached this generic block'
        }

        It "does not write the generic unit-test marker when IS_JUST_PESTER_TEST is not set" {
            $output = Test-DnsResolution 6>&1 | ForEach-Object { "$_" }
            $output | Should -Not -Contain 'Yes, unit test, we reached this generic block'
        }
    }

    Context "TF_BUILD + IS_JUST_PESTER_TEST marker" {
        It "writes the ADO-specific marker when both TF_BUILD and IS_JUST_PESTER_TEST are True" {
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', 'True')
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True')
            $output = Test-DnsResolution -ADOAgentTempDirectoryPath ([System.IO.Path]::GetTempPath()) 6>&1 | ForEach-Object { "$_" }
            $output | Should -Contain 'Yes, unit test, we reached this ADO-specific block'
        }

        It "does not write the ADO-specific marker when IS_JUST_PESTER_TEST is True but TF_BUILD is not set" {
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True')
            $output = Test-DnsResolution 6>&1 | ForEach-Object { "$_" }
            $output | Should -Not -Contain 'Yes, unit test, we reached this ADO-specific block'
        }
    }

    Context "DNS result output" {
        It "always writes a pass/fail summary line to host" {
            $output = Test-DnsResolution 6>&1 | ForEach-Object { "$_" }
            $output | Where-Object { $_ -match 'DNS Results: \d+ passed, \d+ failed' } | Should -Not -BeNullOrEmpty
        }

        It "writes at least one result line for an FQDN to host" {
            $output = Test-DnsResolution 6>&1 | ForEach-Object { "$_" }
            $output | Where-Object { $_ -match '(✅|❌).+\.' } | Should -Not -BeNullOrEmpty
        }
    }

    Context "ADO temp file lifecycle" {
        It "cleans up the temp summary file when IS_JUST_PESTER_TEST is True" {
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', 'True')
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True')
            $tempDir = [System.IO.Path]::GetTempPath()
            $expectedFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($tempDir, 'tempTestDnsResolutionSummary.md'))
            Test-DnsResolution -ADOAgentTempDirectoryPath $tempDir 6>&1 | Out-Null
            Test-Path $expectedFile | Should -BeFalse
        }

        It "writes the vso attachment command to host when TF_BUILD is True" {
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', 'True')
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True')
            $tempDir = [System.IO.Path]::GetTempPath()
            $output = Test-DnsResolution -ADOAgentTempDirectoryPath $tempDir 6>&1 | ForEach-Object { "$_" }
            $output | Where-Object { $_ -match '##vso\[task\.addattachment.+DnsResolution' } | Should -Not -BeNullOrEmpty
        }
    }

}

AfterAll {
    Remove-Item 'Function:Test-DnsResolution' `
        -ErrorAction 'SilentlyContinue'
}
