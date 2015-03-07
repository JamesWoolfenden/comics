import-module "$PSScriptRoot\core.ps1" -force

function get-closeencountersdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

#Parameter 	Default value 	Parameter to append
#kimpath1 	index.php 	&kimpath1=newvalue
#kimpath2 	catalogsearch 	&kimpath2=newvalue
#kimpath3 	result 	&kimpath3=newvalue
#cat 	0 	&cat=newvalue
#name 	manifest+destiny 	&name=newvalue
   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&name=$comic"
   $site="Close Encounters"
   $fullfilter=$search+"&limit=30"
   #$url="http://www.kimonolabs.com/api/9u9wvzya?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   $url="https://www.kimonolabs.com/api/ondemand/9u9wvzya?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"

   write-verbose "Accessing $url"
   write-Host "$(Get-Date) - Looking for $($record.title) @ `"$site`""

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
   $counter=0
   $closeencounters=@()
   
   try
   {
      $ceresults=Invoke-RestMethod -Uri $url
      $results= $ceresults.results.collection1
      
      if ($results -eq $null)
      {
         throw
      }
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }

   $arraytitle=$title.split(" ")

   $datetime=Get-Date
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

      $record| Add-Member -type NoteProperty -name issue -value $temp[0]
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price.Amount
      $record| Add-Member -type NoteProperty -name currency -value $price.Currency
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site

      $closeencounters+=$record
      $counter++
   }
   
   write-host "$(Get-Date) - Found $counter"
   $closeencounters 
}