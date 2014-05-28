function get-comicbookstoredata()
{
   param ([string]$title="Walking Dead")

#kimpath1 catalogsearch &kimpath1=newvalue 
#kimpath2 result &kimpath2=newvalue 
#kimpath3 index &kimpath3=newvalue 
#cat 120 &cat=newvalue 
#limit 99 &limit=newvalue 
#q manifest+destiny &q=newvalue 

   $comic=$title.replace(" ","+")
   $search="&q=$comic"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/9n2moou6?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "for $title from The comic book store"
  
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
   $counter=0
   $comicbookstore=@()

   $results=$cbsresults.results.collection1|where {$_.title.text -like "*$title*"}
  # $results=$results|where {$_.title.text -notlike "*book*"}
  # $results=$results|where {$_.title.text -notlike "*tpb*"}
  # $results=$results|where {$_.title.text -notlike "*t-shirt*"}
  # $results=$results|where {$_.title.text -notlike "*volume*"}


   While($counter -ne $results.count)
   {
      write-debug "Record $counter"
      $record= New-Object System.Object
  
      $record| Add-Member -type NoteProperty -name url -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $issue=$results[$counter].title.text
      $issue=$issue -replace("$title ","")
      $issue=$issue -replace("#","")
      $variant=$issue
      $temp=$issue.split(" ")

      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $results[$counter].price.Replace("�","")
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Comic Book Store"

      $comicbookstore+=$record
      $counter++
   }
   write-host "Record $counter"
   $comicbookstore 
}