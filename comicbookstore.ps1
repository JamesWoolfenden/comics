function get-comicbookstoredata()
{
   param ([string]$title="The Walking Dead")

#kimpath1 shop &kimpath1=newvalue 
#kimpath2 index.php &kimpath2=newvalue 
#main_page advanced_search_result &main_page=newvalue 
#search_in_description 0 &search_in_description=newvalue 
#zenid p8upjit25hl85tj35nuu9l9u46 &zenid=newvalue 
#keyword manifest+destiny &keyword=newvalue 

   $comic=$title.replace(" ","+")
   $search="&q=$comic"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/9n2moou6?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"The Comic Book Store`""
  
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

   While($counter -ne $results.count)
   {
      write-debug "Record $counter"
      $record= New-Object System.Object
  
      $record| Add-Member -type NoteProperty -name url -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $issue=($results[$counter].title.text).ToUpper()
      $issue=$issue -replace("$title ","")
      $issue=$issue -replace("#","")
      $variant=$issue
      $temp=$issue.split(" ")

      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $results[$counter].price.Replace("£","")
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Comic Book Store"

      $comicbookstore+=$record
      $counter++
   }

   write-host "Record $counter"
   $comicbookstore 
}