<# 
.SYNOPSIS 
    harvest / copy files to a local script server 
.DESCRIPTION 
    Script request to harvest log files from multiple computers to a local script server using variable path and server input 
.EXAMPLE 
    .\copylogs.ps1 -servers (gc c:\servers.txt) -uncpath "\c$\windows\system32\adprep\*" -include "*.ldf" 
     
    Copy all the files in the folder \c$\windows\system32\DHCP\ from a remote DHCP server to the local script server 
    using a tekst file containing server names as input 
.EXAMPLE 
    .\copylogs.ps1 -servers $servers -uncpath "\c$\windows\system32\adprep\*" -include "*.ldf" 
     
    Copy all the files in the folder \c$\windows\system32\DHCP\ from a remote DHCP server to the local script server 
.EXAMPLE 
    .\copylogs.ps1 -servers $servers -uncpath "\c$\windows\system32\adprep\*" -include "*.ldf" 
     
    Copy all the ldf files from a remote DC to the local script server 
.NOTES 
    script name : copylogs.ps1 
    Authors       : Martijn (scriptkiddie) van Geffen 
    Version       : 0.1 
       
    Version Changes 
    0.1: Initial Script (MvG) 
#> 
 
param( 
 
    [Parameter(Mandatory=$true)] 
    [ValidateNotNullOrEmpty()] 
    [array]$servers, 
 
    [Parameter(Mandatory=$false)] 
    [ValidateNotNullOrEmpty()] 
    [string]$include = "*", 
 
    [Parameter(Mandatory=$true)] 
    [ValidateNotNullOrEmpty()] 
    [string]$uncpath 
) 
 
 
$storefolder = $PSScriptRoot 
 
$count = 0  
foreach ( $server in $servers )  
{ 
 
    Write-Progress -activity "copying files from $server" -status "total server Percent done: " -percentComplete (($count / $servers.count)  * 100) 
 
    $sourcepath = "\\" + $server + "\" + $uncpath  
    $destination = $storefolder + "\" + $server 
    $files = Get-ChildItem $path 
    if (!(test-path $destination)) 
    { 
        New-Item -ItemType directory -Path $destination 
    } 
    Copy-Item -Path $sourcepath -Destination $destination -Include $include -Recurse 
 
 
  # End of code snippet use download to get entire script 