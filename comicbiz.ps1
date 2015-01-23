import-module "$PSScriptRoot\core.ps1" -force

function get-comicbizdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   if ($record.comictitle)
   {
      $title=$record.comictitle.ToUpper()
   }
   else
   {
      $title=$record.title.ToUpper()
   }
   
   $comic=$title.replace(" ","%20")
   $search="&filter_name=$comic"
   $fullfilter=$search
   $site="The Comic Biz Store"
   $url="http://www.kimonolabs.com/api/b1efn3xu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-debug "Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"$site`""
  
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
   $comicbiz=@()
   $results=$cbsresults.results.collection1

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
      $record| Add-Member -type NoteProperty -name link -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title
  
      $issue=get-coverdetails -rawissue $results[$counter].title.text     
      $price=get-price -price $results[$counter].price.split(" ")[0]

      $record| Add-Member -type NoteProperty -name issue -value $issue.cover
      $record| Add-Member -type NoteProperty -name variant -value $issue.variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value $site

      $comicbiz+=$record
      $counter++
   }

   write-host "Record $counter"
   $comicbiz 
}

function get-coverdetails
{
   param (
   [Parameter(Mandatory=$true)]
   [string]$rawissue)

   Write-debug $rawissue
   $issue=$rawissue.ToUpper()
   $variant=$issue.trim()
   
   if($issue.contains("#"))
   { 
      $cover=($issue.split("#")[1]).split(" ")[0]
   }
   else
   {
      $cover=$issue
   }

   $issue= New-Object System.Object
   $issue| Add-Member -type NoteProperty -name cover -value $cover
   $issue| Add-Member -type NoteProperty -name variant -value $variant
   
   $issue
}