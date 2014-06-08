$corescript=$myinvocation.mycommand.path
$root=split-path -parent  -Path $corescript

import-module "$root\closeencounters.ps1" -force
import-module "$root\comicbookstore.ps1" -force
import-module "$root\fp.ps1" -force
import-module "$root\guru.ps1"  -force
import-module "$root\reed.ps1" -force
import-module "$root\comicbookshop.ps1" -force

function get-market
{
   param(
   [string]$title,
   [string]$productcode,
   [string]$alttitle)
   
   $allrecords=@()
   $filetitle=$title.replace(" ","")
   
   get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"

   get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
   get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
   
   if ($alttitle -ne "")
   {
      write-Host "Using Alternative title $alttitle"
      get-comicbookshopdata  -title $alttitle |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
      get-comicbookstoredata -title $alttitle |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
   }
   else
   {
      write-Host "Using Original title $title"
      get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
      get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
   }
   
   If ($productcode -ne "")
   {
      get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"
   }
}


get-market -title "The Walking Dead" -productcode "2140" -alttitle "Walking Dead"
get-market -title "Manifest Destiny"
get-market -title "Sex Criminals" -productcode "16547"
get-market -title "CHEW" -productcode "12622"
get-market -title "Nailbiter" -productcode "17108"
get-market -title "Manhattan Projects" -productcode "15087"
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
