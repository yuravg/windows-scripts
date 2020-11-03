#!/usr/bin/env powershell

#
# <DeviceName> Enable
#
# https://www.reddit.com/r/PowerShell/comments/5j4djb/disabling_devices_from_powershell_scripts_in/
#

$device_name = "<DeviceName>"

Write-Host "***** '$device_name' ENABLE ***** `n" -ForegroundColor Green

# Escalate privileges if not admin
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# Loop through them to disable/enable one at a time to lessen the possibility no conrolling
# devices are available to confirm But might want to do this remotely to be sure.
Get-PnpDevice |
  Where-Object { $_.FriendlyName -match $device_name } |
  Enable-PnpDevice -Confirm:$false
