function get-closeencountersdata()
{
   param ([string]$title="The Walking Dead")

#Parameter 	Default value 	Parameter to append
#kimpath1 	index.php 	&kimpath1=newvalue
#kimpath2 	catalogsearch 	&kimpath2=newvalue
#kimpath3 	result 	&kimpath3=newvalue
#cat 	0 	&cat=newvalue
#name 	manifest+destiny 	&name=newvalue
   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&name=$comic"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/9u9wvzya?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"Close Encounters`""

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
   $ceresults=Invoke-RestMethod -Uri $url
   
   if ($ceresults.lastrunstatus -eq "failure")
   {
      return $null
   }

   $counter=0
   $closeecounters=@()
   $results= $ceresults.results.collection1
   
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
      $record| Add-Member -type NoteProperty -name title -value $title

      $variant=(($results[$counter].title.text).ToUpper()).Replace("$title ","").replace("\u0026","&")
      $temp=$variant.Split(" ")
      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $results[$counter].price.Replace("£","")
      $record| Add-Member -type NoteProperty -name rundate -value $ceresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Close Encounters"

      $closeecounters+=$record
      $counter++
   }
   
   write-host "Record $counter"
   $closeecounters 
}