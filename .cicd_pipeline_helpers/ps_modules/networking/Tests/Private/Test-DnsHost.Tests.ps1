BeforeAll {
    Remove-Item 'Function:Test-DnsHost' `
        -ErrorAction 'SilentlyContinue'
    . "$PSScriptRoot\..\..\Private\Test-DnsHost.ps1"
}

Describe "Test-DnsHost" {

    Context "When the hostname resolves successfully" {
        It "increments pass and appends a success entry when Expect is 'resolve'" {
            $r = Test-DnsHost -HostName 'localhost' -Expect 'resolve'
            $r.Pass | Should -Be 1
            $r.Fail | Should -Be 0
            $r.Result | Should -Match '✅ localhost →'
        }

        It "resolve gets validated with a remote fqdn as well (presuming test is run un-firewalled)" {
            $r = Test-DnsHost -HostName 'www.google.com' -Expect 'resolve'
            $r.Pass | Should -Be 1
            $r.Fail | Should -Be 0
            $r.Result | Should -Match '✅ www.google.com →'
        }

        It "increments fail and appends an error entry when Expect is 'nxdomain'" {
            $r = Test-DnsHost -HostName 'localhost' -Expect 'nxdomain'
            $r.Pass | Should -Be 0
            $r.Fail | Should -Be 1
            $r.Result | Should -Match '❌ localhost resolved .+ but expected NXDOMAIN'
        }
    }

    Context "When the hostname does not resolve" {
        It "increments pass and appends a success entry when Expect is 'nxdomain'" {
            $r = Test-DnsHost -HostName 'this-host-definitely-does-not-exist.invalid' -Expect 'nxdomain'
            $r.Pass | Should -Be 1
            $r.Fail | Should -Be 0
            $r.Result | Should -Match '✅ .+ → NXDOMAIN \(expected\)'
        }

        It "increments fail and appends an error entry when Expect is 'resolve'" {
            $r = Test-DnsHost -HostName 'this-host-definitely-does-not-exist.invalid' -Expect 'resolve'
            $r.Pass | Should -Be 0
            $r.Fail | Should -Be 1
            $r.Result | Should -Match '❌ .+ → NO RESOLUTION'
        }
    }
}

AfterAll {
    Remove-Item 'Function:Test-DnsHost' `
        -ErrorAction 'SilentlyContinue'
}
