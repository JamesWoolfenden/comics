function scan
{
   $searches=(Get-Content "c:\comics\search-data.json") -join "`n" | ConvertFrom-Json

   foreach($search in $searches)
   {
     if (($($search.comictitle) -eq "") -or ( $($search.comictitle) -eq $null)) 
     {
        $search.comictitle="$($search.title)"
     }

     Write-Host "get-allrecords -title $($search.title) -include $($search.include)  -exclude $($search.exclude) -comictitle $($search.comictitle)"
     get-allrecords -title "$($search.title)" -include "$($search.include)"  -exclude "$($search.exclude)" -comictitle "$($search.comictitle)"
   }
}