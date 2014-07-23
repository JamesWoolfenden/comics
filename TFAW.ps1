$corescript=$myinvocation.mycommand.path
$root=split-path -parent  -Path $corescript

import-module "$root\core.ps1" -force
function get-tfawdata()
{
   param ([string]$title="The Walking Dead")

#URL Parameters

#http://www.tfaw.com/ Search / _results_limit_search=30 / _results_order_search=title / _results_sstring_search=walking%2Bdead / _results_start_at_search=30 /
#Parameter 	Default value 	Parameter to append
#kimpath1 	Search 	&kimpath1=newvalue
#kimpath2 	_results_limit_search=30 	&kimpath2=newvalue
#kimpath3 	_results_order_search=title 	&kimpath3=newvalue
#kimpath4 	_results_sstring_search=walking%2Bdead 	&kimpath4=newvalue
#kimpath5 	_results_start_at_search=30 	&kimpath5=newvalue
   
   $title=$title.ToUpper()
   $comic=$title.replace(" ","%2B")
   $kimpath2="_results_limit_search=100"
   $kimpath4="_results_sstring_search=$comic"
   $search="&kimpath2=$kimpath2&kimpath4=$kimpath4"
   $site="TFAW"
   $fullfilter=$search
   $url="https://www.kimonolabs.com/api/7fuasgeu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"$site`""
  
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
   $tfawresults=Invoke-RestMethod -Uri $url
   if ($tfawresults.lastrunstatus -eq "failure")
   {
     throw "No records found"
   }
   
   $counter=0
   $tfaw=@()
   $results=$tfawresults.results.collection1|where {$_.title.text -like "*$title*"}

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
      $url="<a href=`"$($results[$counter].title.href)`">$($results[$counter].title.href)</a>"
      
      $record| Add-Member -type NoteProperty -name link      -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name url       -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title     -value $title

      write-debug "$($results[$counter].title.text)"
      $issue=($results[$counter].title.text).ToUpper()
      $issue=$issue -replace("$title ","")
      $issue=$issue -replace("#","")
      $variant=$issue
      $temp=$issue.split(" ")
      
      $price=get-price -price  ($results[$counter].price).split(" ")[0]

      $record| Add-Member -type NoteProperty -name issue    -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant  -value $variant
      $record| Add-Member -type NoteProperty -name price    -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate  -value $tfawresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site     -value $site

      $tfaw+=$record
      $counter++
   }

   write-host "Record $counter"
   $tfaw 
}