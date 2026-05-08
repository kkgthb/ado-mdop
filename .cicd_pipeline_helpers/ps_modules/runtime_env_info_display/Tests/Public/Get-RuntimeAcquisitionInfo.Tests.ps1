BeforeAll {
    [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
    Remove-Item 'Function:Get-RuntimeAcquisitionInfo' `
        -ErrorAction 'SilentlyContinue'
    . "$PSScriptRoot\..\..\Public\Get-RuntimeAcquisitionInfo.ps1"
    Mock -CommandName Write-Host -ParameterFilter {
        $Object -eq 'Yes, unit test, we reached this'
    }
}

Describe "Get-RuntimeAcquisitionInfo" {

    It "should output 'Acquisition time' to the host" {
        $output = Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | Out-String
        $output | Should -Match "Acquisition time"
    }

    It "should have a small gap with a short-ago start time" {
        $output = Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | Out-String
        $output | Should -Match 'Acquisition time: \d{1}\.\d+?s' # 0.something
    }

    It "should have a small gap with a short-ago start time" {
        $output = Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String](([DateTime]::UtcNow).AddMinutes(-30)))" 6>&1 | Out-String
        $output | Should -Match 'Acquisition time: \d{4}\.\d+?' # 1800.something
    }

    It "should not write any greeting to the unit test if outside ADO" {
        Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | Out-Null
        Assert-MockCalled -CommandName 'Write-Host' -Exactly 0 -ParameterFilter {
            $Object -eq 'Yes, unit test, we reached this'
        }
    }

    Describe "trigger ADO-specific branch" {
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', 'True', 'Process')
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', 'True', 'Process')
        }
        It "should write a greeting to the unit test if running in ADO" {
            Get-RuntimeAcquisitionInfo `
                -ADOAgentTempDirectoryPath "$PSScriptRoot" `
                -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | 
            Out-Null
            Assert-MockCalled -CommandName 'Write-Host' -Exactly 1 -ParameterFilter {
                $Object -eq 'Yes, unit test, we reached this'
            }
        }
        AfterEach {
            [System.Environment]::SetEnvironmentVariable('IS_JUST_PESTER_TEST', $null, 'Process')
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
        }
    }
}
AfterAll {
    Remove-Item 'Function:Get-RuntimeAcquisitionInfo' `
        -ErrorAction 'SilentlyContinue'
    [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
}
