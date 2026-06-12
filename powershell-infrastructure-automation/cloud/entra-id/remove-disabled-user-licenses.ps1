#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users, Microsoft.Graph.Users.Actions

<#
.SYNOPSIS
Removes directly assigned licenses from disabled Microsoft Entra users.
.DESCRIPTION
Finds disabled users, excludes group-based and configured SKU assignments, removes eligible direct licenses, and writes an audit CSV.
.NOTES
Destructive operation using certificate authentication. Use -WhatIf, then test in a controlled non-production tenant or limited scope and validate rollback before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)]
    [guid]$TenantId,

    [Parameter(Mandatory)]
    [guid]$ClientId,

    [Parameter(Mandatory)]
    [string]$CertificateThumbprint,

    [string[]]$ExcludedSkuPartNumber = @(),

    [Parameter(Mandatory)]
    [string]$AuditPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Connect-MgGraph `
    -TenantId $TenantId `
    -ClientId $ClientId `
    -CertificateThumbprint $CertificateThumbprint `
    -NoWelcome

$audit = [System.Collections.Generic.List[object]]::new()
$users = Get-MgUser -All -Filter 'accountEnabled eq false' -Property Id, UserPrincipalName, AssignedLicenses, LicenseAssignmentStates

foreach ($user in $users) {
    if ($user.AssignedLicenses.Count -eq 0) {
        continue
    }

    $directSkuIds = @(
        $user.LicenseAssignmentStates |
            Where-Object { -not $_.AssignedByGroup } |
            ForEach-Object { $_.SkuId }
    )
    if ($directSkuIds.Count -eq 0) {
        continue
    }

    $details = Get-MgUserLicenseDetail -UserId $user.Id
    $skuIds = @(
        $details |
            Where-Object {
                $_.SkuId -in $directSkuIds -and
                $_.SkuPartNumber -notin $ExcludedSkuPartNumber
            } |
            ForEach-Object { $_.SkuId }
    )

    if ($skuIds.Count -eq 0) {
        continue
    }

    $status = 'WhatIf'
    if ($PSCmdlet.ShouldProcess($user.UserPrincipalName, "Remove $($skuIds.Count) licenses")) {
        Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses $skuIds
        $status = 'Removed'
    }

    $audit.Add([pscustomobject]@{
        TimestampUtc      = (Get-Date).ToUniversalTime()
        UserPrincipalName = $user.UserPrincipalName
        RemovedSkuCount   = $skuIds.Count
        Status            = $status
    })
}

$auditDirectory = Split-Path -Parent $AuditPath
if ($auditDirectory) {
    New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
}
$audit | Export-Csv -LiteralPath $AuditPath -NoTypeInformation -Encoding utf8
