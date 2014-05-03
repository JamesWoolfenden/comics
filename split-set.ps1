function split-set 
{
   param(
   [string]$title)
   
   $wherestring="where Title = '$title' And Issue = 'set' and status='closed'"
   write-host "Where : $wherestring"
   $results=query-db $wherestring
   if ($results -ne "")
   {
      foreach($record in $results)
      {
         $IE=viewer $record 
         $split=read-host "Split? y/n" 
         if ($split -eq "y")
         {
            [int]$setsize= $record.Quantity
            for($x=0;$x -lt $setsize; $x++)
            {
               read-host "$x/$setsize enter issue:"
            }
         }
         
         $IE.Quit()
      }
   }
   Else
   {
      write-host "Found nothing"
   }
   #title or defaults to all
   #only works on closed sets becomes  marks them as split, new fields?

   #split or skip?
   #for given number of recods in closed set
   #asks for issue numbers
   #writes record
}

function Viewer
{
   param($record)

   if ($($record.ebayitem))
   {     
      switch ($($record.site))
      {
         "ebay"
         {
            $ie=view $($record.ebayitem)         
         }
         "ebid"
         {
            $ie=view-url $($record.link)
         }
         default
         {
	    $ie=view $($record.ebayitem)
	 }
      }
   }
   else 
   {
      write-warning "$($record.ebayitem) is null or empty"
   }
   $ie
}