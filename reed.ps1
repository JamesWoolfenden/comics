import-module "$PSScriptRoot\core.ps1" -force

function get-reeddata
{
   param (   
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","%20")
   $search="&keywords=$comic"
   $site="Reed Comics"
   $fullfilter=$search
   $url="https://www.kimonolabs.com/api/ondemand/b1awm6nu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"

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

   $results=get-urltocomicarray -url $url -title $title -filters $record.exclude
  
   $counter=0
   $reed=@()

   $datetime=get-date

   foreach ($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.cover.href)`">$($result.cover.href)</a>"
  
      $record| Add-Member -type NoteProperty -name link -value $result.cover.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $temp=($result.cover.alt).ToUpper()
      $temp=$temp.split("#")

      if ($temp.count -eq 1)
      {
         $newtitle=$title.trim()
         $issue=$temp.Replace("$title ","")
         $variant=$issue
      }
      else
      {
         $newtitle=($temp[0]).trim()
         $variant=$temp[1]
         $issue=$temp[1].split(" ")[0]
      }
      
      $price=(get-price -price $result.price) -as [decimal]

      $record| Add-Member -type NoteProperty -name title -value $newtitle
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value "Reed"

      $reed+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $reed
}


function get-urltocomicarray
{
   param(
   [string]$url,
   [string]$title,
   [string[]]$filters)

   $result=$null

   try
   {
      $rawresults=Invoke-RestMethod -Uri $url  
      $results=$rawresults.results.collection1| where {$_.title -ne ""}
      
      #title filters
      foreach($filter in $filters)
      {
         $results=$results| where {$_.title.text -notmatch "$filter"}
      }

      #pricefilters
      $results=$results| where {$_.price -ne ""}

      if ($results -eq $null)
      {
         throw
      }
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
   }

   $results
}