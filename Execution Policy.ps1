#Display current policy:
Get-ExecutionPolicy –List

#Set policy to restricted”
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted

#Try to run the script from the previous demo

#Set policy to unrestricted:
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
#Try to run the script from the previous demo 