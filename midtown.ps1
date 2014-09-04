function get-midtowndata()
{
   param ([string]$title="The Walking Dead")



<#curl --include --request GET "https://www.kimonolabs.com/api/2y1kpohc?apikey=01f250503b7c40eb0ce695da7d74cbb1"

Please remember to include your API key with each call to your API.
URL Parameters

http://www.midtowncomics.com/ store / search.asp ? q=walking+dead & cat=61 & sh=100 & reld=1/1/1900 & reld2=1/1/1900 & furl=pl
Parameter 	Default value 	Parameter to append
kimpath1 	store 	&kimpath1=newvalue
kimpath2 	search.asp 	&kimpath2=newvalue
q 	walking+dead 	&q=newvalue
cat 	61 	&cat=newvalue
sh 	100 	&sh=newvalue
reld 	1/1/1900 	&reld=newvalue
reld2 	1/1/1900 	&reld2=newvalue
furl 	pl
#>   
   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&q=$comic"
   $fullfilter=$search
   $url="https://www.kimonolabs.com/api/2y1kpohc?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-debug "Accessing $url"
   write-Host "Looking for $title @ `"Midtown`""
  
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
   $comicbookstore=@()
   $results=$cbsresults.results.collection1|where {$_.title.text -like "*$title*"}

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