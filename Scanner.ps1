$corescript=$myinvocation.mycommand.path
$root=split-path -parent  -Path $corescript

import-module "$root\closeencounters.ps1" -force
import-module "$root\comicbookstore.ps1" -force
import-module "$root\fp.ps1" -force
import-module "$root\guru.ps1"  -force
import-module "$root\reed.ps1" -force
import-module "$root\comicbookshop.ps1" -force

$title="The Walking Dead"
$filetitle=$title.replace(" ","")
$productcode="2140"
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $($title.Replace("The ","")) |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $($title.Replace("The ","")) |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
$guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"

$title="Manifest Destiny"
$filetitle=$title.replace(" ","")
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"

$title="Sex Criminals"
$filetitle=$title.replace(" ","")
$productcode="16547"
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
$guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"

$title="CHEW"
$filetitle=$title
$productcode="12622"
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
$guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"

$title="Nailbiter"
$filetitle=$title
$productcode="17108"
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
$guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"

$title="Manhattan Projects"
$filetitle=$title.replace(" ","")
$productcode="15087"
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
$guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"


function get-market
{
   param(
   [string]$title,
   [string]$productcode)
   
   $filetitle=$title.replace(" ","")
   $close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
   $comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
   $fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
   $reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
   $bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"
   
   If ($productcode -ne "")
   {
      $guru      =get-gurudata -title $title -productcode $productcode |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)guru.json"
   }
}



get-market -title "CLONE"
get-market -title "DEADLY CLASS"
get-market -title "JUPITERS LEGACY"

get-market -title "MIND THE GAP"
get-market -title "MERCENARY SEA"
get-market -title "PETER PANZERFAUST"
get-market -title "SHELTERED"
get-market -title "SOUTHERN BASTARDS"
get-market -title "THE FIELD"
get-market -title "THIEF OF THIEVES"
get-market -title "THINK TANK"
get-market -title "FATALE"
get-market -title "LAZARUS"
get-market -title "REVIVAL"
get-market -title "VELVET"
get-market -title "OUTCAST"
get-market -title "COWL"
get-market -title "MPH"

