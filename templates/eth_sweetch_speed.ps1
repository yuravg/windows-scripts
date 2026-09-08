#!/usr/bin/env powershell

#
# Ethernet Adapter - Set Link Speed
#
# Usage:
#   .\eth_sweetch_speed.ps1 -Speed 1G
#   .\eth_sweetch_speed.ps1 -Speed 100 -AdapterName "Ethernet 2"
#
# -Speed accepts: 10, 100, 1000 (or 1G), 2500 (or 2.5G), 10000 (or 10G)
#

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('10', '100', '1000', '1G', '2500', '2.5G', '10000', '10G')]
    [string]$Speed,

    [string]$AdapterName = (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.PhysicalMediaType -eq '802.3' } | Select-Object -First 1 -ExpandProperty Name)
)

# Escalate privileges if not admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "' -Speed '$Speed' -AdapterName '$AdapterName'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

if (-not $AdapterName) {
    Write-Error "No active Ethernet adapter found; specify -AdapterName explicitly."
    exit 1
}

# Match the requested speed against this adapter's actual "Speed & Duplex" values
# (vendors phrase these differently, e.g. "1.0 Gbps Full Duplex" vs "1000 Mbps Full Duplex")
$speedPatterns = @{
    '10'    = '^10\s*Mbps'
    '100'   = '^100\s*Mbps'
    '1000'  = '1\.0\s*Gbps|1000\s*Mbps'
    '1G'    = '1\.0\s*Gbps|1000\s*Mbps'
    '2500'  = '2\.5\s*Gbps'
    '2.5G'  = '2\.5\s*Gbps'
    '10000' = '10\.0\s*Gbps|^10\s*Gbps'
    '10G'   = '10\.0\s*Gbps|^10\s*Gbps'
}
$pattern = $speedPatterns[$Speed]

$prop = Get-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Speed & Duplex" -ErrorAction SilentlyContinue
if (-not $prop) {
    Write-Error "Adapter '$AdapterName' has no 'Speed & Duplex' advanced property; speed cannot be set this way."
    exit 1
}

$targetValue = $prop.ValidDisplayValues | Where-Object { $_ -match $pattern -and $_ -match 'Full Duplex' } | Select-Object -First 1
if (-not $targetValue) {
    Write-Error "Adapter '$AdapterName' does not support speed '$Speed'. Valid values: $($prop.ValidDisplayValues -join ', ')"
    exit 1
}

Write-Host "***** Setting '$AdapterName' speed to '$targetValue' ***** `n" -ForegroundColor Green
Set-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Speed & Duplex" -DisplayValue $targetValue -Confirm:$false

Get-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Speed & Duplex"
