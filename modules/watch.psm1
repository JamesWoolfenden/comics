function get-watch
{
   <#
      .SYNOPSIS 
       For viewing a set open of watch items
        
      .EXAMPLE
      C:\PS> get-watch
      This lists all the open records marked watch
   #>

   param()
   
   search-db "where Watch = 1 and status = 'Verified' order by title"
}

function watch
{
   <#
      .SYNOPSIS 
       For reviewing a set open of watch items
        
      .EXAMPLE
      C:\PS> watch
      
   #>
   
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