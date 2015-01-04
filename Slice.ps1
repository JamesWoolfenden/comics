#
# Script.ps1
#
param(
[string]$title,
[string]$issue,
[switch]$inline)


$pricefiles=gci "$PSScriptRoot\prices\$title*.json"
$pricehistory=@()

foreach ($file in $pricefiles)
{
  $pricehistory+=(Get-Content $file) -join "`n" | ConvertFrom-Json
}

if ($inline)
{
  $pricehistory|where {$_.Issue -eq $issue}|sort-object -Property Date
}
else
{
  $pricehistory|where {$_.Issue -eq $issue}|sort-object -Property Date|ogv
}