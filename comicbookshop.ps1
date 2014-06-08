function get-comicbookshopdata()
{
   param ([string]$title="Walking Dead")

   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&keyword=$comic"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/azk3oj0y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"The Comic Book Shop`""
  
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
   $cbsresults=Invoke-RestMethod -Uri $url
   if ($cbsresults.lastrunstatus -eq "failure")
   {
      return $null
   }
   
   $counter=0
   $comicbookshop=@()
   $results=$cbsresults.results.collection1
   
   $results=$results|where {$_.title.text -notmatch "vol"}
   $results=$results|where {$_.title.text -notmatch "T/S"}
   $results=$results|where {$_.title.text -notmatch "Novel"}

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
      default
      {
         return $NULL
      }
   }

   While($counter -ne $results.count)
   {
      $record= New-Object System.Object
  
      $record| Add-Member -type NoteProperty -name url -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $variant= $results[$counter].title.text
      $temp=$results[$counter].title.text
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
      $price=($results[$counter].price.Replace("£","")).Replace("Add:","")
  
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Comic Book Shop"

      $comicbookshop+=$record
      $counter++
   }

   write-host "Record $counter"
   
   $comicbookshop
}