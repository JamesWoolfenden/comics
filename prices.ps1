function Write-Prices
{
   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$prices,
   [Parameter(Mandatory=$true)]
   [string]$title)

   if ($prices -ne $null)
   {
      $filetitle="$title"+$(datestring)
      $prices |ConvertTo-Json -depth 999 | Out-File "$PSScriptRoot\prices\$($filetitle).json" -Encoding ascii
      cp $PSScriptRoot\prices\$($filetitle).json "$PSScriptRoot\prices\latest-$($title).json"
   }
   Else
   {
      Write-Host "No data" -ForegroundColor cyan
   }
}

$searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" | ConvertFrom-Json

foreach ($record in $searches)
{
   if ($record.comictitle -ne "")
   {
      $record.title=$record.comictitle
   }
}

foreach ($title in ($searches.title |select -unique))
{
   Write-Host "Calculating prices for $title" -ForegroundColor cyan
   $prices= Get-allprices $title
   if ($prices -ne $null)
   {
      write-prices -prices $prices -title $title
      Write-Host "Price table complete" -ForegroundColor green
   }
   else
   {
       Write-Host "No data" -ForegroundColor cyan
   }
}
