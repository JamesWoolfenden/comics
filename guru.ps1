function get-gurudata()
{
   param (
   [string]$title="The Walking Dead",
   [string]$productcode)


   $title=$title.ToUpper()
   $fullfilter="&product=$productcode"
   $url="http://www.kimonolabs.com/api/2gr32l5y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"The Comic Guru`""
  
<# Postage
   1X  £3.50  1.00
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
   $gururaw=Invoke-RestMethod -Uri $url
   $counter=0
   $guru=@()
   $results=$gururaw.results.collection1| where {$_.title -ne ""}
   switch ($results -is [system.array] )
   {
      $NULL 
      {
         return $NULL 
      }
      $true
      {
         #do nothing
      }
      $false 
      {
         $results = $results | Add-Member @{count="1"} -PassThru
      }
   }
   While($counter -ne $results.count)
   {
      $record= New-Object System.Object
      
      $record| Add-Member -type NoteProperty -name url -value "http://www.thecomicguru.co.uk"
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $temp=$results[$counter].issue -split("Stock:")
      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      [string]$variant=($temp[1]).trim
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $results[$counter].price.Replace("£","")
      $record| Add-Member -type NoteProperty -name rundate -value $gururaw.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "The Comic Guru"
      
      $guru+=$record
      $counter++
   }
   
   write-host "Record $counter"
   $guru
}