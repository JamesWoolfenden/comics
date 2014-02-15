#set-strictmode -Version Latest

$corescript=$myinvocation.mycommand.path
$root=split-path -parent  $corescript
$dbfile="$root\data.XML"

import-module "C:\Users\Jim\Documents\GitHub\EbayRssPowershellModule\EbayRssPowershellModule.psm1" -force
import-module "$root\database.ps1"

function read-db
{
   [xml]$comics= Get-Content $dbfile
   $comics
}

function waitforpageload {
    while ($ie.Busy -eq $true) { Start-Sleep -Milliseconds 1000; } 
}

function findDiv {param ($name)
    $ie.Document.getElementsByTagName("div") | where-object {$_.id -and $_.id.EndsWith($name)}
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
   [int]$quantity=1,
   [string]$remaining="",
   [string]$seller=""
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
      $element.SetAttribute('Issue',$Issue.ToUpper())
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
      $element.SetAttribute('ImageSrc', $ImageSrc)
      $element.SetAttribute('Link', $Link)
      $element.SetAttribute('Site', $site)
      $element.SetAttribute('Quantity', $quantity)
      $element.SetAttribute('Remaining', $remaining)
      $element.SetAttribute('Seller', $seller)
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

function estimate-price()
{
   param(
   [string]$title,
   [string]$Issue)
   
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
    
    $averagepaid=$paid/$owned
    if ($result.Count)
    {
      $average=$total/$result.Count
      $averagePrice=$totalPrice/$result.Count
    }
    else
    {
       $average=$total
       $averagePrice=$totalPrice
    }
    
    $average="{0:N2}" -f $average
    
    $objStats = New-Object System.Object
    $objStats | Add-Member -type NoteProperty -name Title -value $($comic.Title)
    $objStats | Add-Member -type NoteProperty -name Issue -value $Issue
    $objStats | Add-Member -type NoteProperty -name TotalCost -value $average
    $objStats | Add-Member -type NoteProperty -name TargetPrice -value $averagePrice
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
   $issue,
   $status)
         
   #first lets read in all existing related items
   $test=read-db
   
   $list=$test.root.comic|Where{$_.Ebayitem -ne $NULL -and $_.Ebayitem -ne ""}|select -property Ebayitem
   $Ebayitems=$list|foreach {"$($_.EbayItem)"}
   
   if ($resultset -ne $Null)
   {
      $count=0
      
      foreach ($set in $resultset)
      {       
          if ($Ebayitems -notcontains $set.ebayitem)
          {
             $trimmedtitle=clean-string $set.Title
             
             Write-host "Adding $title $($set.Ebayitem)"
             add -title $title -issue $issue -price $set.CurrentPrice -bought $false -PublishDate $set.PublishDate -Ebayitem $set.Ebayitem `
	         -Status "Open" -Description $trimmedtitle -AuctionType $set.AuctionType -BestOffer $set.BestOffer -BidCount $set.BidCount `
                 -BuyItNowPrice $set.BuyItNowPrice -CloseDate $set.CloseDate -ImageSrc $set.ImageSrc -Link $set.Link
                 
             add-record -title $title -issue $issue -price $set.CurrentPrice -bought $false -PublishDate $set.PublishDate -Ebayitem $set.Ebayitem `
	         -Status "Open" -Description $trimmedtitle -AuctionType $set.AuctionType -BestOffer $set.BestOffer -BidCount $set.BidCount `
                 -BuyItNowPrice $set.BuyItNowPrice -CloseDate $set.CloseDate -ImageSrc $set.ImageSrc -Link $set.Link
                 
             $count++
          }
          else
          {
              if ($status -ne "Closed")
              {
                 update -ebayitem $set.Ebayitem -price $set.CurrentPrice
                 update-db -ebayitem $set.Ebayitem -price $set.CurrentPrice -UpdateValue $issue -title $title -status $status 
                 Write-host "Updating $title $($set.Ebayitem)"
              }
              else
              {
                 update -ebayitem $set.Ebayitem -price $set.CurrentPrice -Status $status
                 update-db -ebayitem $set.Ebayitem -price $set.CurrentPrice -UpdateValue $issue -title $title -status $status
                 
                 Write-host "Closing $title $($set.Ebayitem)"
              }              
          }
      }
      
      if ($count)
      {
         "Added $count record(s)"
      }   
      else
      {
         "No duplicates Added"
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
   [string]$status="VERIFIED",
   [string]$bought,
   [string]$quantity,
   [string]$seller
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
   
   if ($bought)
   {
      $comic.bought=$bought
   }
   
   if ($quantity)
   {
      $comic.quantity=$quantity
   }
   
   if ($seller)
   {
      $comic.seller=$seller
   }
   
   if (($comic.Status -eq "Open") -or ($comic.Status -eq "Verified"))
   {
      [string]$modified=(Get-Date).ToString() 
      $comic.DateOfSale = $modified
   }
   
   $comic.Status = $status

   $doc.Save($dbfile)
}

function view
{
   param($ebayid,
   $IE=$NULL)
   if ($IE -eq $NULL)
   {
      $IE=new-object -com internetexplorer.application
   }
   
   $url="www.ebay.co.uk/itm/$ebayid"
   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true
   $IE
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
         [string]$Issue,
         [string]$sortby="DateOfSale")
   
   $test=read-db
   
   if ($Issue)
   {
      $results=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And ($_.Status -eq "VERIFIED" -or $_.Status -eq "Open")}| Sort-Object "$SortBy"
   }
   Else
   {
      $results=$test.root.comic| where-object {$_.Title -eq $title -And ($_.Status -eq "VERIFIED" -or $_.Status -eq "Open")}| Sort-Object "$SortBy"
   }
   
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
      [int]$counter=1
      foreach($record in $results)
      {
         Write-host "$counter of $($results.count)"
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
            $ie=view $record.ebayitem         
         }
         "ebid"
         {
            view-url $record.link
         }
         default
         {
	    $ie=view $record.ebayitem
	 }
      }
   }
   
   waitforpageload
   
   if ($record.site -eq "ebay")
   {
      $estimate=$ie.Document.getElementByID('fshippingCost').innerText
      $result=@($ie.Document.body.getElementsByClassName('mbg-nw'))
      
      $seller=$result[0].innerText
      
      #$bydiv=$ie.Document.body.getElementsByTagName('div') | 
      #   Where {$_.getAttributeNode('class').Value -eq 'mbg-nw'}
      #write-host $bydiv
      
      #$seller=""
   }
   Else
   {
      $estimate=$record.postage
   }
   
   write-host "Seller: $seller"
   
   [decimal]$price=read-host "Price $($record.Price)"
   if ($price -eq $NULL -or $price -eq "")
   {
      $price=$record.Price
   }
   
   $postage=new-object decimal
   $postage=read-host "Postage $($record.postage) estimate:$estimate"
   if ($postage -eq $NULL -or $postage -eq "")
   {
      $postage=$record.Postage
   }  
   
   $newtitle=read-host "Title $($record.title)"
   if ($newtitle -eq $NULL -or $newtitle -eq "")
   {
      $newtitle=$record.title
   }  
   
   $newtitle=$newtitle.ToUpper() 
    
   $actualIssue=read-host "Issue $($record.Issue)"
   if ($actualIssue -eq $NULL -or $actualIssue -eq "")
   {
      $actualIssue=$record.Issue
   }
   
   $actualIssue=$actualIssue.ToUpper()
   
   $newquantity  = new-object int 
   $newquantity=1
   
   if ($actualIssue -eq "SET" -And $($record.Quantity) -eq "1")
   {
      $newquantity=read-host "Number in set:$($record.Quantity)"
   }   
   
   $bought="false"
   [string]$newstatus=read-host $record.Status "(V=Verified, C=Closed, E=Expired, B=Bought)"
   
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
      "B"
      {
         $newstatus="CLOSED"
         $bought="true"
      }
      default
      {
         $newstatus=$record.status
      }
   }
   
   #Write-Host 'update -ebayitem $($record.ebayitem) -UpdateValue $actualIssue -price $price -postage $postage $newtitle -Status $newstatus'
   #Write-Host "update -ebayitem $($record.ebayitem) -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus"
   
   update -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -bought $bought -quantity $newquantity -seller $seller
   update-db -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -bought $bought -quantity $newquantity  -seller $seller 
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

function update-open()
{
   $test=read-db
   $results=$test.root.comic| where-object {$_.Status -eq "OPEN"}

   $result=$results
   $count=1

   if ($results -eq "" -or $results -eq $Null)
   { 
      return "None found."
   }
   else
   {
      if ($results.count)
      {
         $count=$results.count
      }    
   }
      
   try
   {
      $index=1
      foreach($record in $results)
      {
         write-host "Record $index of $count"
         update-record $record 
         $index ++
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
   [string]$clean=$dirty.Replace("�", "")
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
   
   $resultset=$results.rss.channel
      
   #first lets read in all existing related items
   $test=read-db
   $list=$test.root.comic|Where{$_.Ebayitem -ne $NULL -and $_.Ebayitem -ne ""}|select -property Ebayitem
   $Ebayitems=$list|foreach {"$($_.EbayItem)"}
    
   write-host "Found $($resultset.item.count)"
   
   foreach ($set in $resultset.item)
   {       
       if ($Ebayitems -notcontains $set.id)
       {
          if ($set.title -ne $null)
          {
             write-host "adding $title $($set.ebayid)"
             add-ebid $set $title
          }
       }
   }
}

function add-ebid 
{
   param($ebiditem,
   [string]$comic,
   [int]$issue,
   [string]$seller=""
   )
   
   if ($ebiditem.price -ne $null)
   {
      $ebiditem.price=$($ebiditem.price).Replace("&#163;","")
   }
   else
   {
     $ebiditem.price=0.00
   }
   
   if ($ebiditem.Shipping -ne $null)
   {
      $ebiditem.Shipping=$($ebiditem.Shipping).Replace("&#163;","")
   }
   else
   {
     $ebiditem.Shipping=0.00
   }

   
   if ($ebiditem.Shipping -contains "Free")
   {
      $ebiditem.Shipping =0.00
   }
   
   if ($ebiditem.buynowprice -ne $null)
   {
      $ebiditem.buynowprice=$($ebiditem.buynowprice).Replace("&#163;","")
   }
   else
   {
     $ebiditem.buynowprice=0.00
   }
   
   if ($description -ne $null)
   {
     $description=$ebiditem.description[0]."#cdata-section"
     $description=$description.Replace("'","")
   }
   else
   {
      $description=""
   }   
   
   #$description=$description.substring(0, [System.Math]::Min(255, $description.Length))
   
   add -title $comic -issue $issue -price $ebiditem.price -PublishDate $ebiditem.pubdate -Status "OPEN" -Description "$description"`
   -postage $ebiditem.Shipping -BidCount $ebiditem.bids -BuyItNowPrice $ebiditem.buynowprice -ImageSrc $ebiditem.image -Link $ebiditem.link`
   -site "Ebid" -quantity $ebiditem.quantity -Ebayitem $ebiditem.id -Remaining $ebiditem.remaining -Seller $seller
   
   add-record -title $comic -issue $issue -price $ebiditem.price -PublishDate $ebiditem.pubdate -Status "OPEN" -Description "$description"`
   -postage $ebiditem.Shipping -BidCount $ebiditem.bids -BuyItNowPrice $ebiditem.buynowprice -ImageSrc $ebiditem.image -Link $ebiditem.link`
   -site "Ebid" -quantity $ebiditem.quantity -Ebayitem $ebiditem.id -Remaining $ebiditem.remaining  -Seller $seller
}

function get-records()
{
   param([string]$title,
   [string]$exclude="",
   [string]$include="")
   
   if ($include -ne $NULL)
   {
     $keywords="$title"+" "+"$include"
   }
   else
   {
      $keywords="$title"
   }
   
   $closedresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -closed $true|where {$_.BidCount -ne "0"}
   if ($closedresult)
   {
     add-array $closedresult "$title" 0 -Status Closed
   }
   
   $result=Get-EbayRssItems -Keywords "$keywords"  -ExcludeWords "$exclude"
   if ($result)
   {
      add-array $result "$title" 0
   }
}

function get-issues()
{
   param(
   [string]$title)
   
   $test=read-db
   $result=$test.root.comic| where-object {$_.Title -eq $title -And $_.Status -eq "CLOSED"}
   
   $issuesfound=@()
   
   $issuesfound=$result| select-object -property Issue -unique|sort-object issue
   
   write-host "$($issuesfound.count) unique titles of $title"  
   $issuesfound
}

function get-allprices
{
   param(
      [string]$title)
   $issues=get-issues $title
   
   $prices=@()
   
   foreach($issue in $Issues)
   {
      $localprice=estimate-price -title $title -Issue $($issue.Issue)
      $prices=$prices+$localprice
   }
   
   $prices
}

function closing-record
{
   Param(
            [Parameter(Mandatory=$true)]
            [string]$title,
            [string]$Issue
            )
   update-recordset -title $title -Issue $Issue -sortby DateOfSale
}

function reduce($array, $size)
{
   if ($array.count -gt $size)
   {
      $trimmedarray=new-object "$($array.GetType())" $size
      $arraysize=$array.count
  
      for ($i=0; $i -lt $size; $i++)
      {
         $trimmedarray[$i]=$array[(($arraysize-1)-$i)]
      }
  
      $trimmedarray
   }
   else
   {
      $array
   }
}

function get-ebidrecords()
{
   param(
   $title,
   $include,
   $exclude)
   
   if ($exclude -ne $NULL)
   {
      $excludearray =$exclude.split(" ")
      $excludearray =$excludearray| Foreach-Object{ "%20-$_" }
      foreach ($item in $excludearray)
      {
         $stringexclude=$stringexclude+$item
      }
   }
   else
   {
      $stringexclude=$NULL
   }
   
   if ($include -ne $NULL)
      {
         $includearray =$include.split(" ")
         $includearray =$includearray| Foreach-Object{ "%20$_" }
         foreach ($item in $includearray)
         {
            $stringinclude=$stringinclude+$item
         }
      }
      else
      {
         $stringinclude=$NULL
   }
   
   
   $url = "http://uk.ebid.net/perl/rss.cgi?type1=a&type2=a&words=$title%$stringinclude$stringexclude&category2=8077&categoryid=8077&categoryonly=on&mo=search&type=keyword"
   write-host "Querying ebid $url"
   $ebidresults=get-ebidresults -url $url
   add-ebidarray -results $ebidresults -title $title
}

function get-allrecords()
{
   param(
   [string]$title,
   [string]$exclude,
   [string]$include)
   
   get-ebidrecords -title "$title" -include $include -exclude "$exclude"
   get-records -title "$title" -include $include -exclude "$exclude"
}

new-alias fr Finalize-Records -force
new-alias ur update-recordset -force
new-alias np c:\windows\notepad.exe
new-alias cr closing-record -force  
new-alias ep estimate-price -force
new-alias ap get-allprices -force