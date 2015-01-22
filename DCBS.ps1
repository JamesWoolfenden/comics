
import-module "$PSScriptRoot\core.ps1" -force

function get-dcbs
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
   Write-Host "$(Get-date) - retrieved $($dcbsresults.count)"
}

function get-dcbsdata
{
   param([string]$title)

   $dcbsdata=(Get-Content "$PSScriptRoot\data\dcbs\latest.json") -join "`n" | ConvertFrom-Json
   
   $results=$dcbsdata|where{$_.title.text -match "$title"}|select -uniq

   $counter=0
   $arraycount=0
   $dcbs=@()
   
   if ($results -is [system.array])
   {
      $arraycount=$results.count
   }
   else
   {
      if ($results -ne $NULL)
      { 
         $arraycount=1
      }
   }

   While($counter -ne $arraycount)
   {
      $record= New-Object System.Object
          
      $url="<a href=`"$($results[$counter].title.href)`">$($results[$counter].title.href)</a>"
      $record| Add-Member -type NoteProperty -name link -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      
      $price=$results[$counter].price.split('$')[1]
      $variant=($results[$counter].title.text.replace("$title","")).trim()
      if ($variant.contains("#"))
      {
         $issue=($variant.split("#")[1]).split(" ")[0]
         $variant=($variant.replace("#$issue","")).trim()
      }
      else
      {
         $issue=$variant
      }

      $record| Add-Member -type NoteProperty -name title    -value $title
      $record| Add-Member -type NoteProperty -name issue    -value $issue
      $record| Add-Member -type NoteProperty -name variant  -value $variant
      $record| Add-Member -type NoteProperty -name price    -value $price
      $record| Add-Member -type NoteProperty -name currency -value "dollars"
      $record| Add-Member -type NoteProperty -name rundate  -value $(datestring)
      $record| Add-Member -type NoteProperty -name site     -value "DCBS"

      $dcbs+=$record
    
      $counter++
   }
  
   write-host "Record $counter"
   $dcbs
}