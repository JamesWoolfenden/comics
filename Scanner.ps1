$corescript=$myinvocation.mycommand.path
$root=split-path -parent  $corescript

import-module "$root\closeencounters.ps1" -force
import-module "$root\Comicbookstore.ps1"
import-module "$root\fp.ps1"
import-module "$root\guru.ps1"
import-module "$root\reed.ps1"

$title="The Walking Dead"
$filetitle=$title.replace(" ","")
$close=    get-closeencountersdata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)closeencountera.json"
$comicbook=get-comicbookstoredata -title  $($title.Replace("The ","")) |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)comicbookstore.json"
$fp       =get-fpdata  -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)fp.json"
$reed     =get-reeddata -title $title |ConvertTo-Json -depth 999 | Out-File "$root\livedata\$($filetitle)reed.json"

