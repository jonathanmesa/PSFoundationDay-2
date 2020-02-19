#Show all commands that support native OS remoting:
Get-Command -ParameterName ComputerName 

#Demo  of the commands:
Test-connection –computername winazcontoso03 
Get-winevent –logname system –computername winazcontoso03
Get-hotfix –computername winazcontoso03 
 Get-Service -Name Spooler -ComputerName winazcontoso03 | Restart-Service -Verbose 
 Get-Service -Name Spooler -ComputerName winazcontoso03,winazcontoso01 | Restart-Service -Verbose 