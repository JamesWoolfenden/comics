# Copyright (c) 2014 Microsoft Corp.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# This script requires Pester (https://github.com/pester) module imported

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ((Get-Module HttpListener) -ne $null) {
    Remove-Module HttpListener
}
Import-Module $currentDir\HttpListener.psd1 -Force

# start the httplistener, requires elevation
$command = "ipmo $pwd\httplistener.psd1;start-httplistener -url test -verbose"
$process = Start-Process powershell -ArgumentList $command -Verb RunAs -PassThru


Function Invoke-WebPowerShell([string] $command, [string] $format = [string]::Empty) {
    $url = "http://localhost:8888/test"
    $httpArgs = @{UseDefaultCredentials=$true}
    $url += "`?command=$command"
    if ($format -ne [string]::Empty) {
        $url += "&format=$format"
    }
    $response = Invoke-WebRequest -Uri $url @httpArgs
    [System.Text.Encoding]::UTF8.GetString($response.Content)
}

Describe "Invoking commandline" {

    It "returns single object" {
        $json = Invoke-WebPowerShell -command "Get-ciminstance win32_bios" -format "JSON"
        $bios = Get-CimInstance win32_bios | ConvertTo-Json
        Compare-Object $json $bios | Should BeNullOrEmpty
    }

    It "returns multiple objects" {
        $json = Invoke-WebPowerShell -command "Get-verb" -format "JSON"
        $verb = Get-Verb | ConvertTo-Json
        Compare-Object $json $verb | Should BeNullOrEmpty
    }

    It "returns nothing" {
        $json = Invoke-WebPowerShell -command "Get-help > `$null" -format "JSON" | Should Be ([string]::Empty)
    }
}

Describe -Tags "Negative" "Exception Handling" {

    It "returns PowerShell exception" {
        try {
            Invoke-WebPowerShell -command "Get-invalidcmdlet" -format "json" | Should BeNullOrEmpty
        } catch {
            ($_.ErrorDetails.Message | ConvertFrom-Json).FullyQualifiedErrorId | Should Be "CommandNotFoundException"
        }
    }

    It "returns cmdlet exception" {
        try {
            Invoke-WebPowerShell -command "Get-process foo" -format "json" | Should BeNullOrEmpty
        } Catch {
            ($_.ErrorDetails.Message | ConvertFrom-Json).FullyQualifiedErrorId | Should Be "NoProcessFoundForGivenName,Microsoft.PowerShell.Commands.GetProcessCommand"
        }
    }
}

$command = "stop-process -id $($process.Id)"
Start-Process powershell -ArgumentList $command -Verb RunAs