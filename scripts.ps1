#set-strictmode -Version Latest

$corescript=$myinvocation.mycommand.path
$root=split-path -parent  $corescript
$dbfile="$root\data.XML"
$imageroot= "$root\covers"

import-module "$root\EbayRssPowershellModule\EbayRssPowershellModule.psm1" -force
import-module "$root\database.ps1"
import-module "$root\split-set.ps1"
import-module "$root\show-image.ps1"
import-module "$root\form.ps1"
import-module "$root\info.ps1"
import-module "$root\core.ps1"
import-module "$root\search-data.ps1"



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

function stat()
{
   param([string]$title,
   [string]$Issue)
    
   if ($Issue)
   {
      query-db "where Title = '$title' And Issue ='$Issue'" 
   }
   else
   {
      query-db "where Title = '$title' order by issue" 
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
   
   $list=query-db "Where Ebayitem != NULL"|select -property Ebayitem
   $Ebayitems=$list|foreach {"$($_.EbayItem)"}
   
   if ($resultset -ne $Null)
   {
      $count=0
      
      foreach ($set in $resultset)
      {       
          if (!(get-db $set.ebayitem))
          {
             $trimmedtitle=clean-string $set.Title
             
             $AuctionType=$set.AuctionType
             if ($AuctionType.Count -gt 1)
             {
                $AuctionType="Mixed"
             }
             
             Write-host "Adding " -nonewline
             Write-host "$($set.Ebayitem)" -foregroundcolor red
             add-record -title $title -issue $issue -price $set.CurrentPrice -bought $false -PublishDate $set.PublishDate -Ebayitem $set.Ebayitem `
	         -Status "Open" -Description $trimmedtitle -AuctionType $AuctionType -BestOffer $set.BestOffer -BidCount $set.BidCount `
                 -BuyItNowPrice $set.BuyItNowPrice -CloseDate $set.CloseDate -ImageSrc $set.ImageSrc -Link $set.Link
                 
             $count++
          }
          else
          {
              if ($status -ne "Closed")
              {
                 update-db -ebayitem $set.Ebayitem -status $status -price $set.CurrentPrice
                 Write-host "Updating " -nonewline
                 Write-host "$($set.Ebayitem)" -foregroundcolor green
              }
              else
              {
                 update-db -ebayitem $set.Ebayitem -status $status  -price $set.CurrentPrice
                 Write-host "Closing " -nonewline 
                 write-host "$($set.Ebayitem)" -foregroundcolor green
              }              
          }
      }
      
      if ($count)
      {
         "Added $count record(s)"
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
   query-db "where title='$title' and issue='$issue' and status='open'"
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

   $IE.Top   =10
   $IE.Left  =10
   $IE.Height=600
   $IE.Width =800

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
   $IE.Top   =10
   $IE.Left  =10
   $IE.Height=600
   $IE.Width =800

   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true
   $IE
}

function update-recordset
{
  <#
      .SYNOPSIS 
       For reviewing a set of comic records
	    
      
      .PARAMETER title
	Specifies the comic.
      .PARAMETER Issue
	Specifies the comic issue.
      .PARAMETER sortby
	Specifies the order parameter.
      .PARAMETER status
	An override to see comics in a certain status e.g. CLOSED.
	    
      .EXAMPLE
      C:\PS> update-recordset -title "The Walking Dead" -issue "1A" 
      
      .EXAMPLE
      C:\PS> ur -title "The Walking Dead" -issue "1A" 
   #>

   #renaming comic is an issue
   Param(
         [Parameter(Mandatory=$true)]
         [string]$title,
         [string]$Issue,
         [string]$sortby="DateOfSale",
         [string]$status)
   
   $querystring="where title='$title'"
   
   if ($Issue)
   {
      $querystring +="and issue='$issue'"
   }
   
   if($status)
   {
      $querystring +=" and (status='$status') order by $sortby"
   }
   else
   {
      $querystring +=" and (status='verified' or status='open') order by $sortby"
   }
   
   $results=query-db "$querystring"
   
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
      [int]$total=$($results.count)
      if ($total -eq $NULL)
      {
         $total=1
      }

      foreach($record in $results)
      {
         Write-host "$counter of $total"
         
         if ($record.Ebayitem -eq "" -or $record.Ebayitem -eq $null) 
         {
           write-host "Skipping item: record.Ebayitem is nothing" -foregroundcolor yellow
         }
         else 
         {
           update-record $record 
         }
         
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
   [Parameter(Mandatory=$true)]
   $record, 
   [string]$newstatus)
   
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
   
   waitforpageload
      
   if ($record.site -eq "ebay")
   {
      $estimate=$ie.Document.getElementByID('fshippingCost').innerText
      if ($record.seller -eq "" -or $record.seller -eq $NULL)
      {
         write-host "Finding seller"
         $result=@($ie.Document.body.getElementsByClassName('mbg-nw'))
         $seller=$result[0].innerText
      }
      else
      {
         $seller=$record.seller
      }
   }
   Else
   {
      $estimate=$record.postage
      if ($record.site -eq "ebid" -And $record.seller -eq "")
      {
         $seller=($ie.Document.body.document.body.getElementsByTagName('a')| where{$_.innerHTML -eq "All about the seller"}).nameProp
      }
      else
      {
         $seller=$record.seller
      }
   }
   
   $newtitle=read-host "Title $($record.title)"
   if ($newtitle -eq $NULL -or $newtitle -eq "")
   {
      $newtitle=$record.title
   }  
   
   $newtitle=$newtitle.ToUpper()  
    
   $color=found-image  -title $newtitle -issue $record.Issue
   
   if ($record.Issue -eq "0")
   {   
      $estimateIssue=$record.Issue
      while (($estimateIssue -eq "0") -or ($estimateIssue -eq ""))
      {
         write-host "Estimate issue ($($record.Issue)):" -Foregroundcolor $color -nonewline
         $estimateIssue=read-host    
      }
   }
   else
   {
      $estimateIssue=$($record.Issue)
   }
   
   $color=found-image  -title $newtitle -issue $estimateIssue
   
   write-host "Issue $($estimateIssue) or (i)dentify:" -Foregroundcolor $color -nonewline
   $actualIssue=read-host  
   
   if ($actualIssue -eq "i")
   {
     $actualIssue=get-imagetitle -issue (get-cover $estimateIssue) -title $newtitle
   }
   
   if ($actualIssue -eq $NULL -or $actualIssue -eq "")
   {
      $actualIssue=$estimateIssue
   }   
   
   $actualIssue=$actualIssue.ToUpper()
   if (!(test-image -title $newtitle -issue $actualIssue))
   {
      if ($($record.ImageSrc))
      {
         Write-host "Updating Library with image of $newtitle : $actualIssue" -foregroundcolor cyan
         $filepath= get-imagefilename -title $newtitle -issue $actualIssue
         Write-host "Downloading from $($record.Imagesrc) " 
         Write-host "Writing to $filepath" 
         set-imagefolder $newtitle $actualIssue
         Invoke-webRequest $($record.ImageSrc) -outfile $filepath 
      }
      Else
      {
         Write-host "No image data"
      }
   }
   
   
   $newquantity  = new-object int 
   
   $newquantity=1
   
   if ($($record.Quantity) -gt 0)
   {
      $newquantity=$($record.Quantity)
   }
   
   if ($actualIssue -eq "SET" -And $($record.Quantity) -eq 1)
   {
      $readquantity=read-host "Number in set:$($record.Quantity)"
      if  ($readquantity -gt 0)
      {
         $newquantity = $readquantity
      }
   }   
      
   write-host "Seller: $seller"
   $priceestimate=0
   [double]$marketprice=0
   [double]$marketprice=get-currentprice -issue $actualIssue -title $newtitle
   
   $foregroundcolor="red"
   
   if ($marketprice -gt [double]$($record.Price))
   {
      $foregroundcolor="green"
   }
   
   $marketprice="{0:N2}" -f $marketprice   
   
   if ($record.site -eq "ebay")
   {
      $priceestimate= $ie.Document.getElementByID('prcIsum').innerText
      if ($priceestimate -eq $NULL)
      {
         $priceestimate= ($ie.Document.getElementByID('prcIsum_bidPrice').innerText)      
      }
      
      #still null must have stopped auction?
      if ($priceestimate -eq $NULL)
      {
         $closedpriceestimate = @($ie.Document.body.getElementsByClassName('notranslate vi-VR-cvipPrice'))
         $priceestimate=$closedpriceestimate[0].innerText
      }
      
      if ($priceestimate -ne $NULL)
      {
         $priceestimate=$priceestimate.replace("£","")    
      }
      
      Write-host "Price $($record.Price): estimate:$priceestimate market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline    
   }
   else
   {
       Write-host "Price $($record.Price): market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline      
   }
   
   [decimal]$price=read-host 
   
   if ($price -eq $NULL -or $price -eq "")
   {
      $price=$record.Price
   }
   
   $postage=new-object decimal
   $postage=read-host "Postage: $($record.postage) estimate:$estimate"
   $postage="{0:N2}" -f $postage
   if ($postage -eq $NULL -or $postage -eq "")
   {
      $postage=$record.Postage
   }  
   
   $TCO ="{0:N2}" -f ([decimal]$postage+[decimal]$price)/$newquantity
   write-host "TCO per issue $TCO" -foregroundcolor cyan
   
   $bought="false"
   [string]$newstatus=read-host $record.Status "(V)erified, (C)losed, (E)xpired, (B)ought, (W)atch"
   [boolean]$watch=$false
   
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
      "W"
      {
         $newstatus="VERIFIED"
         $watch=$true
      }
      default
      {
         $newstatus=$record.status
         $watch=$record.watch
      }
   }
   
   $IE.Quit()
   Write-debug "update-db -ebayitem $($record.ebayitem) -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -seller $seller -watch $watch"

   update-db -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -bought $bought -quantity $newquantity -seller $seller -watch $watch
}

function Finalize-Records()
{
   Param(
        [Parameter(Mandatory=$true)]
        [string]$title,
        [Parameter(Mandatory=$true)]
        [string]$Issue)
   
   
   $results=query-db "where title='$title' and issue='$issue' and status = 'verified'"
   
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
   param([string]$title=$NULL)
      
   if ($title)
   {
      $query="where status='open' and title='$title'"
   }
   else 
   {
      $query="where status='open'"
   }
   
   $results=query-db $query
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
      write-error $_
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
   
   $resultset=$results.rss.channel
       
   foreach ($set in $resultset.item)
   {       
       if ((get-db $set.id) -eq 0)
       {
          if ($set.title -ne $null)
          {
             add-ebid $set $title
          }
       }
       else
       {
          write-host "Skipping " -nonewline
          write-host "$($set.id)" -foregroundcolor yellow
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
      $ebiditem.Shipping=$($ebiditem.Shipping).Replace("<i>","")
      $ebiditem.Shipping=$($ebiditem.Shipping).Replace("</i>","")   
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
      
   add-record -title $comic -issue $issue -price $ebiditem.price -PublishDate $ebiditem.pubdate -Status "OPEN" -Description "$description"`
   -postage $ebiditem.Shipping -BidCount $ebiditem.bids -BuyItNowPrice $ebiditem.buynowprice -ImageSrc $ebiditem.image -Link $ebiditem.link`
   -site "Ebid" -quantity $ebiditem.quantity -Ebayitem $ebiditem.id -Remaining $ebiditem.remaining  -Seller $seller
      
   write-host "adding $title $($set.ebayid)"
}

function get-records()
{
   param(
   
   [string]$title,
   [string]$exclude="",
   [string]$include="",
   [string]$comictitle=$title)
   
   if ($include -ne $NULL)
   {
     $keywords="$title"+" "+"$include"
   }
   else
   {
      $keywords="$title"
   }
   
   #this is the sold items
   write-debug "Soldresult=Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'sold'|where {$_.BidCount -ne '0'}"
   $soldresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'sold'|where {$_.BidCount -ne '0'}
   if ($soldresult)
   {
     write-host "Sold results" -foregroundcolor cyan
     add-array $soldresult -title "$comictitle" -issue 0 -Status Closed
   }
   
   # this is the closed results
   write-debug "Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'closed'|where {_.BidCount -ne '0'}"
   $expiredresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'closed'|where {$_.BidCount -eq "0"}
   if ($expiredresult)
   {
      write-host "Expired results" -foregroundcolor red
      add-array $expiredresult -title "$comictitle" -issue 0 -Status Expired
   }
   
   #these 
   $result=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'Open'
   if ($result)
   {
      write-host "Open results" -foregroundcolor green
      add-array $result -title "$comictitle" -issue 0
   }
}

function get-issues()
{
   param(
   [string]$title)
   
   $result=query-db "where title='$title'  and status = 'closed'"
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
   [string]$Issue)
   
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
   $exclude,
   $comictitle=$title)
   
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
   
   
   $url = "http://uk.ebid.net/perl/rss.cgi?type1=a&type2=a&words=$title$stringinclude$stringexclude&category2=8077&categoryid=8077&categoryonly=on&mo=search&type=keyword"
   write-debug "Querying ebid $url"
   $ebidresults=get-ebidresults -url $url
   add-ebidarray -results $ebidresults -title $comictitle
}

function get-allrecords()
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [string]$exclude,
   [string]$include,
   [string]$comictitle=$title)
   
   get-ebidrecords -title "$title" -include $include -exclude "$exclude" -comictitle $comictitle
   write-debug "get-records -title $title -include $include -exclude $exclude -comictitle $comictitle"
   get-records -title "$title" -include $include -exclude "$exclude" -comictitle $comictitle
}

function update-number()
{
   Param(
   [string]$Issue,
   [string]$title)
   
   $test=read-db
   $results=$test.root.comic| where-object {$_.title -eq $title -And $_.Issue -eq $Issue -And $_.EbayItem -ne $NULL}
   $results=$results| where-object{$_.EbayItem -ne ""}
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

new-alias gb get-bestbuy -force
new-alias fr Finalize-Records -force
new-alias ur update-recordset -force
new-alias np c:\windows\notepad.exe
new-alias cr closing-record -force  
new-alias ep estimate-price -force
new-alias ap get-allprices -force
new-alias uo update-open -force
