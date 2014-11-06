$corescript=$myinvocation.mycommand.path
if ($corescript -eq $null)
{
   $root=$root=(gl).Path
}
else
{
   $root=split-path -parent -Path $corescript
}

import-module "$root\closeencounters.ps1" -force
import-module "$root\comicbookstore.ps1" -force
import-module "$root\fp.ps1" -force
import-module "$root\guru.ps1"  -force
import-module "$root\reed.ps1" -force
import-module "$root\comicbookshop.ps1" -force
import-Module "$root\disposableheroes.ps1" -force
import-Module "$root\comicbiz.ps1" -force
import-Module "$root\tfaw.ps1" -force

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
   #$allrecords+=get-comicbizdata -title $title 

   
   if ($alttitle -ne "")
   {
      write-Host "Using Alternative title $alttitle"
      $allrecords+=get-comicbookshopdata  -title $alttitle 
      $allrecords+=get-comicbookstoredata -title $alttitle  
      $allrecords+=get-tfawdata -title $alttitle  
      $allrecords+=get-comicbizdata -title $alttitle  
   }
   else
   {
      write-Host "Using Original title $title"
      $allrecords+=get-comicbookshopdata  -title $title
      $allrecords+=get-comicbookstoredata -title  $title 
   }
   
   If ($productcode -ne "")
   {
      $allrecords+=get-gurudata -title $title -productcode $productcode
   }

   $allrecords |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle).json" -Encoding ascii
   $allrecords |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle).txt" -Encoding utf8

   #$allrecords |ConvertTo-Json -depth 999 
}

get-market -title "ENORMOUS"
get-market -title "THE WALKING DEAD" -productcode "2140" -alttitle "WALKING DEAD"
get-market -title "MANIFEST DESTINY"
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
get-market -title "OUTCAST" 
get-market -title "COWL"
get-market -title "MPH" -productcode "17137"
get-market -title "SPREAD" 
get-market -title "FADE OUT"
get-market -title "IMPERIAL"
get-market -title "RAT QUEENS" -productcode "16545"
get-market -title "ALEX ADA" 
get-market -title "WICKED DIVINE" 
get-market -title "BIRTHRIGHT" 
get-market -title "COPPERHEAD" 
get-market -title "FADE OUT" 
get-market -title "WYTCHES"
get-market -title "BIRTHRIGHT"
get-market -title "RASPUTIN"
get-market -title "ENORMOUS"




