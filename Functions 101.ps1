#Example 1
function Get-ServiceInfo
{
    Get-Service -Name spooler -RequiredServices -ComputerName winazcontoso03
} 


Get-ServiceInfo

#Example 2 -Adding Parameters

function Get-ServiceInfo
{
        Param ($svc, $computer)
    Get-Service -Name $svc -RequiredServices -ComputerName $computer
} 

Get-ServiceInfo -svc "spooler" -computer winazcontoso03



#Example 3 (using the ISE)

function MyFunction ($svc1, $computer1)
{
    Get-Service -Name $svc1 -RequiredServices -ComputerName $computer1
    
}

MyFunction -svc1 spooler -computer1 winazcontoso03