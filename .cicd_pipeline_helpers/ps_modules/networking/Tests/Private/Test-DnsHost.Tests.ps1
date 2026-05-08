BeforeAll {
    Remove-Item 'Function:Test-DnsHost' `
        -ErrorAction 'SilentlyContinue'
    . "$PSScriptRoot\..\..\Private\Test-DnsHost.ps1"
}

Describe "Test-DnsHost" {

    BeforeEach {
        $script:results = @()
        $script:pass = 0
        $script:fail = 0
    }

    Context "When the hostname resolves successfully" {
        It "increments pass and appends a success entry when Expect is 'resolve'" {
            Test-DnsHost -HostName 'localhost' -Expect 'resolve'
            $script:pass | Should -Be 1
            $script:fail | Should -Be 0
            $script:results[0] | Should -Match '✅ localhost →'
        }

        It "resolve gets validated with a remote fqdn as well (presuming test is run un-firewalled)" {
            Test-DnsHost -HostName 'www.google.com' -Expect 'resolve'
            $script:pass | Should -Be 1
            $script:fail | Should -Be 0
            $script:results[0] | Should -Match '✅ www.google.com →'
        }

        It "increments fail and appends an error entry when Expect is 'nxdomain'" {
            Test-DnsHost -HostName 'localhost' -Expect 'nxdomain'
            $script:pass | Should -Be 0
            $script:fail | Should -Be 1
            $script:results[0] | Should -Match '❌ localhost resolved .+ but expected NXDOMAIN'
        }
    }

    Context "When the hostname does not resolve" {
        It "increments pass and appends a success entry when Expect is 'nxdomain'" {
            Test-DnsHost -HostName 'this-host-definitely-does-not-exist.invalid' -Expect 'nxdomain'
            $script:pass | Should -Be 1
            $script:fail | Should -Be 0
            $script:results[0] | Should -Match '✅ .+ → NXDOMAIN \(expected\)'
        }

        It "increments fail and appends an error entry when Expect is 'resolve'" {
            Test-DnsHost -HostName 'this-host-definitely-does-not-exist.invalid' -Expect 'resolve'
            $script:pass | Should -Be 0
            $script:fail | Should -Be 1
            $script:results[0] | Should -Match '❌ .+ → NO RESOLUTION'
        }
    }
}

AfterAll {
    Remove-Item 'Function:Test-DnsHost' `
        -ErrorAction 'SilentlyContinue'
}
