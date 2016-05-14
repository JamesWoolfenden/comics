param(
[string]$title="CHEW")

$files=gci $PSScriptRoot\Prices -Filter *$title*.json
$files=$files | Where {$_.Name -notmatch  "latest"}
$dataarray=@()
foreach ($file in $files)
{
    $dataarray+=(Get-Content $file.FullName) -join "`n" | ConvertFrom-Json
}

 $dataarray|sort-object cover,date |format-table
