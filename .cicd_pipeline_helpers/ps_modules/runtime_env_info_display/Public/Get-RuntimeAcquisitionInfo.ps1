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
        [String[]]$CicdPipelineStartTime
    ) # end PARAM
    Begin {} # end BEGIN
    Process {
        $firstStepAt = [System.DateTime]::UtcNow
        $pipelineStart = [System.DateTime]::Parse($CicdPipelineStartTime)
        $acquisitionSec = [Math]::Round(($firstStepAt - $pipelineStart).TotalSeconds, 1)
        Write-Host "Pipeline started: $($pipelineStart.ToString('HH:mm:ss')) UTC"
        Write-Host "First step at:    $($firstStepAt.ToString('HH:mm:ss')) UTC"
        Write-Host "Acquisition time: ${acquisitionSec}s"
    } # end PROCESS
    End {} # end END
} # end FUNCTION