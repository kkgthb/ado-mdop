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
            # Write-Host "We will be writing to:  ${tempFilePath}" # DEBUG LINE ONLY
            If ([System.Environment]::GetEnvironmentVariable('IS_JUST_PESTER_TEST') -eq 'True') {
                Write-Host 'Yes, unit test, we reached this'
            }
            # Add-Content `
            #     -Path "$tempFilePath" `
            #     -Value "# Acquisition time summary"
            # Add-Content `
            #     -Path "$tempFilePath" `
            #     -Value ""
            Add-Content `
                -Path "$tempFilePath" `
                -Value "Acquisition time: ${acquisitionSec}s"
            # $pathContents = Get-Content -Path "$tempFilePath" # DEBUG LINE ONLY
            # Write-Host 'Dumping summary contents' # DEBUG LINE ONLY
            # Write-Host "$pathContents" # DEBUG LINE ONLY
            # Write-Host 'Dumped summary contents' # DEBUG LINE ONLY
            Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=AgentAcquisitionTime;]${tempFilePath}" # ADO-specific
            # Write-Host 'Allegedly uploaded summary' # DEBUG LINE ONLY
            If ([System.Environment]::GetEnvironmentVariable('IS_JUST_PESTER_TEST') -eq 'True') {
                Remove-Item -Path "$tempFilePath" -Force -ErrorAction 'SilentlyContinue'
                # Write-Host 'Removed summary file' # DEBUG LINE ONLY
            }
        }
    } # end PROCESS
    End {} # end END
} # end FUNCTION