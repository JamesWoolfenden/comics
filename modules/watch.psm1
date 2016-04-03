function Get-watch
{
   <#
      .SYNOPSIS 
       For viewing a set open of watch items
        
      .EXAMPLE
      C:\PS> Get-watch
      This lists all the open records marked watch
   #>

   param()
   
   Search-DB "where Watch = 1 and status = 'Verified' order by title"
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

   $results=Get-watch

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
         Update-Record $record
         $counter++
      } 
   }
   catch
   {
     throw $_.Exception
     exit 1
   }
}