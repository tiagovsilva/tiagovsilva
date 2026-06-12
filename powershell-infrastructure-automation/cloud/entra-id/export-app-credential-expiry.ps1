#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Applications

<#
.SYNOPSIS
Exports Microsoft Entra application credentials that are expired or nearing expiration.
.DESCRIPTION
Reads application password and certificate credentials through Microsoft Graph and writes their expiration status to a CSV report.
.NOTES
Read-only operation requiring Application.Read.All. The report can contain application identifiers.
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 3650)]
    [int]$ExpiresWithinDays = 30,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph -Scopes 'Application.Read.All' -NoWelcome

$cutoff = (Get-Date).ToUniversalTime().AddDays($ExpiresWithinDays)
$results = foreach ($application in Get-MgApplication -All -Property Id, AppId, DisplayName, PasswordCredentials, KeyCredentials) {
    foreach ($credential in @($application.PasswordCredentials) + @($application.KeyCredentials)) {
        if ($null -eq $credential.EndDateTime -or $credential.EndDateTime.UtcDateTime -gt $cutoff) {
            continue
        }

        [pscustomobject]@{
            ApplicationName = $application.DisplayName
            ApplicationId   = $application.AppId
            CredentialType  = $credential.GetType().Name
            DisplayName     = $credential.DisplayName
            ExpiresAtUtc    = $credential.EndDateTime.UtcDateTime
            DaysRemaining   = [math]::Floor(($credential.EndDateTime.UtcDateTime - (Get-Date).ToUniversalTime()).TotalDays)
        }
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$results |
    Sort-Object ExpiresAtUtc |
    Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8

Write-Information "Exported $(@($results).Count) expiring credentials to '$OutputPath'." -InformationAction Continue
