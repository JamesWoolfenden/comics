function get-fpdata()
{
   param ([string]$title="The Walking Dead")

   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&q=$comic+comics"
   $filter="&filter_instock=on"
   $size="&size=30"
   $fullfilter=$size+$filter+$search
   $url="http://www.kimonolabs.com/api/ca9vxpfa?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"Forbidden Planet`""

<# Postage
   1X  £1.00  1.00
   2X  £1.00  0.50 
   3X  £2.00  0.67
   4X  £2.00  0.50 
   5X  £2.00  0.40
   6X  $3.00  0.50
   7X  $3.00  0.43
   8X  $4.00  0.50
   9X  $4.00  0.44
   10X $4.00  0.40
   11X $5.50  0.55 
   50X $5.50  0.11
#>
   $fpresults=Invoke-RestMethod -Uri $url
   $results=$fpresults.results.collection1| where {$_.title -ne ""}
   $counter=0
   $fp=@()

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
      
      $record| Add-Member -type NoteProperty -name url -value $results[$counter].price.href[1]
      $record| Add-Member -type NoteProperty -name orderdate -value $results[$counter].orderdate.replace("before ","")
      $record| Add-Member -type NoteProperty -name title -value $title

      if ($results[$counter].title.text.Contains("#"))
      {
         $rawissue=$results[$counter].title.text.split("#")[1]
      }
      else
      {
         $rawissue=$results[$counter].title.text
      }

      if ($rawissue.Contains("("))
      {
         $rawissue=$rawissue.split("(?=()")
         $issue=$rawissue[0]
         $variant=$rawissue[1]
      }
      Else
      {
         $issue=$rawissue
         $variant=$rawissue
      }

      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $results[$counter].price.text[1]
      $record| Add-Member -type NoteProperty -name rundate -value $fpraw.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Forbidden Planet"
      
      $fp+=$record
      $counter++
   }
   
   write-host "Record $counter"
   
   $fp
}