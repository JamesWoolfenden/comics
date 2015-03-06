import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function get-gurudata
{
   param (
   [PSObject]$record)


   $title      =$record.title.ToUpper()
   $fullfilter ="&product=$record.productcode"
   $site       ="The Comic Guru"
   $url        ="https://www.kimonolabs.com/api/ondemand/2gr32l5y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   $gururesults=get-urltocomicarray -url $url -title $title -filters $record.exclude -site $site
      
   $counter=0
   $guru=@()
   
   $datetime=get-date

   foreach($result in $results)
   {
      $record= New-Object System.Object
      $record| Add-Member -type NoteProperty -name link -value "http://www.thecomicguru.co.uk"
      $record| Add-Member -type NoteProperty -name url -value "<a href=`"http://www.thecomicguru.co.uk/item.php?product=$($record.productcode)`">http://www.thecomicguru.co.uk/item.php?product=$($record.productcode)</>"
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $temp=$result.issue -split("Stock:")
      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      [string]$variant=($temp[1]).trim()
      $record| Add-Member -type NoteProperty -name variant -value $variant

      $price=($result.price.Replace("£","")) -as [decimal]
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site
      
      $guru+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $guru
}

<# Postage
   1X  £3.50  3.50
   2X  £3.65  1.825
   3X  £3.80  1.27
   4X  £3.95  0.99 
   5X  £4.10  0.82
   6X  $4.25  0.71
   7X  $4.40  0.63
   8X  $4.55  0.50
   9X  $4.70  0.52
   10X $4.85  0.485
   11X $5.00  0.45 
   50X $11.00  0.22
#>

