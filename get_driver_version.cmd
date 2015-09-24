powershell set-executionpolicy Unrestricted
REM mkdir c:\temp
powershell .\driverversion.ps1 .\driver_version_%computername%.txt
echo " pick results from ".\driver_version_%computername%.txt" 