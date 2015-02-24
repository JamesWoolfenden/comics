import-module "$PSScriptRoot\auction.ps1" -force
import-module "$PSScriptRoot\closeencounters.ps1" -force
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
import-module "$PSScriptRoot\modules\xrates.psd1" -force
import-module "$PSScriptRoot\hastings.ps1" -force

function get-market
{
   param(
   [Parameter(Mandatory=$true)]
   [Psobject]$record,
   [decimal]$dollarrate=(get-gbpdollarrate))
   
   $start=get-date
   $elapsed =new-timespan -seconds 60 
   $endtime=$start+$elapsed

   $allrecords=@()
   $filetitle=$record.title.replace(" ","")

   $allrecords+=get-dcbsdata -record $record  -dollarrate $dollarrate
   $allrecords+=get-comicxposuredata -record $record -dollarrate $dollarrate
   $allrecords+=get-dhdata -record $record
   $allrecords+=get-closeencountersdata -record $record 
   $allrecords+=get-fpdata  -record $record  
   $allrecords+=get-reeddata -record $record
   $allrecords+=get-auctiondata -record $record
   $allrecords+=get-comicbizdata -record $record
   $allrecords+=get-comicbookshopdata -record $record
   $allrecords+=get-tfawdata -record $record -dollarrate $dollarrate
   $allrecords+=get-midtowndata -record $record -dollarrate $dollarrate
   $allrecords+=get-intercomicsdata -record $record 
   $allrecords+=get-hastingsdata -record $record -dollarrate $dollarrate

   If ($record.productcode -ne "")
   {
      $allrecords+=get-gurudata -title $record.title -productcode $record.productcode
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).json" -Encoding ascii
   
   #might need to sleep
   while ((get-date) -le $endtime)
   {
      Write-Host "$(Get-date) -  sleeping for kimonolabs limit"
      sleep 1
   }
}

#retrieve data
get-dcbs
get-comicxposure

#load all unique title objects from Json file
$searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" |ConvertFrom-Json
#$searches=$searches|sort -Unique title
Write-Host "$(Get-Date) - Found $($searches.count)"
[decimal]$dollarrate=get-gbpdollarrate

foreach ($record in $searches)
{
   if ($record.title -eq "The Walking dead")
   {
      $record.comictitle="WALKING DEAD"      
   }

   get-market -record $record -dollarrate $dollarrate
}

