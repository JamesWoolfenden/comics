function get-pounds
{
   param([string]$dirty="")
   Try
   {
      $clean=$dirty.split(" ")
   
      [regex]$r="[^0-9.]"
      #$clean=$r.replace($clean,"")
      
      if ($clean.count -gt 1)
      {
         $clean=$r.replace($clean[1],"")
      }
      
      $clean
    }
    Catch [system.exception]
    {
        throw $_.message
    }
}

function get-cover
{
   param([string]$dirty="")
   Try
   {
      [regex]$r="[^0-9.]"
      $clean=$r.replace($dirty,"")
 
      $clean
    }
    Catch [system.exception]
    {
        throw $_.message
    }
}

function add-record()
{
   <#
      .SYNOPSIS 
       Adds a comic sale record.
	    
      .DESCRIPTION
       Adds a comic sale record to the db
      
      .PARAMETER Name
	Specifies the file name.
	    
      .EXAMPLE
      C:\PS> add-record -title "The Walking Dead" -issue "1A" -price 12.5 -status CLOSED -bought $true -site FP -seller FP
      .EXAMPLE
      C:\PS>add-record -title "The Walking Dead" -issue 122 -price 1.75 -status CLOSED -bought $true -site FP -seller FP -postage 0.67
      .EXAMPLE
      C:\PS>add-record -title "The Walking Dead" -issue 123 -price 1.75 -status CLOSED -bought $true -site FP -seller FP -postage 0.67
      .EXAMPLE
      C:\PS> add-record -title "Manhattan Projects" -issue 18 -price 2.10 -status CLOSED -bought $true -site FP -seller FP -postage 0.67
        
   #>
            
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$issue,
   [Parameter(Mandatory=$true)]
   [string]$price,
   [bool]$bought=$false,
   [string]$PublishDate,
   [string]$Ebayitem,
   [string]$Status="CLOSED",
   [string]$Description="",
   [string]$postage="0.00",
   [string]$AuctionType="",
   [string]$BestOffer="",
   [string]$BidCount="",
   [string]$BuyItNowPrice="",
   [string]$CloseDate,
   [string]$ImageSrc="",
   [string]$Link="",
   [string]$site="ebay",
   [int]$quantity=1,
   [string]$remaining="",
   [string]$seller=""
   )
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
   
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   
   $saledate = Get-Date 
   $Issue=$Issue.ToUpper()
   $Description=$Description.Replace("'","")
   
   #Write-host "Postage $Postage"
   #Write-host "Price $Price"
   
   $postage=get-pounds $postage
   $price=get-pounds $price
   
   #Write-host "Postage $Postage"
   #Write-host "Price $Price"
   
   $cmd.commandtext = "INSERT INTO comics 
   (Title, Price, Issue, Bought, DateOfSale, Status, postage, Description, PublishDate, EbayItem, Quantity, AuctionType, BestOffer, BidCount, BuyItNowPrice, CloseDate, ImageSrc, Link, Site, Remaining, Seller, SaleDate, StartingPrice) 
   VALUES
   ('$title', '$Price', '$Issue', '$bought', '$saledate', '$status','$postage', '$Description','$PublishDate', '$ebayitem',$Quantity, '$AuctionType', '$BestOffer', '$BidCount', '$BuyItNowPrice', '$CloseDate', '$ImageSrc', '$Link', '$site', '$remaining', '$seller', '$saledate','$Price')" 
   
   $result=$cmd.executenonquery()
   $conn.close()
}

function get-db()
{
   param([string]$ebayitem)

   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
   
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "select title FROM [Comics].[dbo].[Comics] where ebayitem='$ebayitem'"
   #write-host $cmd.commandtext 
   $data= $cmd.ExecuteReader()
   $result = @()
   $count=0
   
   while ($data.Read())
   {
      $result=$result+$data.GetString(0)
      $count++
   }
   
   $conn.close()
   return $result.count
}

function update-db()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$ebayitem,
   [string]$UpdateValue,
   [string]$price,
   [string]$postage,  
   [string]$title,
   [string]$status=$NULL,
   [string]$bought=$NULL,
   [string]$quantity=$NULL,
   [string]$seller=$NULL
   )
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
      
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
      
   $saledate = Get-Date 
   $Issue=$UpdateValue.ToUpper()
   
   if($price)
   {
      $price=get-pounds $price
   }
   
   if($postage)
   {
      $postage=get-pounds $postage
   }
   
   $updatestring="DateOfSale='$saledate'" 
   
   if ($title -ne "")
   {
      $updatestring=$updatestring+",  title='$title'"
   }
   
   if ($Price -ne "")
   {
      $updatestring=$updatestring+",  price='$price'"
   }
   
   if ($UpdateValue -ne "")
   {
      $updatestring=$updatestring+",  issue='$UpdateValue'"
   }
   
   if ($postage -ne "")   
   {
      $updatestring=$updatestring+", postage='$postage'"
   } 
   
   if ($Bought -ne "")   
   {
      $updatestring=$updatestring+", bought='$bought'"
   }
   
   if ($quantity -ne "")
   {
      $updatestring=$updatestring+", quantity='$quantity'"
   }
   
   if ($status -ne "")
   {
      $updatestring=$updatestring+", status='$status'"
      if ($status -eq "CLOSED")
      {
          $updatestring=$updatestring+", SaleDate='$saledate'"
      }
   }
   
   if ($seller -ne "")
   {
      $updatestring=$updatestring+", seller='$seller'"
   }
   
   $cmd.commandtext = "update Comics.dbo.Comics SET $updatestring where Ebayitem = '$ebayitem' and (status !='CLOSED' OR status !='expired')" 
    
   #$cmd.commandtext 
      
   $result=$cmd.executenonquery()
   $conn.close()
   #$result
}


function query-db()
{
   Param([string]$wherestring="where Title = '$title' And Issue = '$Issue'")
     
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "SELECT 
       [Seller],[Title],[Price]
      ,[Issue],[Bought],[DateOfSale],[Status]
      ,[postage],[Ebayitem],[Description],[PublishDate]
      ,[Quantity],[AuctionType],[BestOffer],[BidCount]
      ,[BuyItNowPrice],[CloseDate],[ImageSrc],[Link]
      ,[Site],[Remaining] 
      FROM comics $wherestring"

   #$cmd.commandtext
   $data = $cmd.ExecuteReader()
   
   while ($data.Read())
   {    
       if ($data.IsDBNUll(0)) 
       {
         $seller=$null
       }
       else 
       {
          $seller=$data.GetString(0)
       }
    
       $price= get-pounds $data.GetDouble(2)
       #postage
       $postage= get-pounds $data.GetDouble(7)
    
    
       if ($data.IsDBNull(8))
       {
          $ebayitem=$null
       }
       else 
       {
          $ebayitem=$data.GetString(8)
       }
   
       #description
       if ($data.IsDBNull(9))
       {
          $description=$NULL
       }
       else 
       {
          $description=$data.GetString(9)  
       } 
       
       if ($data.IsDBNull(10))
       {
          $publishdate=$null
       }
       else 
       {
          $publishdate=$data.GetString(10)  
       }
   
       #auctiontype
       if ($data.IsDBNull(12))
       {
          $auctiontype=$null
       }
       else 
       {
          $auctiontype=$data.GetString(12)  
       }
       
       #BestOffer
       if ($data.IsDBNull(13))
       {
          $BestOffer=$null
       }
       else 
       {
          $BestOffer=get-pounds $data.GetString(13)  
       }
       
       #BidCount
       if ($data.IsDBNull(14))
       {
          $BidCount=$null
       }
       else 
       {
          $BidCount=$data.GetString(14)  
       }
       
       #buyitnowprice
       if ($data.IsDBNull(15))
       {
          $buyitnowprice=$null
       }
       else 
       {
          $buyitnowprice=get-pounds ($data.GetString(15)).Replace("&#163;","")  
       }

       #closedate
       if ($data.IsDBNull(16))
       {
             $closedate=$null
       }
       else 
       {
          $closedate=$data.GetString(16)  
       }
   
       #imagesrc
       if ($data.IsDBNull(17))
       {
          $imagesrc=$null
       }
       else 
       {
          $imagesrc=$data.GetString(17)  
       }  
       
       #link
       if ($data.IsDBNull(18))
       {
          $link=$null
       }
       else 
       {
          $link=$data.GetString(18)
       }
       
       #site
       if ($data.IsDBNull(19))
       {
          $site=$null
       }
       else 
       {
          $site=$data.GetString(19)
       }
          
       $objComic = New-Object System.Object
       $objComic | Add-Member -type NoteProperty -name Title -value $data.GetString(1)
       $objComic | Add-Member -type NoteProperty -name Issue -value $data.GetString(3)
       $objComic | Add-Member -type NoteProperty -name Price -value $price
       $objComic | Add-Member -type NoteProperty -name Seller -value $seller
       $objComic | Add-Member -type NoteProperty -name Bought -value $data.GetString(4)
       $objComic | Add-Member -type NoteProperty -name DateOfSale -value $data.GetString(5)
       $objComic | Add-Member -type NoteProperty -name status -value $data.GetString(6)
       $objComic | Add-Member -type NoteProperty -name postage -value $postage
       $objComic | Add-Member -type NoteProperty -name ebayitem -value $ebayitem
       $objComic | Add-Member -type NoteProperty -name description -value $description
       $objComic | Add-Member -type NoteProperty -name publishdate -value $publishdate
       $objComic | Add-Member -type NoteProperty -name quantity -value $data.GetDouble(11)
       $objComic | Add-Member -type NoteProperty -name AuctionType -value $auctiontype
       $objComic | Add-Member -type NoteProperty -name BestOffer -value $BestOffer
       $objComic | Add-Member -type NoteProperty -name BidCount -value $BidCount
       $objComic | Add-Member -type NoteProperty -name buyitnowprice -value $buyitnowprice
       $objComic | Add-Member -type NoteProperty -name closedate -value $closedate
       $objComic | Add-Member -type NoteProperty -name Imagesrc -value $Imagesrc
       $objComic | Add-Member -type NoteProperty -name link -value $link
       $objComic | Add-Member -type NoteProperty -name site -value $site
       #remaining
       $objComic
   }
   
   $conn.Close()
}

function estimate-price()
{
   param(
   [string]$title,
   [string]$Issue)
   
   $results=query-db "where title='$title' and issue='$issue' and status='CLOSED'"
   
   if ($results -eq $NULL)
   {
      return "None Found"
   }
   
   if($results.count)
   {
      $count=$results.count
      
      $minimum=[double]$results[0].Price+[double]$results[0].postage
   }
   else
   {
      $minimum=[double]$results.Price+[double]$results.postage
   }
   
   foreach($comic in $results)
   {      
      $TotalCost=[double]$comic.Price+[double]$comic.postage 
      $minimum=[System.Math]::Min($comic.Price,$minimum)
      $maximum=[System.Math]::Max($comic.Price,$maximum)
      
      if ($comic.Bought -eq $true)
      {
         $paid += $TotalCost
         $owned ++ 
      }
      
      $total += $TotalCost   
      $totalPrice +=[double]$comic.Price
   }
    
    if ($owned)
    {
       $averagepaid=$paid/$owned
    }
    else
    {
       $averagepaid=$null
    }
    
    if ($results.Count)
    {
      $average=$total/$results.Count
      $averagePrice=$totalPrice/$results.Count
    }
    else
    {
       $average=$total
       $averagePrice=$totalPrice
    }
    
    $currentprice=get-currentprice -title $($comic.Title) -issue $issue
    [int]$cover = get-cover $Issue 
    $average="{0:N2}" -f $average
    
    $objStats = New-Object System.Object
    $objStats | Add-Member -type NoteProperty -name Title -value $($comic.Title)
    $objStats | Add-Member -type NoteProperty -name Issue -value $Issue
    $objStats | Add-Member -type NoteProperty -name Cover -value $cover
    $objStats | Add-Member -type NoteProperty -name TotalCost -value $average
    $objStats | Add-Member -type NoteProperty -name AveragePrice -value $averagePrice
    $objStats | Add-Member -type NoteProperty -name CurrentPrice -value $currentprice
    $objStats | Add-Member -type NoteProperty -name Minimum -value $minimum
    $objStats | Add-Member -type NoteProperty -name Maximum -value $maximum
    $objStats | Add-Member -type NoteProperty -name Count -value $count
    $objStats | Add-Member -type NoteProperty -name AveragePaid -value $averagepaid
    $objStats | Add-Member -type NoteProperty -name Stock -value $owned
    
   return $objStats 
}


function bySeller
{
   <#
      .SYNOPSIS 
       For reviewing a set open of comic sales by vendor
	    
      
      .PARAMETER seller
	Specifies the seller. If left blank orders by seller.
	    
      .EXAMPLE
      C:\PS> byseller -seller blackadam 
      
      .EXAMPLE
      C:\PS> byseller -seller blackadam|ogv
      
      .EXAMPLE
            C:\PS> byseller |ogv
      
   #>

   param([string]$seller)
   if ($seller -eq $NULL -or $seller -eq '')
   {
      query-db "where (status='open' OR status='verified') order by seller"
   }
   else
   {
      query-db "where seller='$seller' and (status='open' OR status='verified')"
   }
}

function get-currentprice
{
   Param(
   [string]$title,
   [string]$Issue)
     
   [string]$wherestring="where Title = '$title' And Issue = '$Issue' and Status='CLOSED'"  
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "Select top 5 Price FROM [Comics].[dbo].[Comics] $wherestring order by saledate desc" 
   #write-host "$($cmd.commandtext)"
   $data = $cmd.ExecuteReader()
   $readprice=0
   $counter=0
   while ($data.Read())
      {    
          if (!($data.IsDBNUll(0))) 
          {
            $readprice+=$data.GetValue(0)
            $counter++
          }
      }
  
    if ($counter -ne 0)
    {
       return [double]($readprice/$counter)
    }
    else 
    {
       return 0.00
    }
}