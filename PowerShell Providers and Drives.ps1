Get-ChildItem HKCU:\
Get-ChildItem


Set-Location cert:
 
Set-Location currentuser
 
Set-Location root


Get-ChildItem | Where-Object Subject -like '*DigiCert*'

Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-Name "fDenyTSConnections"