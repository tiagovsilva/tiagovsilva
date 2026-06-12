#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Creates a directory symbolic link to an existing target directory.
.DESCRIPTION
Validates that the target exists and the link does not, creates the parent directory when needed, and then creates the symbolic link.
.NOTES
Changes the filesystem. Use -WhatIf, then test in a controlled non-production path and validate removal before production.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$LinkPath,

    [Parameter(Mandatory)]
    [string]$TargetPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TargetPath -PathType Container)) {
    throw "Target directory '$TargetPath' does not exist."
}
if (Test-Path -LiteralPath $LinkPath) {
    throw "Link path '$LinkPath' already exists."
}

$parent = Split-Path -Parent $LinkPath
if ($PSCmdlet.ShouldProcess($LinkPath, "Create symbolic link to '$TargetPath'")) {
    if ($parent) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
}
