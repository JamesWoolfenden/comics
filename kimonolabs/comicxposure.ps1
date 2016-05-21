import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\xrates.psd1" -force

function Get-comicxposure
{
   $url="https://www.kimonolabs.com/api/4tn9zcsa?apikey=01f250503b7c40eb0ce695da7d74cbb1"

   $comicxposureresults=Invoke-RestMethod -Uri $url
   if ($comicxposureresults.lastrunstatus -eq "failure")
   {
      return $null
   }

   $filename="$PSScriptRoot\data\comicxposure\$(datestring).json"
   $comicxposureresults.results.collection1|ConvertTo-Json -depth 999|Set-Content $filename
   cp $filename "$PSScriptRoot\data\comicxposure\latest.json"
   Write-Host "$(Get-date) - retrieved $($comicxposureresults.count) records from comicxposure"
}

function Get-comicxposuredata
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$Record,
   $dollarrate=(Get-gbpdollarrate))

   $title=$Record.title.ToUpper()
   Write-Host "$(Get-Date) - Looking for $title @ `"comicxposure`""
   $comicxposuredata=(Get-Content "$PSScriptRoot\data\comicxposure\latest.json") -join "`n" | ConvertFrom-Json

   $results=$comicxposuredata|where{$_.title.text -match "$title"}|select -uniq

   $counter=0
   $arraycount=0
   $comicxposure=@()
   $datetime=Get-date

   foreach($result in $results)
   {
      $record= New-Object System.Object

      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL

      $price=$result.price.split('$')[1]
      $variant=($result.title.text.replace("$title","")).trim()
      if ($variant.contains("#"))
      {
         $issue=($variant.split("#")[1]).split(" ")[0]
         $variant=($variant.replace("#$issue","")).trim()
      }
      else
      {
         $issue=$variant
      }

      $price=[decimal]$price*$dollarrate

      $record| Add-Member -type NoteProperty -name title    -value $title
      $record| Add-Member -type NoteProperty -name issue    -value $issue
      $record| Add-Member -type NoteProperty -name variant  -value $variant
      $record| Add-Member -type NoteProperty -name price    -value ("{0:N2}" -f $price)
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate  -value $datetime
      $record| Add-Member -type NoteProperty -name site     -value "comicxposure"

      $comicxposure+=$record

      $counter++
   }

   Write-Host "$(Get-Date) - Found $counter"
   $comicxposure
}
