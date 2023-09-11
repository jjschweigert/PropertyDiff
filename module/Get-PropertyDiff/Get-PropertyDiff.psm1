<#
.Synopsis
Show chronological changes of propety key/value sets across files

.Description
Generates a table showing how values change across provided files, assuming they are provided in correct chronological order

.Parameter FilePaths
List of files in chronological order

.Parameter PropertyNameValueDelimiter
The character used to differentiate the property name from value

.Parameter PropertyDelimiter
The character used to differentiate each property

.Example
# Providing 3 files in the form name=value where each property is on a new line
Get-PropertyDiff -FilePaths @("C:\data\jan.txt", "C:\data\feb.txt", "C:\data\mar.txt") -PropertyNameValueDelimiter "=" -PropertyDelimiter "`n"
#>

function Get-PropertyDiff {
    param(
        [PSCustomObject[]]$FilePaths, # Get-FileTableObject
        [string]$PropertyNameValueDelimiter,
        [string]$PropertyDelimiter
    )

    $propCollections = Get-PropertyHash -FilePaths $FilePaths -PropertyNameValueDelimiter $PropertyNameValueDelimiter -PropertyDelimiter $PropertyDelimiter
    $propDiffCollection = New-Object System.Collections.ArrayList
    $propDiffObjSrc = Get-PropertyDiffObject

    for(($collection = 0); ($collection -lt $propCollections.Count); $collection++)
    {
        $collectionName = $FilePaths[$collection]
        $propCollection = $propCollections[$collection]

        foreach($prop in $propCollection.Keys)
        {
            # ERROR HERE
            $existingPropIndex = Find-PropertyExists -Collection $propDiffCollection -PropertyName $prop

            if($existingPropIndex -lt 0)
            {
                if($propDiffCollection.Count -gt 0)
                {
                    # Snapshot the current object state
                    $snapshot = $propDiffCollection[-1]

                    # Need to first add the existing properties to match current objects and then add the new property
                    $newPropertyObj = Get-PropertyObj -SourceObject $propDiffObjSrc
                    $newPropertyObj.Name = $prop
                    Update-ObjectWithNewProperty -ExistingObject $newPropertyObj -PropertyName $collectionName -PropertyValue $propCollection[$prop]
                    Set-ObjectClone -ObjectSource $snapshot -ObjectDestination $newPropertyObj
                    
                    # Update existing objects with new property and then add the new property so the value is not overwritten
                    Update-CollectionWithNewProperty -Collection $propDiffCollection -NewPropertyName $collectionName -NewPropertyValue ""
                    $propDiffCollection.Add($newPropertyObj)
                }
                else
                {
                    # List is empty, just add object with single propety value
                    $newPropertyObj = Get-PropertyObj -SourceObject $propDiffObjSrc
                    $newPropertyObj.Name = $prop
                    Update-ObjectWithNewProperty -ExistingObject $newPropertyObj -PropertyName $collectionName -PropertyValue $propCollection[$prop]
                    
                    $propDiffCollection.Add($newPropertyObj)
                }
            }
            else
            {
                # Update existing object - ERROR HERE
                $propExistingObj = $propDiffCollection[$existingPropIndex]
                Update-ObjectWithNewProperty -ExistingObject $propExistingObj -PropertyName $prop -PropertyValue $propCollections[$prop]
            }
        }
    }
}

function Set-ObjectClone
{
    param(
        [pscustomobject]$ObjectSource,
        [pscustomobject]$ObjectDestination
    )

    $ObjectSource | Get-Member -MemberType Properties | ForEach-Object Name | ForEach-Object
    {
        Add-Member -InputObject $ObjectDestination -MemberType NoteProperty -Name $_ -Value ""
    }
}

function Update-CollectionWithNewProperty {
    param(
        [pscustomobject[]]$Collection,
        [string]$NewPropertyName,
        [string]$NewPropertyValue
    )

    foreach($obj in $Collection)
    {
        Add-Member -InputObject $obj -MemberType NoteProperty -Name $NewPropertyName -Value $NewPropertyValue
    }
}

function Update-ObjectWithNewProperty {
    param(
        [pscustomobject]$ExistingObject,
        [string]$PropertyName,
        [string]$PropertyValue
    )
    
    Add-Member -InputObject $ExistingObject -MemberType NoteProperty -Name $PropertyName -Value $PropertyValue
}

function Find-PropertyExists {
    param(
        [PSCustomObject[]]$Collection,
        [String]$PropertyName
    )

    for(($obj = 0); ($obj -lt $Collection.Count); $obj++)
    {
        if(Get-Member -InputObject $Collection[$obj] -Name $PropertyName -MemberType Properties)
        {
            return $obj
        }
    }

    return -1
}

function Get-PropertyObj {
    param(
        [PSCustomObject]$SourceObject
    )

    return $SourceObject | Select-Object -Property *
}

function Get-PropertyHash {
    param(
        [PSCustomObject[]]$FilePaths,
        [string]$PropertyNameValueDelimiter,
        [string]$PropertyDelimiter
    )

    $propCollections = New-Object System.Collections.ArrayList

    foreach($file in $FilePaths)
    {
        $splitProps = Split-Properties -FilePath $file.Path -Delimiter $PropertyDelimiter
        $propHash = @{}

        foreach($propKeyValue in $splitProps)
        {
            $kvp = Split-PropertyNameValue -Property $propKeyValue -Delimiter $PropertyNameValueDelimiter
            $propHash[$kvp[0]] = $kvp[1]
        }

        $propCollections.Add($propHash)
    }

    return $propCollections.ToArray()
}

function Split-Properties {
    param(
        [string]$FilePath,
        [string]$Delimiter
    )

    return (Get-Content $FilePath) -split $Delimiter
}

function Split-PropertyNameValue {
    param(
        [string]$Property,
        [string]$Delimiter
    )

    return $Property -split $Delimiter
}

function Get-Analytics {
    param(
        [PSCustomObject[]]$Results
    )
}