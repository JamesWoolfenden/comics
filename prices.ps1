$corescript=$myinvocation.mycommand.path
if ($corescript -eq $null)
{
   $root=$root=(gl).Path
}
else
{
   $root=split-path -parent -Path $corescript
}

import-module "$root\core.ps1" -force

function write-prices
{
   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$prices, 
   [Parameter(Mandatory=$true)]
   [string]$title)

   if ($prices -ne $null)
   {
      $filetitle="$title"+$(datestring)
      $prices |ConvertTo-Json -depth 999 | Out-File "$root\prices\$($filetitle).json" -Encoding ascii
      cp $root\prices\$($filetitle).json "$root\prices\latest-$($title).json"
      #$prices |ConvertTo-Json -depth 999 | Out-File "$root\prices\$($filetitle).txt" -Encoding utf8
      #cp $root\prices\$($filetitle).txt "$root\prices\latest-$($title).txt"
   }
   Else
   {
      Write-host "No data" -ForegroundColor cyan
   }
}

$searches=(Get-Content "$root\search-data.json") -join "`n" | ConvertFrom-Json

foreach ($record in $searches)
{
   if ($record.comictitle -ne "")
   {
      $record.title=$record.comictitle
   }
}

foreach ($title in ($searches.title |select -unique))
{
   write-Host "Calculating prices for $title" -ForegroundColor cyan
   $prices= get-allprices $title
   if ($prices -ne $null)
   {
      write-prices -prices $prices -title $title
      write-Host "Price table complete" -ForegroundColor green
   }
   else
   {
       Write-host "No data" -ForegroundColor cyan
   }
}

