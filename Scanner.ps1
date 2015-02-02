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
import-Module "$PSScriptRoot\midtown.ps1" -force
import-Module "$PSScriptRoot\intercomics.ps1" -force
import-Module "$PSScriptRoot\comicxposure.ps1" -force
import-module "$PSScriptRoot\xrates.ps1" -force

function get-market
{
   param(
   [Parameter(Mandatory=$true)]
   [Psobject]$record)
   
   $allrecords=@()
   $filetitle=$record.title.replace(" ","")

   $dollarrate=get-gbpdollarrate

   $allrecords+=get-dcbsdata -record $record  -dollarrate $dollarrate
   $allrecords+=get-comicxposuredata -record $record -dollarrate $dollarrate
   $allrecords+=get-dhdata -record $record
   $allrecords+=get-closeencountersdata -record $record 
   $allrecords+=get-fpdata  -record $record  
   $allrecords+=get-reeddata -record $record
   $allrecords+=get-auctiondata -record $record
   $allrecords+=get-comicbizdata -record $record
   $allrecords+=get-comicbookshopdata -record $record
   $allrecords+=get-tfawdata -record $record
   $allrecords+=get-midtowndata -record $record
   $allrecords+=get-intercomicsdata -record $record

   If ($record.productcode -ne "")
   {
      $allrecords+=get-gurudata -title $record.title -productcode $record.productcode
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).json" -Encoding ascii
}

#retrieve data
get-dcbs
get-comicxposure

#load all unique title objects from Json file
$searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" |ConvertFrom-Json
#$searches=$searches|sort -Unique title
Write-Host "$(Get-Date) - Found $($searches.count)"

foreach ($record in $searches)
{
   if ($record.title -eq "The Walking dead")
   {
      $record.comictitle="WALKING DEAD"      
   }

   get-market $record
}

