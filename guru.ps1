import-module "$PSScriptRoot\core.ps1" -force

function get-gurudata
{
   param (
   [string]$title="The Walking Dead",
   [string]$productcode)


   $title=$title.ToUpper()
   $fullfilter="&product=$productcode"
   $site="The Comic Guru"
   $url="http://www.kimonolabs.com/api/2gr32l5y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-debug "$(Get-Date) - Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"$site`""
  
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
   try
   {
      $gururesults=Invoke-RestMethod -Uri $url
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }
   
   if ($gururesults.lastrunstatus -eq "failure")
   {
      return $null
   }
   
   $results=$gururesults.results.collection1
   $counter=0
   $guru=@()
   
   
   foreach($result in $results)
   {
      $record= New-Object System.Object
      $record| Add-Member -type NoteProperty -name link -value "http://www.thecomicguru.co.uk"
      $record| Add-Member -type NoteProperty -name url -value "<a href=`"http://www.thecomicguru.co.uk/item.php?product=$productcode`">http://www.thecomicguru.co.uk/item.php?product=$productcode</>"
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $temp=$result.issue -split("Stock:")
      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      [string]$variant=($temp[1]).trim()
      $record| Add-Member -type NoteProperty -name variant -value $variant

      $price=($result.price.Replace("£","")) -as [decimal]
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $gururesults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value $site
      
      $guru+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $guru
}