#Requires -Version 5.1
#Requires -PSEdition Desktop

<#
.SYNOPSIS
Tests TCP and HTTP connectivity to a WSUS server.
.DESCRIPTION
Checks the configured server and port with Test-NetConnection, probes the WSUS client web service, and returns a structured status object.
.NOTES
Read-only diagnostic. Use TLS and the correct WSUS port for the target environment.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Server,

    [ValidateRange(1, 65535)]
    [int]$Port = 8531,

    [switch]$UseTls
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scheme = if ($UseTls) { 'https' } else { 'http' }
$uri = [uri]::new("${scheme}://${Server}:${Port}/ClientWebService/client.asmx")
$tcp = Test-NetConnection -ComputerName $Server -Port $Port -InformationLevel Detailed

$httpStatus = $null
$httpError = $null
try {
    $response = Invoke-WebRequest -Uri $uri -Method Head -TimeoutSec 15
    $httpStatus = [int]$response.StatusCode
}
catch {
    $httpError = $_.Exception.Message
}

[pscustomobject]@{
    Server          = $Server
    Port            = $Port
    TcpSucceeded    = $tcp.TcpTestSucceeded
    RemoteAddress   = $tcp.RemoteAddress
    HttpStatus      = $httpStatus
    HttpError       = $httpError
    TestedAtUtc     = (Get-Date).ToUniversalTime()
}
