import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function Get-ReedData
{
   param (   
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   $title     =$record.title.ToUpper()
   $comic     =$title.replace(" ","%20")
   $search    ="&keywords=$comic"
   $site      ="Reed Comics"
   $fullfilter=$search
   $url       ="https://www.kimonolabs.com/api/ondemand/b1awm6nu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"

   $results=Get-urltocomicarray -url $url -title $title -filters $record.exclude -site $site
  
   $counter=0
   $reed=@()
   $datetime=Get-date

   foreach ($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.cover.href)`">$($result.cover.href)</a>"
  
      $record| Add-Member -type NoteProperty -name link -value $result.cover.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $temp=($result.cover.alt).ToUpper()
      $temp=$temp.split("#")

      if ($temp.count -eq 1)
      {
         $newtitle=$title.trim()
         $issue=$temp.Replace("$title ","")
         $variant=$issue
      }
      else
      {
         $newtitle=($temp[0]).trim()
         $variant=$temp[1]
         $issue=$temp[1].split(" ")[0]
      }
      
      $price=(Get-price -price $result.price) -as [decimal]

      $record| Add-Member -type NoteProperty -name title -value $newtitle
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value "Reed"

      $reed+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $reed
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
