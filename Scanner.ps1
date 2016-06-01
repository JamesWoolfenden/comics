import-module "$PSScriptRoot\modules\auction.psd1" -force
import-module "$PSScriptRoot\closeencounters.ps1" -force
import-module "$PSScriptRoot\fp.ps1" -force
import-module "$PSScriptRoot\guru.ps1"  -force
import-module "$PSScriptRoot\reed.ps1" -force
import-module "$PSScriptRoot\comicbookshop.ps1" -force
import-Module "$PSScriptRoot\comicbiz.ps1" -force
import-Module "$PSScriptRoot\tfaw.ps1" -force
import-Module "$PSScriptRoot\dcbs.ps1" -force
import-Module "$PSScriptRoot\midtown.ps1" -force
import-Module "$PSScriptRoot\intercomics.ps1" -force
import-Module "$PSScriptRoot\comicxposure.ps1" -force
import-module "$PSScriptRoot\modules\xrates.psd1" -force
import-module "$PSScriptRoot\hastings.ps1" -force

function Get-Market
{
   param(
   [Parameter(Mandatory=$true)]
   [Psobject]$record,
   [decimal]$dollarrate=(Get-gbpdollarrate))

   $start=Get-date
   $elapsed =new-timespan -seconds 60
   $endtime=$start+$elapsed

   $allrecords=@()
   $filetitle=$record.title.replace(" ","")

   $allrecords+=Get-dcbsdata -record $record  -dollarrate $dollarrate
   $allrecords+=Get-comicxposuredata -record $record -dollarrate $dollarrate
   $allrecords+=Get-closeencountersdata -record $record
   $allrecords+=Get-fpdata  -record $record
   $allrecords+=Get-reeddata -record $record
   $allrecords+=Get-AuctionData -record $record
   $allrecords+=Get-comicbizdata -record $record
   $allrecords+=Get-comicbookshopdata -record $record
   $allrecords+=Get-tfawdata -record $record -dollarrate $dollarrate
   $allrecords+=Get-midtowndata -record $record -dollarrate $dollarrate
   $allrecords+=Get-intercomicsdata -record $record
   $allrecords+=Get-hastingsdata -record $record -dollarrate $dollarrate

   If ($record.productcode -ne "")
   {
      $allrecords+=Get-gurudata -record $record
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).json" -Encoding ascii

   #might need to sleep
   while ((Get-date) -le $endtime)
   {
      Write-Host "$(Get-date) -  sleeping for kimonolabs limit"
      sleep 1
   }
}

#retrieve data
Get-dcbs
Get-comicxposure

#load all unique title objects from Json file
$searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" |ConvertFrom-Json

Write-Host "$(Get-Date) - Found $($searches.count)"
[decimal]$dollarrate=Get-gbpdollarrate

foreach ($record in $searches)
{
   if ($record.title -eq "The Walking dead")
   {
      $record.comictitle="WALKING DEAD"
   }

   Get-market -record $record -dollarrate $dollarrate
}
