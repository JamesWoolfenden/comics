import-module "$PSScriptRoot\auction.ps1" -force
import-module "$PSScriptRoot\closeencounters.ps1" -force
import-module "$PSScriptRoot\comicbookstore.ps1" -force
import-module "$PSScriptRoot\fp.ps1" -force
import-module "$PSScriptRoot\guru.ps1"  -force
import-module "$PSScriptRoot\reed.ps1" -force
import-module "$PSScriptRoot\comicbookshop.ps1" -force
import-Module "$PSScriptRoot\disposableheroes.ps1" -force
import-Module "$PSScriptRoot\comicbiz.ps1" -force
import-Module "$PSScriptRoot\tfaw.ps1" -force
import-Module "$PSScriptRoot\dcbs.ps1" -force

function get-market
{
   param(
   [Psobject]$record)
   
   $allrecords=@()
   $filetitle=$record.title.replace(" ","")
  
   $allrecords+=get-dhdata -title $record.title
   $allrecords+=get-closeencountersdata -title $record.title 
   $allrecords+=get-fpdata  -title $record.title  
   $allrecords+=get-reeddata -title $record.title 
   $allrecords+=get-auctiondata -title $record.title
   #$allrecords+=get-comicbizdata -title $record.title 

   if ($record.comictitle)
   {
      write-Host "Using Alternative title $($record.comictitle)"
      $allrecords+=get-comicbookshopdata  -title $record.comictitle
      #$allrecords+=get-comicbookstoredata -title $record.comictitle
      $allrecords+=get-tfawdata -title $record.comictitle
      $allrecords+=get-comicbizdata -title $record.comictitle 
      $allrecords+=get-dcbsdata -title $record.comictitle
   }
   else
   {
      write-Host "Using Original title $($record.title)"
      $allrecords+=get-comicbookshopdata  -title $record.title
      #$allrecords+=get-comicbookstoredata -title  $record.title 
      $allrecords+=get-tfawdata -title $record.title
      $allrecords+=get-dcbsdata -title $record.title  
   }
   
   If ($record.productcode -ne "")
   {
      $allrecords+=get-gurudata -title $record.title -productcode $record.productcode
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).json" -Encoding ascii
}

#retrieve data
get-dcbs

#load all unique title objects from Json file
$searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" |ConvertFrom-Json
$searches=$searches|Select-Object title -unique
Write-Host "$(Get-Date) - Found $($searches.count)"

foreach ($record in $searches)
{
   if ($record.title -eq "The Walking dead")
   {
      $record.comictitle="WALKING DEAD"      
   }

   get-market $record
}

