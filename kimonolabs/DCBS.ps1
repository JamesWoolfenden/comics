
import-module "$PSScriptRoot\core.ps1" -force
import-module "$PSScriptRoot\modules\xrates.psd1" -force
import-module "$PSScriptRoot\modules\url.psd1" -force

function Get-DCBS
{
   $url="https://www.kimonolabs.com/api/3lyw38rc?apikey=01f250503b7c40eb0ce695da7d74cbb1"

   $dcbsresults=Invoke-RestMethod -Uri $url
   if ($dcbsresults.lastrunstatus -eq "failure")
   {
      return $null
   }
   
   $filename="$PSScriptRoot\data\dcbs\$(datestring).json"
   $dcbsresults.results.collection1|ConvertTo-Json -depth 999|Set-Content $filename
   cp $filename "$PSScriptRoot\data\dcbs\latest.json"
   Write-Host "$(Get-date) - retrieved $($dcbsresults.count) records from DCBS"
}

function Get-DCBSData
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$Record,
   $dollarrate=(Get-gbpdollarrate))
   
   $title=$Record.title.ToUpper()
   write-Host "$(Get-Date) - Looking for $title @ `"DCBS`""
   $results=(Get-Content "$PSScriptRoot\data\dcbs\latest.json") -join "`n" | ConvertFrom-Json
   
   $arraytitle=$title.split(" ")

   foreach($part in $arraytitle)
   {
      $results = $results| where {$_.title.text -match $part}
   }

   $counter=0
   $arraycount=0
   $dcbs=@()

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
      $record| Add-Member -type NoteProperty -name rundate  -value $(datestring)
      $record| Add-Member -type NoteProperty -name site     -value "DCBS"

      $dcbs+=$record
    
      $counter++
   }
  
   write-host "$(Get-Date) - Found $counter"
   $dcbs
}
