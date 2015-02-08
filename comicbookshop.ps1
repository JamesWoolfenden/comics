import-module "$PSScriptRoot\core.ps1" -force

function get-comicbookshopdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$Record)

   if ($record.comictitle)
   {
      $title=$record.comictitle.ToUpper()
   }
   else
   {
      $title=$record.title.ToUpper()
   }
   
   $comic=$title.replace(" ","+")
   $search="&keyword=$comic"
   $site="Comic book shop"
   $fullfilter=$search
   $url="http://www.kimonolabs.com/api/azk3oj0y?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
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
      $cbsresults=Invoke-RestMethod -Uri $url
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }


   if ($cbsresults.lastrunstatus -eq "failure")
   {
      write-host "$(Get-Date) - Run Failed" -ForegroundColor Red
      return $null
   }
   
   $counter=0
   $comicbookshop=@()
   $results=$cbsresults.results.collection1
   
   $results=$results|where {$_.title.text -notmatch "vol"}
   $results=$results|where {$_.title.text -notmatch "T/S"}
   $results=$results|where {$_.title.text -notmatch "Novel"}

   foreach($result in $results)
   {
      $record= New-Object System.Object
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
  
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      
      #some encoding to sort
      $variant= ($result.title.text).replace("\u0026","&")
      $temp=$result.title.text
      $id=$temp.split(" ")[0]
      $temp=$temp.Replace("$id ","")

      if (($temp.split("#")).count -ne 1)
      {
         $issue=($temp.split("#")[1]).split(" ")[0]
      }
      else
      {
         $issue=$temp
      }

      $record| Add-Member -type NoteProperty -name title -value $title
      
      $rawprice=($result.price).Replace("Add:","")
      if (!$rawprice)
      {
         $rawprice="£0.00"
      }

      $price=get-price -price $rawprice.split(" ")[0]
  
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $cbsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value $site

      $comicbookshop+=$record
      $counter++
   }

   write-host "$(Get-Date) - Found $counter" 
   $comicbookshop
}