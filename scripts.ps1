$dbfile="C:\comics\data.XML"

import-module "C:\Users\Jim\Documents\GitHub\EbayRssPowershellModule\EbayRssPowershellModule.psm1" -force

function read-db
{
   [xml]$comics= Get-Content $dbfile
   $comics
}

function add 
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
   [int]$quantity=1
   )

   if (!(test-path $dbfile))
   {
      new-xmlfile $dbfile
   }
   
   #write-host "Updating $dbfile"
   try 
   {
      $doc = [xml](Get-Content -Path $dbfile) 
      $element = $doc.CreateElement("Comic")
      $element.SetAttribute('Title',$title)
      $element.SetAttribute('Description', $Description.substring(0, [System.Math]::Min(250, $Description.Length)))
      $element.SetAttribute('Price',$Price)
      $element.SetAttribute('Issue',$Issue)
      $element.SetAttribute('Bought',$bought)
      $element.SetAttribute('PublishDate',$PublishDate)
      $element.SetAttribute('EbayItem', $EbayItem)
      $element.SetAttribute('Status', $Status)
      $saledate = Get-Date 
      $element.SetAttribute('DateOfSale', $saledate)
      $element.SetAttribute('Postage', $postage)
      $element.SetAttribute('AuctionType', $AuctionType)
      $element.SetAttribute('BestOffer', $BestOffer)
      $element.SetAttribute('BidCount', $BidCount)
      $element.SetAttribute('BuyItNowPrice', $BuyItNowPrice)
      $element.SetAttribute('CloseDate', $CloseDate)
      $element.SetAttribute('ImageSrc',$ImageSrc)
      $element.SetAttribute('Link',$Link)
      $element.SetAttribute('Site',$site)
      $element.SetAttribute('Quantity',$quantity)
      
      $doc.DocumentElement.AppendChild($element)

      $doc.Save($dbfile)
      #write-host "Updated $dbfile."
   }
   catch 
   {
      Write-error "Failed to write item $EbayItem:$title"
      exit 1
   }
}

function new-xmlfile ()
{
   param ([string]$filename)

   $doc = new-object xml
   $decl = $doc.CreateXmlDeclaration("1.0", $null, $null)
   $rootNode = $doc.CreateElement("root");
   $doc.InsertBefore($decl, $doc.DocumentElement)
   $doc.AppendChild($rootNode);
   $doc.Save($filename)
   write-warning "Created new db file $filename"
}

function find()
{
   param([string]$title,[string]$Issue)
   $test=read-db
   $result=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And $_.Status -eq "CLOSED"}
   
   [double]$total=0
   [double]$maximum=0
   [double]$minimum=0
   
   [int]$count=1
   [int]$owned=$NULL
   [double]$paid=$NULL
   [double]$postage=$NULL
   
   if ($result -eq $NULL)
   {
      return "None Found"
   }
   
   if($result.count)
   {
      $count=$result.count
      #Write-host $result.count
      $minimum=[double]$result[0].Price+[double]$result[0].postage
   }
   else
   {
      $minimum=[double]$result.Price+[double]$result.postage
   }
   
   foreach($comic in $result)
   {      
      [string]$comic.Price=[double]$comic.Price+[double]$comic.postage 
      $minimum=[System.Math]::Min($comic.Price,$minimum)
      $maximum=[System.Math]::Max($comic.Price,$maximum)
      
      if ($comic.Bought -eq $true)
      {
         $paid += $comic.Price
         $owned ++ 
      }
      
      $total += $comic.Price   
   }
   
    $averagepaid=$paid/$owned
    if ($result.Count)
    {
      $average=$total/$result.Count
    }
    else
    {
       $average=$total
    }
    
    $average="{0:N2}" -f $average
    
    $objStats = New-Object System.Object
    $objStats | Add-Member -type NoteProperty -name Title -value $($comic.Title)
    $objStats | Add-Member -type NoteProperty -name Issue -value $Issue
    $objStats | Add-Member -type NoteProperty -name TargetPrice -value $average
    $objStats | Add-Member -type NoteProperty -name Minimum -value $minimum
    $objStats | Add-Member -type NoteProperty -name Maximum -value $maximum
    $objStats | Add-Member -type NoteProperty -name Count -value $count
    $objStats | Add-Member -type NoteProperty -name AveragePaid -value $averagepaid
    $objStats | Add-Member -type NoteProperty -name Stock -value $owned
   return $objStats 
}

function stat()
{
   param([string]$title,
   [string]$Issue)
   $test=read-db
   if ($Issue)
   {
      $test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue} 
   }
   else
   {
      $test.root.comic| where-object {$_.Title -eq $title}| Sort-Object Issue 
   }
}

function add-array()
{
   param(
   [Parameter(Mandatory=$true)]
   $resultset, 
   [Parameter(Mandatory=$true)]
   $title, 
   [Parameter(Mandatory=$true)]
   $issue)
   
   #first lets read in all existing related items
   $test=read-db
   $existingrecords=$test.root.comic| where-object {$_.Title -eq $title}
   
   #$existingrecords.count
   #$resultset.count
   
   foreach ($old in $existingrecords)
   {
      $resultset=$resultset|where {$_.Ebayitem -ne $old.ebayItem}
   }
   
   #test $existingrecords.Ebayitem  $result.Ebayitem 
   #add state as pending for live auctions
   if ($resultset -ne $Null)
   {
      foreach($result in $resultset)
      {
         $trimmedtitle=clean-string $result.Title
         
         add -title $title -issue $issue -price $result.CurrentPrice -bought $false -PublishDate $result.PublishDate -Ebayitem $result.Ebayitem `
             -Status "Open" -Description $trimmedtitle -AuctionType $result.AuctionType -BestOffer $result.BestOffer -BidCount $result.BidCount `
             -BuyItNowPrice $result.BuyItNowPrice -CloseDate $result.CloseDate -ImageSrc $result.ImageSrc -Link $result.Link
      }
      
      if ($resultset.count)
      {
         "Added $($resultset.count) records"
      }   
      else
      {
         "Added 1 record"
      }
   }
   Else
   {
      "None Added"
   }   
}


function verify()
{
   param([string]$title,[string]$Issue)
   $test=read-db
   $result=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And $_.Status -eq "Open"}
   $result
}

function update()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$ebayitem,
   [string]$UpdateValue,
   [string]$price,
   [string]$postage,  
   [string]$title,
   [string]$status="VERIFIED"
   )
   
   # if loading the XML from file then do this
   $doc = New-Object System.Xml.XmlDocument
   $doc.Load($dbfile)

   $selectstring="//Comic[@EbayItem = '$ebayitem']"
   $comic = $doc.SelectSingleNode("$selectstring")
   
   if ($UpdateValue -eq $NULL -or $UpdateValue -eq "" )
   {
      $comic.Issue = $comic.Issue
   }
   else
   {
      $comic.Issue = $UpdateValue
   }
   
   if ($title)
   {
      $comic.title=$title
   }
   
   if ($price)
   {
      $comic.price=$price
   }
   
   if ($postage)
   {
      $comic.postage=$postage
   }
   
   $comic.Status = $status

   $doc.Save($dbfile)
}

function view
{
   param($ebayid)
   $IE=new-object -com internetexplorer.application
   $url="www.ebay.co.uk/itm/$ebayid"
   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true
}

function view-url
{
   param($url)
   $IE=new-object -com internetexplorer.application
   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true
}



function update-recordset
{

#renaming comic is an issue
   Param(
         [Parameter(Mandatory=$true)]
         [string]$title,
         [Parameter(Mandatory=$true)]
         [string]$Issue)
   
   $test=read-db
   $results=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And ($_.Status -eq "VERIFIED" -or $_.Status -eq "Open")}

   if ($results -eq "" -or $results -eq $Null)
   { 
      return "None found."
   }
   else
   {
      If ($results.count)
      {
         "$($results.count) Records"
      }
      else
      {
         "1 Record"
      }
   }
      
   try
   {
      foreach($record in $results)
      {
         update-record $record 
      }
   }
   catch
   {
    throw $_.Exception
    exit 1
   }
}

function update-record
{
   param(
   $record, 
   [string]$newstatus)
   
   if ($record.ebayitem)
   {
      switch ($record.site)
      {
         "ebay"
         {
            view $record.ebayitem         
         }
         "ebid"
         {
            view-url $record.link
         }
         default
         {
	    view-url $record.link
	 }
      }
   }
         
   [decimal]$price=read-host "Price $($record.Price)"
   if ($price -eq $NULL -or $price -eq 0)
   {
      $price=$record.Price
   }
         
   [decimal]$postage=read-host "Postage $($record.postage)"
   
   $newtitle=read-host "Title $($record.title)"
         
   $actualIssue=read-host "Issue $($record.Issue)"
   if ($actualIssue -eq $NULL -or $actualIssue -eq "")
   {
      $actualIssue=$record.Issue
   }
   
   [string]$newstatus=read-host $record.Status "(V=Verified, C=Closed, E=Expired)"
   
   switch($newstatus)
   {
      "C"
      {
         $newstatus="CLOSED"
      }
      "V"
      {
         $newstatus="VERIFIED"
      }
      "E"
      {
         $newstatus="EXPIRED"    
      }   
      default
      {
         $newstatus=$record.status
      }
   }
      
   update $record.ebayitem $actualIssue $price $postage $newtitle -Status $newstatus
}

function Finalize-Records()
{
   Param(
        [Parameter(Mandatory=$true)]
        [string]$title,
        [Parameter(Mandatory=$true)]
        [string]$Issue)
   
   $test=read-db
   $results=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And ($_.Status -eq "VERIFIED")}

   $result=$results

   if ($results -eq "" -or $results -eq $Null)
   { 
      return "None found."
   }
      
   try
   {
      foreach($record in $results)
      {
         update-record $record 
      }
   }
   catch
   {
    throw $_.Exception
    exit 1
   }
}

function Clean-String()
{
   param([string]$dirty)
   [string]$clean=$dirty.Replace("Â", "")
   $clean.substring(0, [System.Math]::Min(250, $clean.Length))
}

function get-ebidresults()
{
   param([string]$url)
   
   $WebClient = New-Object System.Net.WebClient
   $Results = $WebClient.DownloadString("$url")
   return [xml]"${Results}" 
}

function add-ebidarray
{
   param([xml]$results,
   [string]$title)
   
   foreach ($set in $results.rss.channel.item)
   {
      add-ebid $set $title
   }
}

function add-ebid 
{
   param($ebiditem,
   [string]$comic,
   [int]$issue)
   
   add -title $comic -issue $issue -price $ebiditem.price -PublishDate $ebiditem.pubdate -Status "OPEN" -Description $ebiditem.description[0]."#cdata-section"`
   -postage $ebiditem.Shipping -BidCount $ebiditem.bids -BuyItNowPrice $ebiditem.buynowprice -ImageSrc $ebiditem.image -Link $ebiditem.link`
   -site "Ebid" -quantity $ebiditem.quantity -Ebayitem $ebiditem.id 
}

new-alias fr Finalize-Records -force
new-alias ur update-recordset -force