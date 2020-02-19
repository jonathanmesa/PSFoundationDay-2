#The difference between item and properties when browsing datastores:
Set-Location "hklm:\SOFTWARE\Microsoft\FilePicker“  followed by DIR    -> No output 
Get-ChildItem -path "hklm:\SOFTWARE\Microsoft\FilePicker“    -> No output                                                                                                 -> while in the location still prompts for name 
Get-ItemProperty -Path "hklm:\SOFTWARE\Microsoft\FilePicker“     -> should work
Get-ItemPropertyvalue -Path "hklm:\SOFTWARE\Microsoft\FilePicker" -Name "AsyncWindowBehaviorDisabled“      -> should work but only displays 1 value or the ”name” parameter must be used with multiple values
Get-item -Path  "hklm:\SOFTWARE\Microsoft\FilePicker“         -> should work  displays most data 

#Working with properties:
new-item -Path HKCU:\ -Name Powershell
New-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701"
New-ItemProperty -Path HKCU:\Powershell  -Name registry2 -Value "NCC-74656"
set-ItemProperty -Path HKCU:\Powershell  -Name registry1 -Value "NCC-1701-D“
Get-item –path HKCU:\Powershell
Rename-ItemProperty -Path HKCU:\Powershell -Name registry1 -NewName Ship1
Rename-ItemProperty -Path HKCU:\Powershell -Name registry2 -NewName Ship2
Get-item –path HKCU:\Powershell
new-item -Path HKCU:\ -Name "Intrepid"
new-item -Path HKCU:\ -Name "Galaxy"
Copy-ItemProperty -Path HKCU:\Powershell -Destination HKCU:\Intrepid -Name Ship2
Move-ItemProperty -Path HKCU:\Powershell -Destination HKCU:\Galaxy -name Ship1
Get-item –path HKCU:\Intrepid
Get-item –path HKCU:\galaxy
Remove-ItemProperty -Path HKCU:\Galaxy -Name Ship1
Remove-Item -Path HKCU:\Galaxy
Remove-Item -Path HKCU:\Intrepid 