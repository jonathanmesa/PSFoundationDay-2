#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

function Get-Dc
{
    <#
    .SYNOPSIS
        Find a DC in a domain that is up and running by probing the DC port 389
        Find a DC with GC role in a domain that is up and running by probing the DC port 3268
        Find a DC with ADWS role in a domain that is up and running by probing the DC port 9389
        List a single , best responsive or all servers found
    .DESCRIPTION
        Find all DC`s within your query range and probe if it responds to the AD port and return a working DC, all working DC or 
        best available DC.
        If the site parameter is not specified it will use the computers AD site if it resolves. Otherwise it will use all AD Sites.
        A subset of DC`s with a specific role can be specified using switches -isgc and/or -isadws.
        Return a random server that is working, return all working servers or return the best responsive server based on ping response. 
    .EXAMPLE
        Get-Dc

        Get all DC`s from the current computers site. Return a random working DC
    .EXAMPLE
        Get-Dc -listall

        Get all DC`s from the current computers site. Return list of all working Domain controllers
    .EXAMPLE
        Get-Dc -ADsite "*"

        Get all DC`s from the logged on Domain. Return a random working DC
    .EXAMPLE
        Get-Dc -ADSite "Newyork"
    
        Get all DC`s from the logged on Domain in the AD site Newyork. Return a random working DC
    .EXAMPLE
        Get-Dc -ADSite "Newyork" -isgc -isadws
    
        Get all DC`s from the logged on Domain in the AD site Newyork. filter out DC`s running GC and ADWS services.
        Return a random working DC
    .EXAMPLE
        Get-Dc -Domain "contoso.com" -ADSite "Newyork" -Bestresponsetime
    
        Get all DC`s from the domain contoso.com in the AD site Newyork and probe for best response time. Return the fastest responding DC
    .EXAMPLE
        Get-Dc -Domain "contoso.com" -ADSite "Newyork" -Bestresponsetime -cred (get-credential)
    
        Get all DC`s from the domain contoso.com in the AD site Newyork and probe for best response time. Return the fastest responding DC
        Use a interactive credential prompt to provide credentials

    .NOTES
        -----------------------------------------------------------------------------------------------------------------------------------
        Function name : Get-Dc
        Authors       : Martijn (scriptkiddie) van Geffen
        Version       : 1.3
        dependancies  : None
        -----------------------------------------------------------------------------------------------------------------------------------
        -----------------------------------------------------------------------------------------------------------------------------------
        Version Changes:
        Date: (dd-MM-YYYY)    Version:     Changed By:           Info:
        10-10-2016            V0.1         Martijn van Geffen    Initial Script.
        06-12-2016            V0.2         Martijn van Geffen    Updated script with credential support and doubble ping.
        12-12-2016            V1.0         Martijn van Geffen    Fixed a issue with the credentials when querying from a domain joined PC.
        17-01-2017            v1.1         Martijn van Geffen    Updated "Site" param to "ADsite" and try to resolve default AD site if the
                                                                 param is not specified.
	    27-01-2017            v1.2         Martijn van Geffen    Added an aditional loop for cross forest DC lookup. If script won`t find a
                                                                 DC in the site it will retry all sites.
        17-10-2017            v1.3         Martijn van Geffen    Added support for specific AD role Global catalog
                                                                 Added support for specific AD role Active directory web services
                                                                 Added support to return list of all working DC`s 
                                                                 Added alias gdc
                                                                 Update code error handling  
                                                                 Added verbose & debug output
        -----------------------------------------------------------------------------------------------------------------------------------
    .OUTPUTS
        [system.Array]        
    .ROLE
        None
    .FUNCTIONALITY
        Find a DC in a domain that is up and running by probing the DC port 389
    #>

    [CmdletBinding(
                        DefaultParameterSetName='return_one',
                        HelpUri='https://gallery.technet.microsoft.com/scriptcenter/Find-a-working-domain-fe731b4f'
                   )]
    [Alias("gdc")]
    [OutputType([System.Array])]

    param(

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain = ([system.directoryservices.activedirectory.domain]::GetCurrentDomain()).name,
    
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ADSite = "getsite",

        [Parameter(
                        Mandatory=$false,
                        ParameterSetName='return_one'
                   )]
        [switch]$Bestresponsetime,

        [Parameter(Mandatory=$false)]
        [switch]$isgc,

        [Parameter(Mandatory=$false)]
        [switch]$isadws,

        [Parameter(
                        Mandatory=$false,
                        ParameterSetName='return_all'
                   )]
        [switch]$listall,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PsCredential]$Cred

    )

    #region resolve site and domain
    if ($ADsite -eq "getsite")
    {
        try
        {
            $ADsite = ([System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()).name
            Write-Verbose -Message "Found computer to be in AD site: $ADsite"
        }catch
        {
            $ADsite = "*"
            Write-Verbose -Message "Could not resolve AD site setting site to *"
        }
    }

    if ( $cred )
    {
        $username = $Cred.username
        $password = $Cred.GetNetworkCredential().password
        $ADcontext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("domain",$domain,$username,$password)
    }else
    {
        $ADcontext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext("domain",$domain)
    }
    #endregion resolve site and domain

    #region resolve DC in site
    $AllDCs = ([system.directoryservices.activedirectory.domain]::GetDomain($ADcontext).domainControllers)

    Write-debug -Message "All domaincontrollers according to AD: $($allDCs)"

    $AllDCinsite = $AllDCs | Where-Object -FilterScript {$_.sitename -like $ADsite }
    [array]$AllDCinsite = $AllDCinsite.name
    
    Write-Verbose -Message "All domaincontrollers according to site filter: $($AllDCinsite)"

    If ($AllDCinsite.count -eq 0)
    {
        Write-debug -Message "Did not find any DC , retrying with full site scope might be a non local domain"
        $ADsite = "*"
        $AllDCinsite = $AllDCs | Where-Object -FilterScript {$_.sitename -like $ADsite }
        [array]$AllDCinsite = $AllDCinsite.name
        Write-Verbose -Message "All domaincontrollers after resetting site scope to all sites: $($AllDCinsite)"
    }

    $AllusableDC = @()
    #endregion resolve DC in site

    #region test if ADDC is availble for AD querys
    foreach ($DC in $AllDCinsite)
    { 
        #validate if server is usable for AD query`s
        
        try 
        {            
            $socket = New-Object Net.sockets.tcpclient
            $socket.Connect($DC, "389")
            if ( $socket.Connected )
            {
                $AllusableDC += $DC           
            }
            
        }
        catch
        {
          write-verbose -Message "Domain controller $dc is not reachable"
        }
        finally
        {
            if ( $socket -is [System.IDisposable])
            { 
                $socket.Dispose()
            } 
        }
    }

    Write-Verbose -Message "All working domaincontrollers: $($AllusableDC)"
    #endregion test if ADDC is availble for AD querys

    #region test if ADDC is availble for GC query`s
    If ($isgc.ispresent)
    {
        $AllusableGC = @()
        foreach ($GC in $AllusableDC)
        { 
            #validate if server is usable for GC query`s
        
            try 
            {            
                $socket = New-Object Net.sockets.tcpclient
                $socket.Connect($GC, "3268")
                if ( $socket.Connected )
                {
                    $AllusableGC += $GC           
                }                
            }
            catch
            {
              write-verbose -Message "Global catalog $GC is not reachable"
            }
            finally
            {
                if ( $socket -is [System.IDisposable])
                { 
                    $socket.Dispose()
                } 
            }
        }
        Write-Verbose -Message "All working Global catalogs: $($AllusableGC)"
        $AllusableDC = $AllusableGC
    }
    #endregion test if ADDC is availble for GC query`s

    #region test if ADDC is availble for ADWS query`s
    If ($isadws.ispresent)
    {
        $AllusableADWS = @()
        foreach ($ADWS in $AllusableDC)
        { 
            #validate if server is usable for ADWS query`s
        
            try 
            {            
                $socket = New-Object Net.sockets.tcpclient
                $socket.Connect($ADWS, "9389")
                if ( $socket.Connected )
                {
                    $AllusableADWS += $ADWS           
                }
                
            }
            catch
            {
              write-verbose -Message "ADWS service on $ADWS is not reachable"
            }
            finally
            {
                if ( $socket -is [System.IDisposable])
                { 
                    $socket.Dispose()
                } 
            }
        }
        Write-Verbose -Message "All working domain controllers with ADWS: $($AllusableADWS)"
        $AllusableDC = $AllusableADWS
    }
    #endregion test if ADDC is availble for ADWS query`s

    #region validate response times for best responsetime param
    if ($bestresponsetime.IsPresent)
    {
        Write-Verbose -Message "Probing for best response time"
        try
        {
            $dcresponse = @()
            $ping = new-object System.Net.NetworkInformation.ping
            foreach ($testdc in $AllusableDC)
            {
                #clean itterative variables
                $pingresult = $null
                $pingresultavg = $null

                try 
                {
                    $pingresult = $ping.Send($testdc).Roundtriptime
                    $pingresult += $ping.Send($testdc).Roundtriptime
                    $pingresultavg = $pingresult/2
                    Write-Verbose -Message "domaincontrollers: $testdc, Test time: $pingresultavg"
                }
                catch
                {
                    write-verbose -Message "Unable to ping $testdc is not reachable"
                }

                $tempdc = New-Object PSObject
                $tempdc | Add-Member -Type NoteProperty -Name "Name" -Value $testdc
                $tempdc | Add-Member -Type NoteProperty -Name "pingtime" -Value $pingresultavg
                $dcresponse += $tempdc
            }        

            $dcresponse = $dcresponse | Sort-Object -Property pingtime
            $returnDC = $dcresponse[0].name 
            Write-Verbose -Message "Fastest dc: $returnDC"
        }
        finally
        {  
            if ( $ping -is [System.IDisposable])
            { 
                $ping.dispose() 
            }                 
        }

    }else
    {
        Write-Verbose -Message "All DC that meet the query and are working: $($AllusableDC)"
        if ($listall.IsPresent)
        {
            $returnDC = $AllusableDC
        }
        else
        {
            $returnDC = get-random $AllusableDC
        }
    }
    #endregion validate response times for best responsetime param

    return $returnDC
}