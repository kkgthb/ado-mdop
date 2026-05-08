Function Test-DnsHost {
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
    Param(
        [Parameter(
            HelpMessage = 'FQDN hostname'
        )]
        [ValidateNotNullOrWhiteSpace()]
        [String[]]$HostName,
        [Parameter(
            HelpMessage = 'DNS host resolution expectation ("resolve", "nxdomain," or ... something else?)'
        )]
        [ValidateNotNullOrWhiteSpace()]
        [String[]]$Expect
    ) # end PARAM
    Begin {} # end BEGIN
    Process {
        # Note:  not my code, for the most part
        Try {
            $addrs = [System.Net.Dns]::GetHostAddresses($HostName) |
            Select-Object -ExpandProperty IPAddressToString |
            Select-Object -First 5
            $result = $addrs -join ', '
            If ($Expect -eq 'resolve') {
                [PSCustomObject]@{ Result = "✅ $HostName → $result"; Pass = 1; Fail = 0 }
            }
            Else {
                [PSCustomObject]@{ Result = "❌ $HostName resolved ($result) but expected NXDOMAIN"; Pass = 0; Fail = 1 }
            }
        }
        Catch {
            If ($Expect -eq 'nxdomain') {
                [PSCustomObject]@{ Result = "✅ $HostName → NXDOMAIN (expected)"; Pass = 1; Fail = 0 }
            }
            Else {
                [PSCustomObject]@{ Result = "❌ $HostName → NO RESOLUTION"; Pass = 0; Fail = 1 }
            }
        }
    } # end PROCESS
    End {} # end END
} # end FUNCTION