import-module "$PSScriptRoot\core.ps1" -force

function get-comicbookstoredata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$Record)

#kimpath1 shop &kimpath1=newvalue 
#kimpath2 index.php &kimpath2=newvalue 
#main_page advanced_search_result &main_page=newvalue 
#search_in_description 0 &search_in_description=newvalue 
#zenid p8upjit25hl85tj35nuu9l9u46 &zenid=newvalue 
#keyword manifest+destiny &keyword=newvalue 
   
   $title=$Record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&q=$comic"
   $site="The Comic Book Store"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/9n2moou6?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-debug "Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"$site`""

<# Postage
   1X  �1.23 1.23
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
      write-host "$(Get-Date) - Run Failed" -ForegroundColor Red
      return $null
   }
   
   $counter=0
   $comicbookstore=@()
   $results=$cbsresults.results.collection1|where {$_.title.text -like "*$title*"}

   foreach($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
      $issue=($result.title.text).ToUpper()
      $issue=$issue -replace("$title ","")
      $issue=$issue -replace("#","")
      $variant=$issue
      $temp=$issue.split(" ")

      $price=get-price -price $result.price

      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value $site

      $comicbookstore+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter"
   $comicbookstore 
}