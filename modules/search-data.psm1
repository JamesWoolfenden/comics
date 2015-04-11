$script:datafile="$PSScriptRoot\..\search-data.json"


function Initialize-SearchData
{<#
      .SYNOPSIS 
    Given some string properties this returns a search csutom object             
      .PARAMETER title
    Specifies the comic title.
      .PARAMETER include
    Optional  specifies any additional search strings.
      .PARAMETER exclude
    Optional specifies any terms to exclude by
      .PARAMETER comictitle
    An alterative title 
      .PARAMETER category
    An optional ebid category parameter 
      .PARAMETER Enabled
    Enables or Disables its use in the scan
    .EXAMPLE
      C:\PS> Initialize-searchdata -title "The Walking Dead" -exclude "Poster" -include "Image"    
   #>
   Param(
   [string]$title,
   [string[]]$include=@(""),
   [string[]]$exclude=@(""),
   [string]$comictitle=$null,
   [string]$productcode=$null,
   [string[]]$category=@("8077"),
   [Boolean]$Enabled=$true)
   
   New-Object PSObject -Property @{title=$title;include=[string[]]$include;exclude=[string[]]$exclude;comictitle=$comictitle;productcode=$productcode;category=[string[]]$category;Enabled=$Enabled}
}

function Add-SearchData
{<#
      .SYNOPSIS 
    Adds an item to the scan search db	       
      .PARAMETER title
    Specifies the comic title.
      .PARAMETER include
    Optional  specifies any additional search strings.
      .PARAMETER exclude
    Optional specifies any terms to exclude by
      .PARAMETER comictitle
    An alterative title 
      .PARAMETER category
    An optional ebid category parameter 
      .PARAMETER Enabled
    Enables or Disables its use in the scan
    .EXAMPLE
      C:\PS> add-searchdata -title "The Walking Dead" -exclude "Poster" -include "Image"    
   #>

   Param(
   [Parameter(Mandatory=$true)]
   [string]$title=$title.ToUpper(),
   [string[]]$include=@(""),
   [string[]]$exclude=@(""),
   [string]$comictitle,
   [string]$productcode,
   [string[]]$category=@("8077"),
   [switch]$Enabled,
   [switch]$duplicate)
   
   [boolean]$searchEnabled=$false|out-null
   
   if($enabled)
   {
      $searchEnabled=$true
   }

   if (!(get-searchdata -title $title) -replace $duplicate)
   {
      $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
      $search=Initialize-searchdata -title "$($title.ToUpper())" -exclude $exclude -include $include -comictitle $comictitle -productcode $productcode -category $category -Enabled $searchEnabled
      $searches+=$search
      $searches|Sort-Object title| ConvertTo-Json -depth 999 | Out-File "$datafile"
      $search
   }
   else
   { 
      Write-Error "Cannot add duplicate"
   }
}

function Set-SearchData
{  
  <#
      .SYNOPSIS 
       updates an item to the scan search db
           
      .PARAMETER title
    Specifies the comic title.
      .PARAMETER include
    Optional  specifies any additional search strings.
      .PARAMETER exclude
    Optional specifies any terms to exclude by
      .PARAMETER comictitle
    An alterative title 
      .PARAMETER category
    An optional ebid category parameter 
      .PARAMETER Enabled
    Enables or Disables its use in the scan
        
      .EXAMPLE
      C:\PS> add-searchdata -title "The Walking Dead" -exclude "Poster" -include "Image"
     
   #>

   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [string]$include,
   [string]$exclude,
   [string]$comictitle,
   [string]$productcode,
   [string]$category,
   [switch]$Enabled,
   [switch]$Disabled
   )

   $title=$title.ToUpper()
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json

   $index = [array]::IndexOf(($searches.title), $title)
   
   if ($Enabled)
   {
      $searches[$index].Enabled=$true
   }

   if ($Disabled)
   {
      $searches[$index].Enabled=$false
   }
   
   if($productcode) 
   {
     $searches[$index].productcode+=$productcode
   }

   if ($category)
   {
      $searches[$index].category=$category
   }

   if($exclude) 
   {
     if ($searches[$index].Exclude -is [string])
     {
        
     }
     $searches[$index].Exclude+=$exclude
   }

   if($include) 
   {
     $searches[$index].Include+=$include
   }

   $searches[$index].Exclude=$searches[$index].Exclude|sort -unique
   $searches[$index].Include=$searches[$index].Include|sort -unique

   write-verbose "Index is $Index"
   $searches[$index]
   $searches| ConvertTo-Json -depth 999 | Out-File "$datafile"
}

function Get-SearchData
{
   <#
      .SYNOPSIS 
       returns a search object when given its title
           
      .PARAMETER title
    Specifies the comic title.
      .EXAMPLE
      C:\PS> get-searchdata -title "The Walking Dead" 
     
   #>
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title)

   $title=$title.ToUpper()
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $index = [array]::IndexOf(($searches.title), $title)
   
   if ($index -ge 0)
   {
      $searches[$index]
   }
   else
   {
      $null
   }
}   

function remove-SearchData
{
   <#
      .SYNOPSIS 
       Removes a complete search object when given its title
           
      .PARAMETER title
    Specifies the comic title.
      .EXAMPLE
      C:\PS> remove-SearchData -title "The Walking Dead" 
     
   #>

   throw "Function not implemented"
}
