Function Search-Bing
{
    param(
          [parameter(
          ValueFromPipelineByPropertyName=$true,
          ValueFromPipeLine=$true,
          Mandatory=$false,
          ValueFromRemainingArguments = $true,
          Position=0)]
    [string[]]$query)

    PROCESS
    {
        if($query.count -gt 1)
        {
            $query = $query -join " "
        }
        Start-Process "http://www.bing.com/search?q=$query"
    }
}

New-Alias -Name Bing -Value Search-Bing

#Export-ModuleMember -Function "Search-Bing"  -Alias Bing