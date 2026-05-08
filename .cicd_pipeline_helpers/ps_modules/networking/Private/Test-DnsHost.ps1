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
                $script:results += "✅ $HostName → $result"
                $script:pass++
            }
            Else {
                $script:results += "❌ $HostName resolved ($result) but expected NXDOMAIN"
                $script:fail++
            }
        }
        Catch {
            If ($Expect -eq 'nxdomain') {
                $script:results += "✅ $HostName → NXDOMAIN (expected)"
                $script:pass++
            }
            Else {
                $script:results += "❌ $HostName → NO RESOLUTION"
                $script:fail++
            }
        }
    } # end PROCESS
    End {} # end END
} # end FUNCTION