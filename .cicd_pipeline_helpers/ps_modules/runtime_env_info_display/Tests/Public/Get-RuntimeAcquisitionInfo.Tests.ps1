BeforeAll {
    [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
    [System.Environment]::SetEnvironmentVariable('AGENT_BUILDSUMMARYFILE', $null, 'Process')
    Remove-Item 'Function:Get-RuntimeAcquisitionInfo' `
        -ErrorAction 'SilentlyContinue'
    . "$PSScriptRoot\..\..\Public\Get-RuntimeAcquisitionInfo.ps1"
    Mock Add-Content {} 
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

    It "should not run add-content if outside ADO" {
        Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | Out-Null
        Should -Not -Invoke 'Add-Content'
    }

    Describe "trigger add-content" {
        BeforeEach {
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', 'True', 'Process')
            [System.Environment]::SetEnvironmentVariable('AGENT_BUILDSUMMARYFILE', 'does_not_matter', 'Process')
        }
        It "should run add-content if running in ADO" {
            Get-RuntimeAcquisitionInfo -CicdPipelineStartTime "$([String]([DateTime]::UtcNow))" 6>&1 | Out-Null
            Should -Invoke 'Add-Content'
        }
        AfterEach {
            [System.Environment]::SetEnvironmentVariable('AGENT_BUILDSUMMARYFILE', $null, 'Process')
            [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
        }
    }
}
AfterAll {
    Remove-Item 'Function:Get-RuntimeAcquisitionInfo' `
        -ErrorAction 'SilentlyContinue'
    [System.Environment]::SetEnvironmentVariable('AGENT_BUILDSUMMARYFILE', $null, 'Process')
    [System.Environment]::SetEnvironmentVariable('TF_BUILD', $null, 'Process')
}
