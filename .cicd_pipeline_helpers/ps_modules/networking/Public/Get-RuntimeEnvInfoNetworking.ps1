Function Get-RuntimeEnvInfoNetworking {
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
    Param () # end PARAM
    Begin {} # end BEGIN
    Process {
        # Note:  not my code, for Linux, and LLM-generated for Windows
        Write-Host "~~~BEGIN:  System Info~~~"
        Write-Host "Hostname:  $([System.Net.Dns]::GetHostName())"
        Write-Host "Runner OS: $([System.Environment]::GetEnvironmentVariable('RUNNER_OS'))"
        $imageOs = [System.Environment]::GetEnvironmentVariable('ImageOS') ?? 'unknown'
        $imageVer = [System.Environment]::GetEnvironmentVariable('ImageVersion') ?? 'unknown'
        Write-Host "Image:     $imageOs $imageVer"
        If ([System.OperatingSystem]::IsLinux()) {
            uname -a
        }
        If ([System.OperatingSystem]::IsWindows()) {
            Get-ComputerInfo | Select-Object *
        }
        Write-Host "~~~END:  System Info~~~"

        Write-Host "~~~BEGIN:  Network Interfaces~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            ip -4 addr show
        }
        If ([System.OperatingSystem]::IsWindows()) {
            # List active interface IPv4 configurations
            Get-NetIPConfiguration
            # List all IPv4 addresses
            Get-NetIPAddress -AddressFamily 'IPv4' | Format-Table -AutoSize
        }
        Write-Host "~~~END:  Network Interfaces~~~"

        Write-Host "~~~BEGIN:  IPv6 Interfaces~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            ip -6 addr show 2>$null
            if ($LASTEXITCODE -ne 0) { Write-Host "IPv6 not available" }
        }
        If ([System.OperatingSystem]::IsWindows()) {
            # List all IPv6 addresses
            Get-NetIPAddress -AddressFamily 'IPv6' | Format-Table -AutoSize
        }
        Write-Host "~~~END:  IPv6 Interfaces~~~"

        Write-Host "~~~BEGIN:  DNS Configuration~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            Get-Content /etc/resolv.conf
        }
        If ([System.OperatingSystem]::IsWindows()) {
            [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() | 
            Where-Object { $_.OperationalStatus -eq 'Up' } | 
            ForEach-Object {
                $name = $_.Name
                $dnsServers = $_.GetIPProperties().DnsAddresses
                if ($dnsServers) {
                    Write-Host "Interface: $name"
                    $dnsServers | ForEach-Object { Write-Host "  DNS Server: $_" }
                }
            }
        }
        Write-Host "~~~END:  DNS Configuration~~~"

        Write-Host "~~~BEGIN:  Routing Table~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            ip route show
        }
        If ([System.OperatingSystem]::IsWindows()) {
            Get-NetRoute | 
            Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias | 
            Format-Table -AutoSize
        }
        Write-Host "~~~END:  Routing Table~~~"

        Write-Host "~~~BEGIN:  Default Gateway~~~"
        Try {
            If ([System.OperatingSystem]::IsLinux()) {
                ip route get 8.8.8.8 2>$null
            }
            If ([System.OperatingSystem]::IsWindows()) {
                # Windows: Finds the specific route used to reach a destination
                $route = Get-NetRoute -DestinationPrefix "8.8.8.8" -ErrorAction SilentlyContinue
                if ($null -eq $route) { 
                    # Fallback to general default route if specific one isn't found
                    $route = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop 
                }
                Write-Host "Next Hop to 8.8.8.8: $($route.NextHop)"
            }
        }
        Catch { 
            Write-Host "No route to 8.8.8.8"
        }
        Write-Host "~~~END:  Default Gateway~~~"

        Write-Host "~~~BEGIN:  ARP Table~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            ip neigh show
        }
        If ([System.OperatingSystem]::IsWindows()) {
            # Windows modern cmdlet (replaces 'arp -a')
            # Filter to 'Unreachable' or 'Permanent' if you want specific states
            Get-NetNeighbor -AddressFamily IPv4 | 
            Select-Object IPAddress, LinkLayerAddress, State, InterfaceAlias | 
            Format-Table -AutoSize
        }
        Write-Host "~~~END:  ARP Table~~~"

        Write-Host "~~~BEGIN:  Listening Ports~~~"
        If ([System.OperatingSystem]::IsLinux()) {
            ss -tlnp 2>$null
            if ($LASTEXITCODE -ne 0) {
                netstat -tlnp 2>$null
                if ($LASTEXITCODE -ne 0) { Write-Host "Cannot list ports" }
            }
        }
        If ([System.OperatingSystem]::IsWindows()) {
            # Windows native: Filters for listening state and includes Process ID
            Get-NetTCPConnection -State Listen | 
            Select-Object LocalAddress, LocalPort, OwningProcess | 
            Sort-Object LocalPort | Format-Table -AutoSize
            Write-Host "~~~END:  Listening Ports~~~"
        }
    } # end PROCESS
    End {} # end END
} # end FUNCTION