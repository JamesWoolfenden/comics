import-module "$PSScriptRoot\core.ps1" -force

function get-reeddata
{
   param (   
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   #Parameter 	Default value 	Parameter to append
   #kimpath1 	advanced_search_result.php 	&kimpath1=newvalue
   #keywords 	manifest%20destiny 	&keywords=newvalue
   #sort 	2a 	&sort=newvalue
   #listing 	1000 	&listing=newvalue
   #osCsid 	pv7c5rk4j1u0p83fpanlr1oc63 	&osCsid=newvalue
   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","%20")
   $search="&keywords=$comic"
   $site="Reed Comics"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/b1awm6nu?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
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
   try
   {
      $reedresults=Invoke-RestMethod -Uri $url
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }
   
   if ($reedresults.lastrunstatus -eq "failure")
   {
      write-host "$(Get-Date) - Run Failed" -ForegroundColor Red
      return $null
   }

   $counter=0
   $reed=@()
   $results=$reedresults.results.collection1| where {$_.title -ne ""}
   $results=$results| where {$_.price -ne ""}
   $results=$results| where {$_.title.text -notmatch "novel"}
   $results=$results| where {$_.title.text -notmatch "Volume"}
   
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
      $record| Add-Member -type NoteProperty -name rundate -value $reedresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Reed"

      $reed+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $reed
}