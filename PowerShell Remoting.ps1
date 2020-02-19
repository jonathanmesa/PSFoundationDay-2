Get-PSSessionConfiguration


#Create new persistent sessions:

$sessions = New-PSSession -ComputerName  winazcontoso03, winazcontoso01
Invoke-Command –Session $sessions –ScriptBlock {$hostname = (get-wmiobject win32_computersystem).name ;“Hello world from $hostname”}


Remove-PSSession -Id 13