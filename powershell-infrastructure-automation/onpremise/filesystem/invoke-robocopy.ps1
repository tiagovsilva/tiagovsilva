#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Copies or mirrors a directory tree with Robocopy.
.DESCRIPTION
Validates the source, builds a controlled Robocopy command, optionally copies security metadata, and writes a detailed operation log.
.NOTES
Mirror mode can delete files. Use -WhatIf, then test with disposable non-production data and validate backup and restore before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [string]$Source,

    [Parameter(Mandatory)]
    [string]$Destination,

    [switch]$Mirror,

    [switch]$CopySecurity,

    [ValidateRange(0, 100)]
    [int]$RetryCount = 2,

    [Parameter(Mandatory)]
    [string]$LogPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    throw "Source directory '$Source' does not exist."
}

$arguments = @(
    $Source
    $Destination
    $(if ($Mirror) { '/MIR' } else { '/E' })
    "/R:$RetryCount"
    '/W:5'
    '/XJ'
    '/NP'
    "/LOG:$LogPath"
)
if ($CopySecurity) {
    $arguments += '/COPY:DATS'
}

$action = if ($Mirror) {
    "Mirror source to destination. Files absent from the source can be deleted from '$Destination'"
}
else {
    'Copy all subdirectories without deleting destination-only files'
}

if ($PSCmdlet.ShouldProcess($Destination, $action)) {
    $logDirectory = Split-Path -Parent $LogPath
    if ($logDirectory) {
        New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    }

    & robocopy.exe @arguments
    $exitCode = $LASTEXITCODE
    if ($exitCode -ge 8) {
        throw "Robocopy failed with exit code $exitCode. Review '$LogPath'."
    }
}
