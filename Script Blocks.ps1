#Example 1 
#Local
Invoke-Command -ScriptBlock {Get-NetAdapter -Physical} 
#Remote: 
Invoke-Command -ScriptBlock {Get-NetAdapter -Physical} -ComputerName winazcontoso01


#Example 2

#Local
$MySB1 = {Get-NetAdapter -Physical}
Invoke-Command -ScriptBlock $MySB1

$Remote 
$MySB1 = {Get-NetAdapter -Physical}
Invoke-Command -ScriptBlock $MySB1 -ComputerName winazcontoso01

#Remote To Multiple System
$MySB1 = {Get-Process}
Invoke-Command -ScriptBlock $MySB1 -ComputerName winazcontoso01,winazcontoso03