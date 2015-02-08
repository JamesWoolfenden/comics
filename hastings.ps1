import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\xrates.ps1" -force

function get-hastingsdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$Record,
   $dollarrate=(get-gbpdollarrate))
   
   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $keywords="&keywords=$comic"
   $site="Hastings"
   $url="https://www.kimonolabs.com/api/4frkfrdo?apikey=01f250503b7c40eb0ce695da7d74cbb1$keywords"

   write-debug "Accessing $url"
   write-Host "$(Get-Date) - Looking for $($record.title) @ `"$site`""
   
   try
   {
      $hastingsresults=invoke-restmethod -uri $url
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }

   if ($hastingsresults.lastrunstatus -eq "failure")
   {
      write-host "$(Get-Date) - Run Failed" -ForegroundColor Red
      return $null
   }

   $counter = 0
   $hastings= @()
   $results = $hastingsresults.results.collection1
   $arraytitle=$title.split(" ")

   foreach($part in $arraytitle)
   {
      $results = $results| where {$_.title.text -match $part}
   }
   
   foreach($result in $results)
   {
      $record= New-Object psobject
      $record.psobject.TypeNames.Insert(0, "ComicSearchResult")

      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title -value $title

      $variant=(($result.title.text).ToUpper()).Replace("$title ","").replace("\u0026","&")
      
      $temp=$variant.Split(" ")

      if ($result.price -is [system.array])
      {
         $price=get-price -price $result.price[1]
      }
      else
      {
         if ($result.price.contains(" "))
         {
            $tempprice=$result.price.Split(" ")
            $price=get-price -price $tempprice[1]
         }
         else
         {
            try
            {
                $price=get-price -price $result.price
            }     
            catch
            {
                write-warning "Price fail on Count $counter : $result)"
                $price=$null
            }       
         }
      }
         
	  $issue=get-numeric $temp[0]
      $inpounds=0

      try{
         $inpounds=[decimal]$price.amount*$dollarrate
      }
      catch
      {
         $inpounds=$null
      }
      
      $record| Add-Member -type NoteProperty -name issue   -value $issue 
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $inpounds
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate -value $hastingsresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value $site

      $hastings+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Record $counter"
   $hastings
}