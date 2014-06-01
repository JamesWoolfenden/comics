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
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $($title.Replace("The ","")) |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $($title.Replace("The ","")) |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"


$title="Manifest Destiny"
$filetitle=$title.replace(" ","")
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"

$title="Sex Criminals"
$filetitle=$title.replace(" ","")
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
#$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"

$title="Nailbiter"
$filetitle=$title.replace(" ","")
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"

$title="CHEW"
$filetitle=$title
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"

$title="Nailbiter"
$filetitle=$title
$close     =get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencounter.json"
$comicbook =get-comicbookstoredata -title  $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp        =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed      =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"
$bookshop  =get-comicbookshopdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookshop.json"