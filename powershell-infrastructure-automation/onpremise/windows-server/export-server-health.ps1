#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Exports a local Windows server health snapshot as JSON.
.DESCRIPTION
Collects operating system, boot time, network, stopped automatic services, and fixed-disk capacity information into a structured report.
.NOTES
Read-only operation. The generated JSON can contain host, domain, and IP information and must remain outside Git.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$network = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = True'
$services = Get-CimInstance -ClassName Win32_Service -Filter "StartMode = 'Auto'" |
    Where-Object State -NE 'Running'
$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType = 3'

$report = [pscustomobject]@{
    CollectedAtUtc          = (Get-Date).ToUniversalTime()
    ComputerName            = $env:COMPUTERNAME
    Domain                  = $computerSystem.Domain
    OperatingSystem         = $operatingSystem.Caption
    OperatingSystemVersion  = $operatingSystem.Version
    LastBootTimeUtc         = $operatingSystem.LastBootUpTime.ToUniversalTime()
    IpAddresses             = @($network.IPAddress | Where-Object { $_ -notmatch ':' })
    AutomaticServicesStopped = @($services | Select-Object Name, DisplayName, State)
    FixedDisks              = @(
        $disks | ForEach-Object {
            [pscustomobject]@{
                DeviceId         = $_.DeviceId
                SizeGb           = [math]::Round($_.Size / 1GB, 2)
                FreeSpaceGb      = [math]::Round($_.FreeSpace / 1GB, 2)
                FreeSpacePercent = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { 0 }
            }
        }
    )
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8
