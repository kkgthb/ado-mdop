Function Test-DnsResolution {
    <#
    .Synopsis
        TODO
    .DESCRIPTION
        TODO
    .NOTES
        Author: Katie Kodes
        Date: 2026-05-08
        Company: Katie Kodes
    #>
    [CmdletBinding()]
    Param (
        [Parameter(
            HelpMessage = 'The ADO "temp directory" folder path (for ADO, should be the "$(Agent.TempDirectory)" YAML variable)'
        )]
        [String[]]$ADOAgentTempDirectoryPath
    ) # end PARAM
    Begin {
        Remove-Item 'Function:Test-DnsHost' -ErrorAction 'SilentlyContinue' # TODO:  clean up later
        . "$(Split-Path -Parent $MyInvocation.MyCommand.ScriptBlock.File)\..\Private\Test-DnsHost.ps1" # TODO:  clean up later
        $externalResolveExpectsByFqdnWhileNotFirewalled = [PSCustomObject]@{
            'dev.azure.com'  = 'resolve'
            'www.google.com' = 'resolve'
        }
        $externalResolveExpectsByFqdnWhileFirewalled = [PSCustomObject]@{
            'dev.azure.com'  = 'resolve'
            'www.google.com' = 'resolve'
        }
    } # end BEGIN
    Process {
        # Note:  not my code, for the most part
        $tempFilePath = $null
        If ([System.Environment]::GetEnvironmentVariable('IS_JUST_PESTER_TEST') -eq 'True') {
            Write-Host 'Yes, unit test, we reached this generic block'
        }
        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            If ([System.Environment]::GetEnvironmentVariable('IS_JUST_PESTER_TEST') -eq 'True') {
                Write-Host 'Yes, unit test, we reached this ADO-specific block'
            }
        }
        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            $tempFilePath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($ADOAgentTempDirectoryPath, "tempTestDnsResolutionSummary.md"))
            # Write-Host "We will be writing to:  ${tempFilePath}" # DEBUG LINE ONLY
        }

        $pass = 0; $fail = 0
        $results = @()

        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            Add-Content `
                -Path "$tempFilePath" `
                -Value '## DNS Resolution Tests'
            Add-Content `
                -Path "$tempFilePath" `
                -Value ''
        }

        # Allowed FQDNs must resolve
        ForEach ($prop In $externalResolveExpectsByFqdnWhileNotFirewalled.PSObject.Properties) {
            $r = Test-DnsHost -HostName $prop.Name -Expect $prop.Value
            $results += $r.Result
            $pass += $r.Pass
            $fail += $r.Fail
        }
      
        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            Add-Content `
                -Path "$tempFilePath" `
                -Value '| Test | Result |'
            Add-Content `
                -Path "$tempFilePath" `
                -Value '|------|--------|'
            ForEach ($r In $results) {
                Add-Content `
                    -Path "$tempFilePath" `
                    -Value "| $r |"
            }
            Add-Content `
                -Path "$tempFilePath" `
                -Value ''
            Add-Content `
                -Path "$tempFilePath" `
                -Value "**DNS: $pass passed, $fail failed**"
        }
        Write-Host ""
        $results | ForEach-Object { Write-Host $_ }
        Write-Host ""
        Write-Host "DNS Results: $pass passed, $fail failed"


        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            Write-Host "##vso[task.addattachment type=Distributedtask.Core.Summary;name=DnsResolution;]${tempFilePath}" # ADO-specific
            # Write-Host 'Allegedly uploaded summary' # DEBUG LINE ONLY
        }
        If ([System.Environment]::GetEnvironmentVariable('TF_BUILD') -eq 'True') {
            If ([System.Environment]::GetEnvironmentVariable('IS_JUST_PESTER_TEST') -eq 'True') {
                Remove-Item -Path "$tempFilePath" -Force -ErrorAction 'SilentlyContinue'
                # Write-Host 'Removed summary file' # DEBUG LINE ONLY
            }
        }
    } # end PROCESS
    End {
        Remove-Item 'Function:Test-DnsHost' -ErrorAction 'SilentlyContinue' # TODO:  clean up later
    } # end END
} # end FUNCTION