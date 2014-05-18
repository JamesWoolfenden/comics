function get-watch
{
   <#
      .SYNOPSIS 
       For viewing a set open of watch items
	    
      .EXAMPLE
      C:\PS> get-watch
      
   #>

   param()
   
   query-db "where Watch = 1 order by title"
}

function watch
{
   Param()

   $results=get-watch

   try
   {
      [int]$counter=1
      [int]$total=$($results.count)
      if ($total -eq $NULL)
      {
         $total=1
      }

      foreach($record in $results)
      {
         Write-host "$counter of $total"      
         update-record $record
         $counter++
      } 
   }
   catch
   {
     throw $_.Exception
     exit 1
   }
}