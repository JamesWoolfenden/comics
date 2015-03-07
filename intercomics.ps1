function get-intercomicsdata
{
   param (   
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   set-strictmode -Version Latest

   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $fullfilter="&kimpath3=$comic"

   #$url="https://www.kimonolabs.com/api/aq2ee2f2?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   $url="https://www.kimonolabs.com/api/ondemand/aq2ee2f2?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-verbose "$(Get-Date) - Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"Intercomics`""
  
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
   try
   {
      $intercomicsresults=Invoke-RestMethod -Uri $url 
      $results=$intercomicsresults.results.collection1
      if ($results -eq $null)
      {
         throw
      }
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }
   
   $counter=0
   $intercomics=@()
   $datetime=get-date

   foreach($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      $record| Add-Member -type NoteProperty -name link  -value $result.title.href
      $record| Add-Member -type NoteProperty -name url   -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $rawissue=($result.title.text).ToUpper()

      if($rawissue.contains("#"))
      {
         $variant=($rawissue -split("#"))[1]
         $issue=($variant -split(" "))[0]
      }
      else{
         $variant=$rawissue
         $issue=$rawissue
      }

      $strprice=($result.price -split("\n"))[0]
      $price=($strprice.split('£'))[1]
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value "Intercomics"

      $intercomics+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter"
   $intercomics
}