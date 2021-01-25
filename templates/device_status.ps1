#!/usr/bin/env powershell

#
# <DeviceName> Status
#

$device_name = "<DeviceName>"

Get-WmiObject Win32_PNPEntity | Where-Object{$_.ConfigManagerErrorCode -eq 0} | Where-object{$_.Name -Match $device_name} | Select Name, DeviceID
