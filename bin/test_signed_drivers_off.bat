@echo off
rem
rem Disable of Test Signed Drivers
rem
rem https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option
rem
rem Administrator rights required:
rem  Press Windows+R to open the "Run" box. Type "cmd" into the box and then press
rem  Ctrl+Shift+Enter to run the command as an administrator.

echo ***** DISABLE Loading of Test Signed Drivers *****
echo NOTE: Administrator rights required!
echo        (press Windows+R to open the "Run" box;
echo         Ctrl+Shift+Enter to run the command as an administrator)
@echo on

bcdedit /set testsigning off
pause
