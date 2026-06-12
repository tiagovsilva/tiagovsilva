#Requires -Version 7.4
#Requires -PSEdition Core
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns

<#
.SYNOPSIS
Removes selected phone authentication methods from Microsoft Entra users.
.DESCRIPTION
Looks up mobile, alternate mobile, or office phone methods through Microsoft Graph, removes the selected methods, and records the result in an audit CSV.
.NOTES
Destructive authentication change. Use -WhatIf, then test with non-production identities and validate account recovery before production.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string[]]$UserId,

    [ValidateSet('mobile', 'alternateMobile', 'office')]
    [string[]]$PhoneType = @('mobile', 'alternateMobile', 'office'),

    [Parameter(Mandatory)]
    [string]$AuditPath
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    Connect-MgGraph -Scopes 'UserAuthenticationMethod.ReadWrite.All' -NoWelcome
    $audit = [System.Collections.Generic.List[object]]::new()
}

process {
    foreach ($id in $UserId) {
        $methods = Get-MgUserAuthenticationPhoneMethod -UserId $id |
            Where-Object { $_.PhoneType -in $PhoneType }

        foreach ($method in $methods) {
            $status = 'WhatIf'
            if ($PSCmdlet.ShouldProcess($id, "Remove $($method.PhoneType) phone authentication method")) {
                Remove-MgUserAuthenticationPhoneMethod -UserId $id -PhoneAuthenticationMethodId $method.Id
                $status = 'Removed'
            }

            $audit.Add([pscustomobject]@{
                TimestampUtc = (Get-Date).ToUniversalTime()
                UserId       = $id
                PhoneType    = $method.PhoneType
                Status       = $status
            })
        }
    }
}

end {
    $auditDirectory = Split-Path -Parent $AuditPath
    if ($auditDirectory) {
        New-Item -ItemType Directory -Path $auditDirectory -Force | Out-Null
    }
    $audit | Export-Csv -LiteralPath $AuditPath -NoTypeInformation -Encoding utf8
}
