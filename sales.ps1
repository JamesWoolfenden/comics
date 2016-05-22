
import-module "$PSScriptRoot\core.ps1" -force

$sales=(Get-Content "$PSScriptRoot\sales\2014\04.json") -join "`n" | ConvertFrom-Json

$parseddata=@()

foreach($record in $sales.data)
{
   if ($record.column_1_number -eq $NULL)
   {
      Write-Host "Skip" -ForegroundColor Red
      continue
   }

   $data= New-Object System.Object
   $data| Add-Member -type NoteProperty -name Title -value $record.column_2[0]
   $data| Add-Member -type NoteProperty -name Sales -value $record.column_6_number[0]
   $data| Add-Member -type NoteProperty -name Publisher -value $record.column_5[0]
   $data| Add-Member -type NoteProperty -name Rank -value $record.column_1_number[0]
   $data| Add-Member -type NoteProperty -name Price -value $record.column_4_currency[0]
   $data| Add-Member -type NoteProperty -name Currency -value $record."column_4_currency/_currency"[0] 
   Write-Verbose "Here again"
   $parseddata+=$data
}
