#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules PnP.PowerShell

<#
.SYNOPSIS
Exports a SharePoint Online site as a PnP provisioning template.
.DESCRIPTION
Connects interactively to a site and saves its supported structure, client-side pages, and branding files to the requested template path.
.NOTES
Read-only against SharePoint, but the exported template can contain site configuration and should be reviewed before publication.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [uri]$SiteUrl,

    [Parameter(Mandatory)]
    [guid]$ClientId,

    [Parameter(Mandatory)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

Connect-PnPOnline -Url $SiteUrl.AbsoluteUri -Interactive -ClientId $ClientId
Get-PnPSiteTemplate -Out $OutputPath -IncludeAllClientSidePages -PersistBrandingFiles
