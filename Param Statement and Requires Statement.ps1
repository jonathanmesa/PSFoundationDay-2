param(
[Parameter(Mandatory=$true) ]
[string]$ComputerName = $env:computername   

)
Test-Connection -ComputerName $ComputerName -Quiet -Count 1







#Requires –RunAsAdministrator