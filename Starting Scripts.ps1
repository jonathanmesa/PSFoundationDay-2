Download  following to c:\temp:
https://gallery.technet.microsoft.com/Get-RemoteProgram-Get-list-de9fd2b4



#Start script with full path:
C:\temp\Get-RemoteProgram.ps1

#Start script dot notation from current path
.\Get-RemoteProgram.ps1

#Using Invoke command
& "Get-RemoteProgram.ps1"

#Using start-process
Start-Process powershell -ArgumentList "C:\temp\Get-RemoteProgram.ps1"

#Using the mouse
#Right click the script and select run with PowerShell 

##########