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
   [string]$title,
   [string]$productcode,
   [string]$alttitle)
   
   $allrecords=@()
   $filetitle=$title.replace(" ","")
  
   $allrecords+=get-dhdata -title $title
   $allrecords+=get-closeencountersdata -title $title 
   $allrecords+=get-fpdata  -title $title  
   $allrecords+=get-reeddata -title $title 
   $allrecords+=get-auctiondata -title $title
   #$allrecords+=get-comicbizdata -title $title 

   if ($alttitle -ne "")
   {
      write-Host "Using Alternative title $alttitle"
      $allrecords+=get-comicbookshopdata  -title $alttitle 
      #$allrecords+=get-comicbookstoredata -title $alttitle  
      $allrecords+=get-tfawdata -title $alttitle  
      $allrecords+=get-comicbizdata -title $alttitle  
      $allrecords+=get-dcbsdata -title $alttitle  
   }
   else
   {
      write-Host "Using Original title $title"
      $allrecords+=get-comicbookshopdata  -title $title
      #$allrecords+=get-comicbookstoredata -title  $title 
      $allrecords+=get-tfawdata -title $title
      $allrecords+=get-dcbsdata -title $title  
   }
   
   If ($productcode -ne "")
   {
      $allrecords+=get-gurudata -title $title -productcode $productcode
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).json" -Encoding ascii
   #$allrecords |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\livedata\$($filetitle).txt" -Encoding utf8
}

#retrieve data
get-dcbs

get-market -title "THE WALKING DEAD" -productcode "2140" -alttitle "WALKING DEAD"
get-market -title "MANIFEST DESTINY" -productcode "16670"
get-market -title "SEX CRIMINALS" -productcode "16547"
get-market -title "CHEW" -productcode "12622"
get-market -title "NAILBITER" -productcode "17108"
get-market -title "MANHATTAN PROJECTS" -productcode "15087"
get-market -title "CLONE" -productcode "15777"
get-market -title "DEADLY CLASS" -productcode "16834"
get-market -title "JUPITERS LEGACY"  -productcode "16143"
get-market -title "MIND THE GAP" -productcode "15235"
get-market -title "MERCENARY SEA"  -productcode "16959"
get-market -title "PETER PANZERFAUST"  -productcode "15039"
get-market -title "SHELTERED"  -productcode "16349"
get-market -title "SOUTHERN BASTARDS"  
get-market -title "THE FIELD"  -productcode "17015"
get-market -title "THIEF OF THIEVES" -productcode "15027"
get-market -title "THINK TANK" -productcode "15475"
get-market -title "FATALE" -productcode "14935"
get-market -title "LAZARUS" -productcode "16313"
get-market -title "REVIVAL" -productcode "15414"
get-market -title "VELVET" -productcode "16617"
get-market -title "OUTCAST" -productcode "17212"
get-market -title "COWL"
get-market -title "MPH" -productcode "17137"
get-market -title "SPREAD" -productcode "17248"
get-market -title "FADE OUT"
get-market -title "IMPERIAL"
get-market -title "RAT QUEENS" -productcode "16545"
get-market -title "ALEX ADA" 
get-market -title "WICKED DIVINE" 
get-market -title "BIRTHRIGHT" -productcode "17539"
get-market -title "COPPERHEAD" -productcode "17435"
get-market -title "BIRTHRIGHT"
get-market -title "RASPUTIN" -productcode "17636"
get-market -title "ENORMOUS"
get-market -title "THE AUTUMNLANDS" -productcode "17652"
get-market -title "AFTERLIFE WITH ARCHIE" -productcode "16564"
get-market -title "WYTCHES" -productcode "17555"
