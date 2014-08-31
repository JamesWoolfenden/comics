param(
[string]$title="CHEW")

$files=gci c:\comics\prices -Filter *$title*.json 

$dataarray=@()
foreach ($file in $files)
{
    $dataarray+=(Get-Content $file.FullName) -join "`n" | ConvertFrom-Json
}

 $dataarray|sort-object cover,date |format-table