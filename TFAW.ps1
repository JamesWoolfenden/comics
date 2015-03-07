import-module "$PSScriptRoot\core.ps1" -force

function get-tfawdata
{
   param (
      [Parameter(Mandatory=$true)]
      [PSObject]$record,
      $dollarrate=(get-gbpdollarrate))
 
  <#
   .SYNOPSIS 
   Retrieves TFAW records for a title
	    
   .EXAMPLE
    C:\PS> get-tfawdata -title "The Walking Dead" 
    retieves and parses TFAW records
 #>

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

   $limit=100
   
   if ($record.comictitle)
   {
      $title=$record.comictitle.ToUpper()
   }
   else
   {
      $title=$record.title.ToUpper()
   }

   $comic=$title.replace(" ","%2B")
   $kimpath2="_results_limit_search=$limit"
   $kimpath4="_results_sstring_search=$comic"

   $kimpath5=0
   $results=@()  
   
   $site="TFAW"

   write-host "$(Get-Date) - Looking for $title @ `"$site`""

   do
   {
      write-verbose "$(get-date) - Count $($kimpath5.ToString())"
      $search="&kimpath2=$kimpath2&kimpath4=$kimpath4&kimpath5=_results_start_at_search=$($kimpath5.ToString())"

      $fullfilter=$search
      $url="https://www.kimonolabs.com/api/ondemand/7fuasgeu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
      write-verbose "$(Get-Date) - Accessing $url"
  
      try{
         $tfawresults=Invoke-RestMethod -Uri $url
	  }
      catch
      {
         Write-Warning "$(Get-Date) No data returned from $url"
         return $null
      }
   
      $results+=$tfawresults.results.collection1|where {$_.title.text -like "*$title*"}
      $kimpath5+=$limit
   }
   while($tfawresults.results.collection1.count -eq $limit)

   $tfaw=@()
   $counter=0
   $datetime=get-date

   Foreach($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      
      $record| Add-Member -type NoteProperty -name link      -value $result.title.href
      $record| Add-Member -type NoteProperty -name url       -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title     -value $title

      write-verbose "$($result.title.text)"
      $issue=($result.title.text).ToUpper()
      $issue=$issue -replace("$title ","")
      $issue=$issue -replace("#","")
      $variant=$issue
      $temp=$issue.split(" ")
      
      $price=get-price -price  ($result.price).split(" ")[0]
      $price=[decimal]$price.Amount*$dollarrate

      $record| Add-Member -type NoteProperty -name issue    -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant  -value $variant
      $record| Add-Member -type NoteProperty -name price    -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate  -value $datetime
      $record| Add-Member -type NoteProperty -name site     -value $site

      $tfaw+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter"
   $tfaw 
}