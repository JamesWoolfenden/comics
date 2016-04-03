import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function Get-comicbookshopdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$Record)

   if ($record.comictitle)
   {
      $title=$record.comictitle.ToUpper()
   }
   else
   {
      $title=$record.title.ToUpper()
   }
   
   $comic     =$title.replace(" ","+")
   $search    ="&keyword=$comic"
   $site      ="Comic book shop"
   $fullfilter=$search
   $url       ="https://www.kimonolabs.com/api/azk3oj0y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   
   $results   =Get-urltocomicarray -url $url -title $title -filters $record.exclude -site $site
  
   $counter=0
   $comicbookshop=@()

   $datetime=Get-date

   foreach($result in $results)
   {
      $record= New-Object psobject
      $record.psobject.TypeNames.Insert(0, "ComicSearchResult")
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
  
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      
      #some encoding to sort
      $variant= ($result.title.text).replace("\u0026","&")
      $temp=$result.title.text
      $id=$temp.split(" ")[0]
      $temp=$temp.Replace("$id ","")

      if (($temp.split("#")).count -ne 1)
      {
         $issue=($temp.split("#")[1]).split(" ")[0]
      }
      else
      {
         $issue=$temp
      }

      $record| Add-Member -type NoteProperty -name title -value $title
      
      $rawprice=($result.price).Replace("Add:","")
      if (!$rawprice)
      {
         $rawprice="�0.00"
      }

      $price=Get-price -price $rawprice.split(" ")[0]
  
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site

      $comicbookshop+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter" 
   $comicbookshop
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
