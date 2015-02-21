function get-midtowndata
{
   param (   
   [Parameter(Mandatory=$true)]
   [PSObject]$record,
   $dollarrate=(get-gbpdollarrate))

set-strictmode -Version Latest

<#curl --include --request GET "https://www.kimonolabs.com/api/925e0u00?apikey=01f250503b7c40eb0ce695da7d74cbb1"
Please remember to include your API key with each call to your API.

URL PARAMETERS 

When you use URL parameters, your API will disregard any crawling strategy and extract data at the time of your crawl (temporarily overriding any other settings previously set for this API).

http://www.midtowncomics.com/ store / search.asp ? pl=16 & q=walking+dead

PARAMETER	DEFAULT VALUE	PARAMETER TO APPEND
kimpath1	store	&kimpath1=newvalue
kimpath2	search.asp	&kimpath2=newvalue
pl	16	&pl=newvalue
q	walking+dead	&q=newvalue
#>   
   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&q=$comic"
   $fullfilter=$search
   $url="https://www.kimonolabs.com/api/925e0u00?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-debug "$(Get-Date) - Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"Midtown`""
  
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
   try{
      $midtownresults=Invoke-RestMethod -Uri $url
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }
   
   if ($midtownresults.lastrunstatus -eq "failure")
   {
      write-host "$(Get-Date) - Run Failed" -ForegroundColor Red
      return $null
   }
   
   $counter=0
   $comicbooks=@()
   $results=$midtownresults.results.collection1
   $datetime=get-date

   foreach($result in $results)
   {
      $record= New-Object System.Object

      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
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
      if ($strprice.contains('$'))
      {
         $price=($strprice.split('$'))[1]
      }
      else{
         $price=$strprice
      }

      $price=[decimal]$price*$dollarrate

      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value "Midtown"

      $comicbooks+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter"
   $comicbooks
}