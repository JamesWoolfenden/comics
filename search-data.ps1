
function Make-SearchData
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
      C:\PS> make-searchdata -title "The Walking Dead" -exclude "Poster" -include "Image"    
   #>
   Param(
   [string]$title,
   [string[]]$include=$null,
   [string[]]$exclude=$null,
   [string]$comictitle=$null,
   [string]$productcode=$null,
   [string[]]$category="8077",
   [Boolean]$Enabled=$true
   )
   
   New-Object PSObject -Property @{title=$title;include=$include;exclude=$exclude;comictitle=$comictitle;productcode=$productcode;category=$category;Enabled=$Enabled}
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
   [string]$include,
   [string]$exclude,
   [string]$comictitle,
   [string]$productcode,
   [string]$category,
   [Boolean]$Enabled
   )

   $datafile="$PSScriptRoot\search-data.json"
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $searches+=make-searchdata -title "$($title.ToUpper())" -exclude "$exclude" -include "$include" -comictitle $comictitle -productcode $productcode -category $category -Enabled $Enabled
   $searches|Sort-Object title| ConvertTo-Json -depth 999 | Out-File "$datafile"
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
   $datafile="$PSScriptRoot\search-data.json"
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
     $searches[$index].Exclude+=$exclude
   }

   if($include) 
   {
     $searches[$index].Include+=$include
   }

   $searches[$index].Exclude=$searches[$index].Exclude|sort -unique
   $searches[$index].Include=$searches[$index].Include|sort -unique

   write-debug "Index is $Index"
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
   $datafile="$PSScriptRoot\search-data.json"
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $index = [array]::IndexOf(($searches.title), $title)

   $searches[$index]
}   

function Remove-SearchData
{
   <#
      .SYNOPSIS 
       Removes a search object data when given its title
	       
      .PARAMETER title
	Specifies the comic title.
      .EXAMPLE
      C:\PS> Remove-searchdata -title "The Walking Dead" 
     
   #>

   throw "Function not implemented"
}

function Delete-SearchData
{
   <#
      .SYNOPSIS 
       Removes a complete search object when given its title
	       
      .PARAMETER title
	Specifies the comic title.
      .EXAMPLE
      C:\PS> Delete-SearchData -title "The Walking Dead" 
     
   #>

   throw "Function not implemented"
}
