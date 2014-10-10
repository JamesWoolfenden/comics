#set-strictmode -Version Latest

$corescript=$myinvocation.mycommand.path
if ($corescript -eq $null)
{
   $root=$root=(gl).Path
}
else
{
   $root=split-path -parent -Path $corescript
}

$dbfile="$root\data.XML"
$imageroot= "$root\covers"

import-module "$root\rss\EbayRssPowershellModule.psm1" -force
import-module "$root\database.ps1"
import-module "$root\split-set.ps1"
import-module "$root\show-image.ps1"
import-module "$root\form.ps1"
import-module "$root\info.ps1"
import-module "$root\core.ps1"
import-module "$root\search-data.ps1"
import-module "$root\review.ps1"


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

             Write-host "`r`nAdding " -nonewline
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
                 Write-host "`rUpdating $($set.Ebayitem)" -foregroundcolor green  -NoNewline 
              }
              else
              {
                 update-db -ebayitem $set.Ebayitem -status $status  -price $set.CurrentPrice
                 Write-host "`rClosing $($set.Ebayitem)"  -NoNewline 
              }            
                
          }
      }
      
      if ($count)
      {
         "`nAdded $count record(s)"
      }         
   }
   Else
   {
      "`nNone Added"
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
      If ($results -is [system.array])
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

function clean-string()
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
          write-host "`rSkipping $($set.id)" -nonewline -foregroundcolor yellow
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
      
   write-host "Adding $title $($set.ebayid)"
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
     write-host "`nSold" -foregroundcolor cyan
     add-array $soldresult -title "$comictitle" -issue 0 -Status Closed
   }
   
   # this is the closed results
   write-debug "Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'closed'|where {_.BidCount -ne '0'}"
   $expiredresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'closed'|where {$_.BidCount -eq "0"}
   if ($expiredresult)
   {
      write-host "`r`nExpired" -foregroundcolor cyan
      add-array $expiredresult -title "$comictitle" -issue 0 -Status Expired
   }
   
   #these 
   $result=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'Open'
   if ($result)
   {
      write-debug "`r`nOpen" 
	  if ($result.count)
	  {
	     write-host "`n`tEbay found: $($result.count)"
	  }
	  else
      {
         write-host "`n`tEbay found: 0"
      }

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
   [Parameter(Mandatory=$true)]
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

function datestring
{
   $date=(get-date).Date
   "$($date.day)-$($date.month)-$($date.year)"
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
   if ($ebidresults.count)
   {
      write-host "`tEbid found: $($ebidresults.count)" -foregroundcolor green
   }
   else
   {
      write-host "`tEbid found: 0"
   }

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
