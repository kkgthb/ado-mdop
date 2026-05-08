BeforeAll {
    Import-Module ([IO.Path]::Combine($PSScriptRoot, '..', '..')) `
        -Scope 'Local' `
        -Force
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
}
