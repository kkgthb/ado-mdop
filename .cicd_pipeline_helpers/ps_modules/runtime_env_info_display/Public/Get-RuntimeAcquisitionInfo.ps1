Function Get-RuntimeAcquisitionInfo {
    <#
    .Synopsis
        TODO
    .DESCRIPTION
        TODO
    .NOTES
        Author: Katie Kodes (and peers)
        Date: 2026-05-08
        Company: Katie Kodes
    #>
    [CmdletBinding()]
    Param (
        [Parameter(
            HelpMessage = 'The time at which the CI/CD pipeline started (for ADO, should be the "$(System.PipelineStartTime)" YAML variable)'
        )]
        [ValidateNotNullOrWhiteSpace()]
        [String[]]$CicdPipelineStartTime,

        [Parameter(
            HelpMessage = 'The ADO "temp directory" folder path (for ADO, should be the "$(Agent.TempDirectory)" YAML variable)'
        )]
        [String[]]$ADOAgentTempDirectoryPath
        
    ) # end PARAM
    Begin {} # end BEGIN
    Process {
        $firstStepAt = [System.DateTime]::UtcNow
        $pipelineStart = [System.DateTime]::Parse($CicdPipelineStartTime)
        $acquisitionSec = [Math]::Round(($firstStepAt - $pipelineStart).TotalSeconds, 1)
        Write-Host "Pipeline started: $($pipelineStart.ToString('HH:mm:ss')) UTC"
        Write-Host "First step at:    $($firstStepAt.ToString('HH:mm:ss')) UTC"
        Write-Host "Acquisition time: ${acquisitionSec}s"
        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            # Credit:  https://stackoverflow.com/a/77511799
            $tempFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ADOAgentTempDirectoryPath, "temp.md"))
            Write-Host 'Yes, unit test, we reached this'
            Add-Content `
                -Path "$tempFilePath" `
                -Value "Acquisition time: ${acquisitionSec}s"
            Write-Host "##vso[task.uploadsummary]${tempFilePath}" # ADO-specific
            Remove-Item -Path "$tempFilePath" -Force -ErrorAction 'SilentlyContinue'
        }
    } # end PROCESS
    End {} # end END
} # end FUNCTION