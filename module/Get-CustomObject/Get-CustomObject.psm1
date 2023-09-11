<#
.Synopsis
Get a custom object

.Description
Returns a custom object using pre-created hash tables

.Parameter TemplateHash
The template hash table to create the object from

.Example
# Providing 3 files in the form name=value where each property is on a new line
Get-PropertyDiff -FilePaths @("C:\data\jan.txt", "C:\data\feb.txt", "C:\data\mar.txt") -PropertyNameValueDelimiter "=" -PropertyDelimiter "`n"
#>

$Template_PropertyDiff = @{
    Name = ""
}

$Template_FileTable = @{
    Path = ""
    Name = ""
}

function Get-CustomObject {
    param(
        [hashtable]$TemplateHash
    )

    return [pscustomobject]$TemplateHash
}

function Get-PropertyDiffObject {
    return Get-CustomObject -TemplateHash $Template_PropertyDiff
}

function Get-FileTableObject  {
    return Get-CustomObject -TemplateHash $Template_FileTable
}