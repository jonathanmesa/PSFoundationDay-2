#Create a new PS drive for the registry:
New-PSDrive -Name Regclasses -PSProvider Registry -Root HKEY_CLASSES_ROOT
#Create a new PS drive for a folder on c:
New-PSDrive -Name Z -PSProvider FileSystem -Root c:\windows\system32

#Removing the drives again:
Remove-PSDrive -Name Z
Remove-PSDrive -Name Regclasses

New-PSDrive -Name W -PSProvider FileSystem -Root C:\Scripts
Set-Location z: