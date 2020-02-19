#Demonstrate the following commands:
$systemfolder = "\system32\\"
$windows = "c:\windows\"
($windows+$systemfolder)

#The command Test-path & Join-path:
Test-Path -path ($windows+$systemfolder)
Join-Path -Path $windows -ChildPath $systemfolder

#The command split-path:
Split-Path -path ($windows+$systemfolder) -Parent
Split-Path -path ($windows+$systemfolder) -Leaf 