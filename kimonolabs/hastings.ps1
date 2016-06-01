import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\xrates.psd1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function Get-hastingsdata
{
   param (
   [Parameter(Mandatory=$true)]
   [PSObject]$Record,
   $dollarrate=(Get-gbpdollarrate))
   
   $title     =$record.title.ToUpper()
   $comic     =$title.replace(" ","+")
   $keywords  ="&keywords=$comic"
   $site      ="Hastings"
   $url       ="https://www.kimonolabs.com/api/4frkfrdo?apikey=01f250503b7c40eb0ce695da7d74cbb1$keywords"

   $results   =Get-urltocomicarray -url $url -title $title -filters $record.exclude -site $site
  
   $counter = 0
   $hastings= @()

   $arraytitle=$title.split(" ")

   foreach($part in $arraytitle)
   {
      if ($results)
      {
          $results = $results| where {$_.title.text -match $part}
      }
   }
   
   $datetime=Get-date

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
         $price=Get-price -price $result.price[1]
      }
      else
      {
         if ($result.price.contains(" "))
         {
            $tempprice=$result.price.Split(" ")
            $price=Get-price -price $tempprice[1]
         }
         else
         {
            try
            {
                $price=Get-price -price $result.price
            }     
            catch
            {
                Write-Warning "Price fail on Count $counter : $result)"
                $price=$null
            }       
         }
      }
         
      $issue=Get-numeric $temp[0]
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
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site

      $hastings+=$record
      $counter++
   }
   
   Write-Host "$(Get-Date) - Record $counter"
   $hastings
}