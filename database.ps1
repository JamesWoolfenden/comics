#[assembly.reflection]::loadwithpartialname('System.Data')
#$conn = New-Object System.Data.SqlClient.SqlConnection
#$conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
#$conn.open()
#$title="The Walking Dead"
#$description ="The description"
#$issue = "1"
#$ebayid=1221342343

function add-record()
{
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
   [string]$Status="Closed",
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
   
   $cmd.commandtext = "INSERT INTO comics 
   (Title, Price, Issue, Bought, DateOfSale, Status, postage, Description, PublishDate, EbayItem, Quantity, AuctionType, BestOffer, BidCount, BuyItNowPrice, CloseDate, ImageSrc, Link, Site, Remaining, Seller) 
   VALUES
   ('$title', '$Price', '$Issue', '$bought', '$saledate', '$status','$postage', '$Description','$PublishDate', '$ebayitem','$Quantity', '$AuctionType', '$BestOffer', '$BidCount', '$BuyItNowPrice', '$CloseDate', '$ImageSrc', '$Link', '$site', '$remaining', '$seller')" 
   
   #$cmd.commandtext 
   
   $result=$cmd.executenonquery()
   $conn.close()
   #$result
}

function update-db()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$ebayitem,
   [Parameter(Mandatory=$true)]
   [string]$UpdateValue,
   [Parameter(Mandatory=$true)]
   [string]$price,
   [string]$postage,  
   [Parameter(Mandatory=$true)]
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
   
   $updatestring="Issue='$UpdateValue', Price='$price', title='$title'"
   
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
   }
   
   if ($seller -ne "")
   {
      $updatestring=$updatestring+", seller='$seller'"
   }
   
   
   $cmd.commandtext = "update Comics.dbo.Comics SET $updatestring where Ebayitem = '$ebayitem'" 
   
   #$cmd.commandtext 
      
   $result=$cmd.executenonquery()
   $conn.close()
   #$result
}


function query-db()
{
   $conn = New-Object System.Data.SqlClient.SqlConnection
   $conn.ConnectionString = "Data Source=localhost\r2;Initial Catalog=comics;Integrated Security=SSPI;"
   $conn.open()
   $cmd = New-Object System.Data.SqlClient.SqlCommand
   $cmd.connection = $conn
   $cmd.commandtext = "SELECT * FROM comics"

   $data = $cmd.ExecuteReader()
   $count=0
   
   while ($data.Read())
   {    
     write-host $data.GetString(0) $data.GetDouble(1) $data.GetString(2) $data.GetString(3) 
   }

   $conn.Close()
}
