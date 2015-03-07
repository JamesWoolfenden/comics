import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function get-comicbizdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   if ($record.comictitle)
   {
      $title=$record.comictitle.ToUpper()
   }
   else
   {
      $title=$record.title.ToUpper()
   }
   
   $comic     =$title.replace(" ","%20")
   $search    ="&filter_name=$comic"
   $fullfilter=$search
   $site      ="The Comic Biz Store"
   $url       ="https://www.kimonolabs.com/api/ondemand/b1efn3xu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"

   $results   =get-urltocomicarray -url $url -title $title -filters $record.exclude -site $site
    
   $counter   =0
   $comicbiz  =@()
   $datetime  =Get-Date
   
   foreach($result in $results)
   {
      $record= New-Object psobject
      $record.psobject.TypeNames.Insert(0, "ComicSearchResult")
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
  
      $issue=get-coverdetails -rawissue $result.title.text     
      $price=get-price -price $result.price.split(" ")[0]

      $record| Add-Member -type NoteProperty -name issue -value $issue.cover
      $record| Add-Member -type NoteProperty -name variant -value $issue.variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site

      $comicbiz+=$record
      $counter++
   }

   write-host "$(Get-Date) - Record $counter"
   $comicbiz 
}

function get-coverdetails
{
   param (
   [Parameter(Mandatory=$true)]
   [string]$rawissue)

   write-verbose $rawissue
   $issue=$rawissue.ToUpper()
   $variant=$issue.trim()
   
   if($issue.contains("#"))
   { 
      $cover=($issue.split("#")[1]).split(" ")[0]
   }
   else
   {
      $cover=$issue
   }

   $issue= New-Object System.Object
   $issue| Add-Member -type NoteProperty -name cover -value $cover
   $issue| Add-Member -type NoteProperty -name variant -value $variant
   
   $issue
}

<# Postage
   1X  x x
   2X  x x
   3X  x x
   4X  x x
   5X  x x
   6X  x x
   7X  x x
   8X  x x
   9X  x x
   10X x x
   11X x x
   50X x x
#>