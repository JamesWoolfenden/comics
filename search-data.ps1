
function make-searchdata
{
   Param(
   [string]$title,
   [string]$include=$null,
   [string]$exclude=$null,
   [string]$comictitle=$null,
   [string]$category="8077",
   [Boolean]$Enabled=$true
   )
   
   New-Object PSObject -Property @{title=$title;include=$include;exclude=$exclude;comictitle=$comictitle;category=$category;Enabled=$Enabled}
}

function append-searchdata
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title=$title.ToUpper(),
   [string]$include,
   [string]$exclude,
   [string]$comictitle,
   [string]$category,
   [Boolean]$Enabled
   )
   
   $datafile="$root\search-data.json"
   $searches=(Get-Content $datafile) -join "`n" | ConvertFrom-Json
   $searches+=make-searchdata -title "$title" -exclude "$exclude" -include "$include" -comictitle $comictitle -category $category -Enabled $Enabled
   $searches| ConvertTo-Json -depth 999 | Out-File "$datafile"
}
<#
$file=@(make-searchdata -title "2000AD Monthly" -include "Eagle"  -exclude "Lurkers")
$file+=make-searchdata -title "2000AD" -Exclude "golden IDW monthly Rogue Revolver Showcase JUNKK Killing Eagle Hellblazer Quality DREDD STRONTIUM Xena ETERNAL Commando Starblazer BBC"
$file+=make-searchdata -title "Best of 2000 AD" -exclude "Lurkers"
$file+=make-searchdata -title "BURN THE ORPHANAGE" -include "image" -exclude "Lurkers"
$file+=make-searchdata -title "CHEW" -include "image" -exclude "Alpha Pirates Trouble Detective Wolverine America Pacific VOL dancer volume bedlam luther happy nightly romana saga sex talent"
$file+=make-searchdata -title "CLONE" -include "Image" -exclude "VOL Lazarus Ghosted Orphanage Titans Spider-man" 
$file+=make-searchdata -title "DEADLY CLASS" -exclude "Lurkers"
$file+=make-searchdata -title "FIVE GHOSTS" -include "image" -exclude "Lurkers"
$file+=make-searchdata -title "IRREDEEMABLE ANT-MAN" -exclude "Lurkers"
$file+=make-searchdata -title "JUDGE DREDD THE EARLY CASES" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "JUDGE DREDD CRIME FILE" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "JUDGE DREDD JUDGE CHILD QUEST" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "JUDGE DREDD" -include "Eagle" -exclude "Early Child Crime IDW Quality"
$file+=make-searchdata -title "JUPITERS LEGACY" -include "image"  -exclude "Lurkers"
$file+=make-searchdata -title "MANHATTAN PROJECTS" -exclude "Nowhere women vol volume"
$file+=make-searchdata -title "MANIFEST DESTINY" -include "Image" -Exclude "x-men Poster Card Still A4 Novel SET LOT"
$file+=make-searchdata -title "MIND THE GAP" -exclude "Lurkers"
$file+=make-searchdata -title "MERCENARY SEA" -include "image" -exclude "Lurkers"
$file+=make-searchdata -title "NIGHTLY NEWS" -comictitle "The Nightly News" -include "image" 
$file+=make-searchdata -title "NEMESIS THE WARLOCK" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "PETER PANZERFAUST" -exclude "Hatter Morning chin Xenoholics Rat volume vol chew pacific sex jesus sheltered Ninja Elephantmen Debris"
$file+=make-searchdata -title "ROBO-HUNTER" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "SECRET" -include "Image" -exclude "avengers dc Invasion Marvel Batman Valiant Avengers Warriors Flashpoint Wars Skullkickers Poster Card Still A4 Novel SET LOT POYO RAGE Vibert HAPPY Marvel Deadpool"
$file+=make-searchdata -title "SEX CRIMINALS"  -include "image" -exclude "zero"
$file+=make-searchdata -title "SHELTERED" -exclude "vol volume voltron"
$file+=make-searchdata -title "SOUTHERN BASTARDS" -exclude "Lurkers"
$file+=make-searchdata -title "STRONTIUM DOG" -include "eagle" -exclude "QUALITY" 
$file+=make-searchdata -title "TEN GRAND" -include "image" 
$file+=make-searchdata -title "THE BOUNCE" -include "image" -Exclude "VOL" 
$file+=make-searchdata -title "THE FIELD"  -exclude "Orchid Avengers iron herobear nun superman spiderwick marvel comeback strawberry"
$file+=make-searchdata -title "THE FUSE" -include "image" -exclude "pop airboy blows"
$file+=make-searchdata -title "THE WALKING DEAD WEEKLY" -exclude "brit paperback chew volume dinosaur world monopoly Marvel "
$file+=make-searchdata -title "THE WALKING DEAD" -exclude "brit Haunt Nowhere Zombie FANBOYS clone FIGURE Mocking invincible THIEF Ashcan Astounding hatter Variant Magazine Xenoholics x-files paperback chew volume dinosaur world weekly MONOPOLY Weekly Marvel"
$file+=make-searchdata -title "THE WALKING DEAD" -include "brit Variant" -exclude "Haunt Nowhere Zombie FANBOYS clone FIGURE Mocking invincible Ashcan hatter Magazine Xenoholics x-files paperback chew volume dinosaur world weekly MONOPOLY Weekly Marvel"
$file+=make-searchdata -title "THIEF OF THIEVES" -Exclude "Super walking chew tpb VOL"
$file+=make-searchdata -title "THINK TANK" -exclude "fantastic Daredevil"
$file+=make-searchdata -title "THE NIGHTLY NEWS" -include "image" -exclude "Lurkers"
$file+=make-searchdata -title "The Stainless Steel Rat" -include "eagle" -exclude "Lurkers"
$file+=make-searchdata -title "V FOR VENDETTA" -Exclude "VOL Essentials TERRITORY"
$file+=make-searchdata -title "WALKING DEAD" -comictitle "The Walking Dead" -exclude "Haunt Nowhere FIGURE The Mocking invincible THIEF Ashcan Astounding hatter Variant Magazine Xenoholics x-files paperback chew volume dinosaur world MONOPOLY Weekly Marvel "
$file+=make-searchdata -title "WARRIOR" -include "QUALITY" -Exclude "Eternal Race Nun Wolverine Women Tarzan Mystic Frenzy Conan STRIKER SHI SPARTAN SEX Trooper Domon thor PRINCESS Xena ETERNAL Commando Starblazer BBC 2000AD"
$file+=make-searchdata -title CASANOVA -exclude "Lurkers"
$file+=make-searchdata -title FATALE -include "image" -exclude "finale witchblade Reality Pirates Bedlam Powers Happy"
$file+=make-searchdata -title GHOSTED -include "Image" -Exclude "Skullkickers Poster Card Still A4 Novel" 
$file+=make-searchdata -title LAZARUS -include "image" -exclude "Manifest Voice Saviors Pretty Deadly Churchyard DC five incredible Moriarty Vol"
$file+=make-searchdata -title REVIVAL  -include "image" -exclude "batman debris saga CHALLENGERS"
$file+=make-searchdata -title REVOLVER -exclude "Danger Wolverine VOLCANIC Vertigo RENEGADE"
$file+=make-searchdata -title VELVET -include "image" -exclude "Ten Grand Stumptown LADY DEATH ASSASSIN Mara National"
$file+=make-searchdata -title WATCHMEN -exclude "Trade Paperback badges Whatmen before dc novels book prints spawn figure badge tpb after fashion essential swamp VOL liberty"
$file+=make-searchdata -title cowl -batman -gordon -azrael -battle -dc
$file| ConvertTo-Json -depth 999 | Out-File "c:\comics\search-data.json"
#>