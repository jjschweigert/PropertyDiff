$returnPath = Get-Location
Set-Location C:\Users\JoshS\OneDrive\Development\Projects\PropertyDiff\tools

Remove-Item .\Get-PropertyDiffs.psd1 -Force

New-ModuleManifest `
    -Path "Get-PropertyDiffs.psd1" `
    -NestedModules @("..\module\Get-PropertyDiff\Get-PropertyDiff.psm1", "..\module\Get-CustomObject\Get-CustomObject.psm1") `
    -Guid (New-Guid) `
    -ModuleVersion '1.0.0.0' `
    -Description 'Create Get-PropertyDiffs module' `
    -PowerShellVersion $PSVersionTable.PSVersion.ToString()

Set-Location $returnPath