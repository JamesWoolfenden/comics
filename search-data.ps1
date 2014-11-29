
function make-searchdata
{
   Param(
   [string]$title,
   [string]$include=$null,
   [string]$exclude=$null,
   [string]$comictitle=$null,
   [string]$category="8077",
   [Boolean]$Enabled=$true
   )
   
   New-Object PSObject -Property @{title=$title;include=$include;exclude=$exclude;comictitle=$comictitle;category=$category;Enabled=$Enabled}
}

function add-searchdata
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title=$title.ToUpper(),
   [string]$include,
   [string]$exclude,
   [string]$comictitle,
   [string]$category,
   [Boolean]$Enabled
   )
   
  <#
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

   $datafile="$root\search-data.json"
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $searches+=make-searchdata -title "$title" -exclude "$exclude" -include "$include" -comictitle $comictitle -category $category -Enabled $Enabled
   $searches|Sort-Object title| ConvertTo-Json -depth 999 | Out-File "$datafile"
}

function set-searchdata
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [string]$include,
   [string]$exclude,
   [string]$comictitle,
   [string]$category,
   [switch]$Enabled,
   [switch]$Disabled
   )

  <#
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

   $title=$title.ToUpper()
   $datafile="$root\search-data.json"
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

   if ($category)
   {
      $searches[$index].category=$category
   }

   if($exclude) 
   {
     $searches[$index].Exclude=$($searches[$index].Exclude+" "+$exclude).trim()
   }

   write-debug "Index is $Index"
   $searches[$index]
   $searches| ConvertTo-Json -depth 999 | Out-File "$datafile"
}

function get-searchdata
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title)

   $title=$title.ToUpper()
   $datafile="$root\search-data.json"
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $index = [array]::IndexOf(($searches.title), $title)

   $searches[$index]
}   