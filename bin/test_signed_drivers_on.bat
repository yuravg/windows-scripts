rem
rem Enable Loading of Test Signed Drivers
rem
rem https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option
rem
rem Administrator rights required:
rem  Press Windows+R to open the "Run" box. Type "cmd" into the box and then press
rem  Ctrl+Shift+Enter to run the command as an administrator.
rem
@echo off
bcdedit /set testsigning on
pause
