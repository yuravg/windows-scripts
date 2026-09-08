#!/usr/bin/env powershell

#
# Ethernet Adapter - Set Link Speed
#
# Run from an already-elevated shell (does not self-elevate / no UAC popup).
#
# Usage:
#   .\eth_set_speed.ps1 -Speed 1G
#   .\eth_set_speed.ps1 -Speed 100 -AdapterName "Ethernet 2"
#
# -Speed accepts: 10, 100, 1000 (or 1G), 2500 (or 2.5G), 10000 (or 10G)
#

param(
    [string]$Speed,
    [string]$AdapterName
)

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

if (-not $speedPatterns.ContainsKey($Speed)) {
    Write-Host "Usage: eth_set_speed.ps1 -Speed <10|100|1000|1G|2500|2.5G|10000|10G> [-AdapterName <name>]"
    exit 1
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Not elevated - re-run this from an Administrator shell (this script will not self-elevate)."
    exit 1
}

if (-not $AdapterName) {
    $AdapterName = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.PhysicalMediaType -eq '802.3' } | Select-Object -First 1 -ExpandProperty Name
}
if (-not $AdapterName) {
    Write-Host "No active Ethernet adapter found - pass -AdapterName explicitly."
    exit 1
}

# Match the requested speed against this adapter's actual "Speed & Duplex" values
# (vendors phrase these differently, e.g. "1.0 Gbps Full Duplex" vs "1000 Mbps Full Duplex")
$prop = Get-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Speed & Duplex"
if (-not $prop) {
    Write-Host "Adapter '$AdapterName' has no 'Speed & Duplex' setting - speed cannot be set this way."
    exit 1
}

$targetValue = $prop.ValidDisplayValues | Where-Object { $_ -match $speedPatterns[$Speed] -and $_ -match 'Full Duplex' } | Select-Object -First 1
if (-not $targetValue) {
    Write-Host "Adapter '$AdapterName' does not support speed '$Speed'. Valid values: $($prop.ValidDisplayValues -join ', ')"
    exit 1
}

Set-NetAdapterAdvancedProperty -Name $AdapterName -DisplayName "Speed & Duplex" -DisplayValue $targetValue -Confirm:$false
Write-Host "'$AdapterName' set to '$targetValue'"
