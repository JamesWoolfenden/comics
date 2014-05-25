
function scan
{
   $searches=(Get-Content "$root\search-data.json") -join "`n" | ConvertFrom-Json

   foreach($search in $searches)
   {
     if (($($search.comictitle) -eq "") -or ( $($search.comictitle) -eq $null)) 
     {
        $search.comictitle="$($search.title)"
     }

     Write-Host "Finding $($search.title)" -ForegroundColor cyan
     Write-debug "get-allrecords -title $($search.title) -include $($search.include)  -exclude $($search.exclude) -comictitle $($search.comictitle)"
     get-allrecords -title "$($search.title)" -include "$($search.include)"  -exclude "$($search.exclude)" -comictitle "$($search.comictitle)"
     Write-Host "Complete." -ForegroundColor cyan
   }
}

function best-buys
{
   param([pscustomobject]$results)
   
   foreach($record in $results)
   {
      $prices=estimate-price -title $record.title -issue $record.issue
      $record | Add-Member -type NoteProperty -name AveragePrice -value $prices.AveragePrice
      $record | Add-Member -type NoteProperty -name Margin -Value ($prices.CurrentPrice-$record.price)
      $record | Add-Member -type NoteProperty -name CurrentPrice -value $prices.CurrentPrice
   }
   $results
}