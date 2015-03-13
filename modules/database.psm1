$connection= "Data Source=redwolffour.cloudapp.net;Initial Catalog=comics;User ID=guru;Password=Faithle55;Trusted_Connection=False;Persist Security Info=False;"

function get-pounds
{   <#
      .SYNOPSIS 
       returns clean currency string when given a dirty string    
      
      .PARAMETER dirty
            
      .EXAMPLE
      C:\PS>  get-pounds -dirty    
   #>

   param(
   [Parameter(Mandatory=$true)]
   [string]$dirty)

   Try
   {
      $clean=$dirty.split(" ")
   
      [regex]$r="[^0-9.]"
      
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
   <#
      .SYNOPSIS 
       attempts to find cover issue when given a dirty string    
      
      .PARAMETER dirty
            
      .EXAMPLE
      C:\PS>  get-cover -dirty    
   #>

   param(
   [Parameter(Mandatory=$true)]
   [string]$dirty)
   
   Try
   {
      write-verbose "Analysing cover $dirty"
      if ($dirty.Contains("#"))
      {
         $dirty=$dirty.split("#")[1]
      }
      elseif (($dirty.ToUpper()).Contains("PROG"))
      {
         $dirty=($dirty.ToUpper() -split("PROG"))[1]
      }

      [regex]$r="[^0-9.]"
      $clean=$r.replace($dirty,"")
      $clean=$clean.Replace(":","")
      $clean
    }
    Catch [system.exception]
    {
        throw $_.message
    }
}

function add-record
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
      C:\PS> add-record -title "The Walking Dead" -issue 122 -price 1.75 -status CLOSED -bought $true -site FP -seller FP -postage 0.67
      .EXAMPLE
      C:\PS> add-record -title "The Walking Dead" -issue 123 -price 1.75 -status CLOSED -bought $true -site FP -seller FP -postage 0.67
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
   [string]$seller="",
   [string]$Parentid=$NULL,
   [boolean]$split=0)
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = $connection
   $conn.open()
   
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   
   $DateOfSale=$(Get-date).ToString()
   $saledate = Get-date
   $title=$title.ToUpper()
   $Issue=$Issue.ToUpper()
   $Description=$Description.Replace("'","")
   
   $postage=get-pounds $postage
   $price=get-pounds $price
   
   $cmd.commandtext = "INSERT INTO comics 
   (Title, Price, Issue, Bought, DateOfSale, Status, postage, Description, PublishDate, EbayItem, Quantity, AuctionType, BestOffer, BidCount, BuyItNowPrice, CloseDate, ImageSrc, Link, Site, Remaining, Seller, SaleDate, StartingPrice, Parentid, Split) 
   VALUES
   ('$title', '$Price', '$Issue', '$bought', '$DateOfSale', '$status','$postage', '$Description','$PublishDate', '$ebayitem',$Quantity, '$AuctionType', '$BestOffer', '$BidCount', '$BuyItNowPrice', '$CloseDate', '$ImageSrc', '$Link', '$site', '$remaining', '$seller', '$saledate','$Price', '$Parentid', '$split')" 
   
   write-verbose $cmd.commandtext
   $result=$cmd.executenonquery()
   $conn.close()
}

function get-db
{
   param(
    [Parameter(Mandatory=$true)]
    [string]$ebayitem)

   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = $connection
   $conn.open()
   
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "select title FROM [Comics].[dbo].[Comics] where ebayitem='$ebayitem'"
   $data= $cmd.ExecuteReader()
   $result = @()
   $count=0
   
   while ($data.Read())
   {
      $result=$result+$data.GetString(0)
      $count++
   }
   
   $conn.close()
   $result.count
}

function update-db
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
   [string]$seller=$NULL,
   [System.Nullable[System.Boolean]]$watch
   )
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = $connection
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
   
   $updatestring="DateOfSale='$($saledate.ToString())'" 
   
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
   
   If (($watch -eq "") -or ($watch -eq $null))
   {
      #write-Host "watch not set:$watch"
   }
   else
   {
      $updatestring=$updatestring+", watch='$watch'"
   }
 
   $cmd.commandtext = "update Comics.dbo.Comics SET $updatestring where Ebayitem = '$ebayitem' and (status !='CLOSED' OR status !='expired')" 
   write-verbose $cmd.commandtext
   
   $transactionComplete=$NULL

   do 
   {
      try
      {   
         $result=$cmd.executenonquery()
         $transactionComplete = $true
      }
      catch
      {
         $transactionComplete = $false
      }
      
   }
   until ($transactionComplete)


   $conn.close()
}

function search-db
{
   Param(
   [string]$wherestring="where Title = '$title' And Issue = '$Issue'")
     
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString =$connection
   
   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "SELECT 
       [Seller],[Title],[Price]
      ,[Issue],[Bought],[DateOfSale],[Status]
      ,[postage],[Ebayitem],[Description],[PublishDate]
      ,[Quantity],[AuctionType],[BestOffer],[BidCount]
      ,[BuyItNowPrice],[CloseDate],[ImageSrc],[Link]
      ,[Site],[Remaining],[watch] 
      FROM comics $wherestring"

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

       $BestOffer=0
       
       #BestOffer
       if (!($data.IsDBNull(13)))
       {    
         if ($data.GetString(13))
          {
             $BestOffer=get-pounds -dirty "$($data.GetString(13))" 
          }
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
          if ($data.GetString(15))
          {
             $buyitnowprice=($data.GetString(15)).Replace("&#163;","")
             $buyitnowprice=get-pounds -dirty $buyitnowprice  
          }
          else
          {
             $buyitnowprice=0
          }
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
        
       #watch
       if ($data.IsDBNull(20))
       {
          $watch=$null
       }
       else 
       {
          $watch=$data.GetValue(20)
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
       $objComic | Add-Member -type NoteProperty -name watch -value $watch
       #remaining
       $objComic
   }
   
   $conn.Close()
}

function get-priceestimate
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$Issue)
   
   $results=search-db "where title='$title' and issue='$issue' and status='CLOSED'"
   [decimal]$maximum=0
   [int]$count      =1
   [int]$owned      =0

   if ($results -eq $NULL)
   {
      return $null
   }
   
   if($results -is [system.array])
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
         $ComicPrice+=[double]$comic.Price
         $paid += $TotalCost
         $owned ++ 
      }
      
      $total += $TotalCost   
      $totalPrice +=[double]$comic.Price
   }
    
    if ($owned)
    {
       $averagepaid=$paid/$owned
       $avComicPrice=$ComicPrice/$owned
    }
    else
    {
       $averagepaid=$null
       $avComicPrice=$null
    }
    
    if ($results -is [system.array])
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

    [int]$cover = get-cover -dirty $issue 
    $mean=$average
    $average="{0:N2}" -f $average
    $date=Get-date 
    
    $objStats = New-Object System.Object
    $objStats | Add-Member -type NoteProperty -name Title -value $($comic.Title)
    $objStats | Add-Member -type NoteProperty -name Issue -value $Issue
    $objStats | Add-Member -type NoteProperty -name Cover -value $cover
    $objStats | Add-Member -type NoteProperty -name TotalCost -value $average
    $objStats | Add-Member -type NoteProperty -name Mean -value $Mean
    $objStats | Add-Member -type NoteProperty -name AveragePrice -value $averagePrice
    $objStats | Add-Member -type NoteProperty -name CurrentPrice -value $currentprice
    $objStats | Add-Member -type NoteProperty -name Minimum -value $minimum
    $objStats | Add-Member -type NoteProperty -name Maximum -value $maximum
    $objStats | Add-Member -type NoteProperty -name Count -value $count
    $objStats | Add-Member -type NoteProperty -name AveragePaid -value $averagepaid
    $objStats | Add-Member -type NoteProperty -name AverageNetPaid -value $avComicPrice
    $objStats | Add-Member -type NoteProperty -name Stock -value $owned
    $objStats | Add-Member -type NoteProperty -name Date -value $date
    
   return $objStats 
}

function get-selleritems
{
   <#
      .SYNOPSIS 
       For reviewing a set open of comic sales by vendor
            
      .PARAMETER seller
    Specifies the seller. If left blank orders by seller.
        
      .EXAMPLE
      C:\PS> get-selleritems -seller blackadam 
      
      .EXAMPLE
      C:\PS> get-selleritems -seller blackadam -nogrid
      
      .EXAMPLE
            C:\PS> byseller |ogv
      
   #>

   param(
   [Parameter(Mandatory=$true)]
   [string]$seller,
   [switch]$nogrid)

   if ($seller -eq $NULL -or $seller -eq '')
   {
      $resultsset=search-db "where (status='open' OR status='verified') order by seller"
   }
   else
   {
      $resultsset=search-db "where seller='$seller' and (status='open' OR status='verified')"
   }
   
   if ($nogrid)
   {
      $resultsset
   }
   else
   {
      $resultsset|ogv
   }

}

function get-currentprice
{
   <#
      .SYNOPSIS 
       gets the current market price    
      
      .PARAMETER title
      The comics title

      .PARAMETER Issue
      The issue for pricing
        
      .EXAMPLE
      C:\PS>  get-currentprice -Issue 127 -title "The Walking Dead" 
   #>

   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$Issue)
     
   [string]$wherestring="where Title = '$title' And Issue = '$Issue' and Status='CLOSED'"  
   
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString =$connection
   
   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "Select top 5 Price FROM [Comics].[dbo].[Comics] $wherestring order by saledate desc" 
   
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

function update-issue
{
   <#
      .SYNOPSIS 
       For modifying the issue for a given record    
      
      .PARAMETER OldIssue
      
      .PARAMETER NewIssue
      
      .PARAMETER title
        
      .EXAMPLE
      C:\PS>  update-issue -OldIssue 127:SIGNED -title "The Walking Dead" -NewIssue 127SIGNED         
   #>
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$OldIssue,
   [Parameter(Mandatory=$true)]
   [string]$NewIssue)
   
   $NewIssue=$NewIssue.ToUpper()

   write-Host "Modifying issue $OldIssue - $title to $NewIssue" -ForegroundColor  cyan 
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = $connection

   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "update comics set issue='$NewIssue' where title='$title' and issue='$OldIssue'"

   $result = $cmd.ExecuteNonQuery()
   $conn.Close()

   $oldimage=get-imagefilename -title $title -issue $Oldissue
   $newimage=get-imagefilename -title $title -issue $newissue

   If(test-path $oldimage)
   {
      if(test-path $newimage)
      {
         ri $oldimage
      }
      else
      {
         move-item -Path "$oldimage" -Destination "$newimage"
      }
   }


   Write-Host "Updated $result records"
}
