Remove-Module Get-PropertyDiffs
Import-Module "C:\Users\joshs\OneDrive\Development\Projects\PropertyDiff\tools\Get-PropertyDiffs.psd1"

$file1 = Get-FileTableObject
$file1.Name = "Test 1"
$file1.Path = "C:\Users\JoshS\Downloads\test1.txt"

$file2 = Get-FileTableObject
$file2.Name = "Test 2"
$file2.Path = "C:\Users\JoshS\Downloads\test2.txt"

Get-PropertyDiff -FilePaths @($file1, $file2)