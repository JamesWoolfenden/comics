function split-set 
{
   param(
   [string]$title)
   
   $wherestring="where Title = '$title' And Issue = 'set' and status='closed' and split != 1 "
   write-host "Where : $wherestring"
   $results=query-db $wherestring
   if ($results -ne "")
   {
      write-host "Found $($results.count)"
      foreach($record in $results)
      {
         $IE=viewer $record 
         $split=read-host "Split? Yes(y)/No(n)/Exclude(x)" 
         if ($split -eq "y")
         {
            $newsize=read-host "Update Quantity ($($record.Quantity))"
            if ($newsize -ne "")
            {
               [int]$setsize=$newsize
            } 
            else
            {
               [int]$setsize= $record.Quantity
            }
            
            for($x=0;$x -lt $setsize; $x++)
            {
               $displayissue=$x+1
               $item=read-host "$displayissue/$setsize enter issue"
               
               if ($item -eq "")
               {
                  break
               }
               
               $price=$record.price/$setsize
               #write-host "bought: $($record.bought)"
               if ($($record.bought) -eq "true")
               {
                  $bought=$true
               }
               else 
               {
                  $bought=$false
               }

               #Write-host "add-record -title $record.title -issue $item -price $price -status $record.status -bought $bought -site $record.site -seller $record.seller -parentid $record.ebayitem"
               add-record -title $record.title -issue $item -price $price -status $record.status -bought $bought -site $record.site -seller $record.seller -parentid $record.ebayitem -split $true -PublishDate $record.PublishDate -Description $record.Description -AuctionType $record.AuctionType -BestOffer $record.BestOffer -BidCount $record.BidCount -BuyItNowPrice $record.BuyItNowPrice -CloseDate $record.CloseDate 
            }
            
            set-splitstate -state $true -ebayitem $record.ebayitem
         }
         
         if ($split -eq "x")
         {
            set-splitstate -state $true -ebayitem $record.ebayitem
         }
         
         $IE.Quit()
      }
   }
   Else
   {
      write-host "Found nothing"
   }
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


function set-splitstate()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$ebayitem,
   [Parameter(Mandatory=$true)]
   [boolean]$state
   )
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
      
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
         
   [int]$split=$state   
   #Write-host "Split:$split"
   $cmd.commandtext = "update Comics.dbo.Comics SET Split = $split where Ebayitem = '$ebayitem' " 
   #Write-host "$($cmd.commandtext)"   
   $result=$cmd.executenonquery()
   $conn.close()
}