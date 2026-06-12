#Requires -Version 5.1
#Requires -PSEdition Desktop
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
Displays Active Directory values used to inspect hybrid identity cloud anchors.
.DESCRIPTION
Reads ObjectGuid and mS-DS-ConsistencyGuid for selected users and returns their GUID and Base64 representations for synchronization troubleshooting.
.NOTES
Read-only operation. Output contains identity correlation values and should be handled as directory data.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [string[]]$Identity,

    [string]$DomainController
)

begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
}

process {
    foreach ($currentIdentity in $Identity) {
        $parameters = @{
            Identity = $currentIdentity
            Properties = @('DisplayName', 'ObjectGuid', 'mS-DS-ConsistencyGuid', 'UserPrincipalName')
        }
        if ($DomainController) {
            $parameters.Server = $DomainController
        }

        $user = Get-ADUser @parameters
        $consistencyGuid = $user.'mS-DS-ConsistencyGuid'
        $consistencyGuidValue = $null
        if ($consistencyGuid) {
            $consistencyGuidValue = New-Object -TypeName Guid -ArgumentList (,$consistencyGuid)
        }

        [pscustomobject]@{
            DisplayName                   = $user.DisplayName
            UserPrincipalName             = $user.UserPrincipalName
            ObjectGuid                    = $user.ObjectGuid
            ObjectGuidBase64              = [Convert]::ToBase64String($user.ObjectGuid.ToByteArray())
            ConsistencyGuid               = $consistencyGuidValue
            ConsistencyGuidBase64         = if ($consistencyGuid) { [Convert]::ToBase64String($consistencyGuid) } else { $null }
        }
    }
}
