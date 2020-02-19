Get-Date | Set-Content -path "c:\temp\date.csv"
"This was today" | add-Content -path "c:\temp\date.csv"
Get-Content -path "c:\temp\date.csv"
Clear-Content -path "c:\temp\date.csv"
Get-Content -path "c:\temp\date.csv


#more Examples:
Add-Content "C:\Temp\jonathan.txt "`n test"

Get-Content C:\Temp\jonathan.txt