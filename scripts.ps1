set-strictmode -version Latest
$imageroot= "$PSScriptRoot\covers"

import-module "$PSScriptRoot\modules\Update-Records.psd1" -force
import-module "$PSScriptRoot\modules\object-helper.ps1"
import-module "$PSScriptRoot\rss\EbayRssPowershellModule.psm1" -force
import-module "$PSScriptRoot\modules\database.psd1" -force
import-module "$PSScriptRoot\modules\multiple.psd1" -force
import-module "$PSScriptRoot\modules\image.psd1" -force
import-module "$PSScriptRoot\modules\form.psd1" -force
import-module "$PSScriptRoot\modules\watch.psd1"
import-module "$PSScriptRoot\core.ps1"
import-module "$PSScriptRoot\modules\search-data.psd1" -force
import-module "$PSScriptRoot\review.ps1"

function waitforpageload {
    while ($ie.Busy -eq $true) { Start-Sleep -Milliseconds 1000; }
}

function findDiv {param ($name)
    $ie.Document.getElementsByTagName("div") | where-object {$_.id -and $_.id.EndsWith($name)}
}

function stat
{
   param(
   [string]$title,
   [string]$Issue,
   [switch]$nogrid)

   $querystring="where Title = '$title'"

   if ($Issue)
   {
      $querystring+=" And Issue ='$Issue'"
   }

   if ($nogrid)
   {
      Search-DB "$querystring"
   }
   else
   {
      Search-DB "$querystring"|ogv
   }
}

function add-array
{
   param(
   [Parameter(Mandatory=$true)]
   $resultset,
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$issue,
   [Parameter(Mandatory=$true)]
   [string]$status)

   #first lets read in all existing related items
   #$test=read-db

   $list=Search-DB "Where Ebayitem != NULL"|select -property Ebayitem
   $Ebayitems=$list|foreach {"$($_.EbayItem)"}

   if ($resultset -ne $Null)
   {
      $count=0

      foreach ($set in $resultset)
      {
		  $foundrecord=Search-DB -where "where ebayitem = '$($set.ebayitem)'"

          #new and not expired records
          if (!($foundrecord) -and ($status -ne "Expired"))
          {
             $trimmedtitle=clean-string $set.Title

             $AuctionType=$set.AuctionType
             if ($AuctionType -is [system.array])
             {
                $AuctionType="Mixed"
             }

             Write-host "`r`nAdding " -nonewline
             Write-host "$($set.Ebayitem)" -foregroundcolor red

             if ($set.CurrentPrice)
             {
                $CurrentPrice=$set.CurrentPrice
             }
             else
			 {
                $CurrentPrice=0
             }

             [string]$bestOffer=$set.BestOffer.ToString()

			 try
			 {
			    add-record -title $title -issue $issue -price $CurrentPrice -bought $false `
			               -PublishDate $set.PublishDate -Ebayitem $set.Ebayitem `
                           -Status "Open" -Description $trimmedtitle -AuctionType $AuctionType -BestOffer $BestOffer -BidCount $set.BidCount `
                           -BuyItNowPrice $set.BuyItNowPrice -CloseDate $set.CloseDate `
			               -ImageSrc $set.ImageSrc -Link $set.Link
             }
			 Catch
			 {
				 $set|Get-member

				 Write-Host "Failed to add record"
				 Write-Host "title $title"
				 Write-Host "issue $issue"
				 Write-Host "price $CurrentPrice"
				 Write-Host "bought $false"
				 Write-Host "PublishDate $($set.PublishDate)"
				 Write-Host "Ebayitem $($set.Ebayitem)"
				 Write-Host "Description $($trimmedtitle)"
				 Write-Host "AuctionType $($AuctionType)"
			     Write-Host "BestOffer $BestOffer"
				 Write-Host "BidCount $($set.BidCount)"
                 Write-Host "BuyItNowPrice $($set.BuyItNowPrice)"
				 Write-Host "CloseDate $($set.CloseDate)"
			     Write-Host "ImageSrc $($set.ImageSrc) "
				 Write-Host "Link $($set.Link)"
				 throw
			 }

             $count++
          }
          else
          {
              #record exist
              if ($status -ne "Expired")
              {
                 #record exists check its not expired or closed
			     if (($foundrecord.Status -eq "Open") -or ($foundrecord.Status -eq "Verified"))
			     {
                    write-verbose " Update-DB -ebayitem $($set.Ebayitem) -status $status -price $($set.CurrentPrice)"
			        if ($status -eq "Open")
                    {
			           Update-DB -ebayitem $set.Ebayitem -price $set.CurrentPrice
                    }

			        Write-host "`rUpdating: $($set.Ebayitem)" -foregroundcolor green  -NoNewline
                 }
			     else
			     {
                    Write-host "`rSkipping: $($set.Ebayitem)" -foregroundcolor yellow  -NoNewline
			     }
              }
          }
      }

	  Write-Host ""

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

function verify
{
   param(
   [string]$title,
   [string]$Issue)

   Search-DB "where title='$title' and issue='$issue' and status='open'"
}

function View
{
   param(
   [string]$ebayid,
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

   while ($ie.ReadyState -ne 4)
   {
      write-host "." -NoNewline
      Start-Sleep -Milliseconds 1000
   }

   $IE
}

function View-URL
{
   param
	(
		[Parameter(Mandatory=$true)]
		[string]$url)

   $IE=new-object -com internetexplorer.application
   $IE.Top   =10
   $IE.Left  =10
   $IE.Height=600
   $IE.Width =800

   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true

   while ($ie.Busy -eq $true)
   {
      write-host "." -NoNewline
      Start-Sleep -Milliseconds 1000
   }

   $ie
}

function view-market
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title)

   $title=$title.replace(" ","")

   $browser=new-object -com internetexplorer.application

   $browser.Top   =10
   $browser.Left  =10
   $browser.Height=600
   $browser.Width =800

   $url="redwolfthree/jqwidgets/demos/jqxgrid/comic-$title.htm"
   $browser.navigate2("$url")
   $browser.visible=$true
   while ($ie.Busy -eq $true)
   {
      write-host "." -NoNewline
      Start-Sleep -Milliseconds 1000
   }
}

function Update-Recordset
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
      C:\PS> Update-Recordset -title "The Walking Dead" -issue "1A"

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

   $results=Search-DB "$querystring"
   $found=0

   if ($results -eq "" -or $results -eq $Null)
   {
      return "None found."
   }
   else
   {
      If ($results -is [system.array])
      {
         $found=$results.count
      }
      else
      {
         $found=1
      }
   }

   "$found Record(s)"

   try
   {
      [int]$counter=1
      [int]$total=$found
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
           Update-Record $record
         }

         $counter++
      }
   }
   catch
   {
     write-host $_.Exception
     write-host "Script:$($_.InvocationInfo.ScriptName):$($_.InvocationInfo.ScriptLineNumber)"
     throw $_.Exception
     exit 1
   }
}

function Finalize-Records
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$Issue)


   $results=Search-DB "where title='$title' and issue='$issue' and status = 'verified'"

   if ($results -eq "" -or $results -eq $Null)
   {
      return "None found."
   }

   try
   {
      foreach($record in $results)
      {
         $result=Update-Record $record
         if (!$result)
         {
            Write-Host "$(Get-date) - Finalise record failure expired"
         }
      }
   }
   catch
   {
    throw $_.Exception
    exit 1
   }
}

function Update-Open
{
   <#
      .SYNOPSIS
       update open update comic records, either all open or all open of given title

      .PARAMETER title

      .EXAMPLE
      C:\PS>  uo chew
   #>
   param(
	   [string]$title=$NULL,
       [switch]$sort)

   if ($title)
   {
      $query="where status='open' and title='$title'"
   }
   else
   {
      $query="where status='open'"
   }

   if ($sort)
   {
      $query+=" order by title"
   }

   $results=Search-DB $query
   $count=1

   If (!$results)
   {
      return "None found."
   }
   else
   {
      if ($results -is [system.array])
      {
         $count=$results.count
      }
   }

   $index=1
   foreach($record in $results)
   {
      Write-Host "Record $index of $count"
      Update-Record $record
    
      $index ++
   }
}

function Clean-String
{
   param([string]$dirty)

   [string]$clean=$dirty.Replace("�", "")
   $clean.substring(0, [System.Math]::Min(250, $clean.Length))
}

function Get-EBidResults
{
   param([string]$url)

   write-verbose "Getting $url"
   invoke-restmethod -uri "$url"
}

function Add-EBidArray
{
   param(
   [psobject]$results,
   [string]$title)

   foreach ($record in $results)
   {
       if ((Get-db $record.id) -eq 0)
       {
          if ($record.title -ne $null)
          {
             add-ebid $record $title
          }
       }
       else
       {
          write-host "`t`rSkipping $($record.id)" -nonewline -foregroundcolor yellow
       }
   }

	Write-Host ""
}

function add-ebid
{
   param(
   $ebiditem,
   [string]$comic,
   [int]$issue,
   [string]$seller=$null
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

   if ($ebiditem.description[0]."#cdata-section")
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

   write-host "Adding $title $($ebiditem.id)"
}

function Get-issues
{
 <#
      .SYNOPSIS
    Retrieves sold issue records for a title.

      .PARAMETER title
    Specifies the comic.

    .EXAMPLE
    C:\PS> Get-issues -title "The Walking Dead"

 #>
   param(
   [Parameter(Mandatory=$true)]
   [string]$title)

   $result=Search-DB "where title='$title'  and status = 'closed'"
   $issuesfound=@()
   $count=0

   $issuesfound=$result| select-object -property Issue -unique|sort-object issue
   if ($issuesfound -is [system.array])
   {
      $count=$issuesfound.count
   }
   else
   {
      if ($issuesfound)
      {
         $count=1
      }
   }

   write-host "$count unique titles of $title"
   $issuesfound
}

function Get-allprices
{
   <#
      .SYNOPSIS
    Retrieves sold issue records for a title.

      .PARAMETER title
    Specifies the comic.

    .EXAMPLE
    C:\PS> Get-issues -title "The Walking Dead"
   #>

   param(
   [Parameter(Mandatory=$true)]
   [string]$title)

   $issues=Get-issues -title $title

   $prices=@()

   foreach($issue in $Issues)
   {
      $localprice=Get-priceestimate -title $title -Issue $($issue.Issue)
      $prices=$prices+$localprice
   }

   $prices
}

function datestring
{
   $date=(Get-date).Date
   "$($date.day)-$($date.month)-$($date.year)"
}

function closing-record
{
   Param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$Issue)

   Update-Recordset -title $title -Issue $Issue -sortby DateOfSale
}

function reduce
{
   param(
   $array,
   $size)

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

function Get-ebidrecords
{
   <#
      .SYNOPSIS
       Rereiving and adding new records from ebid site

      .EXAMPLE
      C:\PS> Get-ebidrecords -title "THE WALKING DEAD"
      This lists all the open records marked watch
   #>

   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$search)

   $title=$search.title.replace(" ","%20")
   [string]$stringexclude=$null
   [string]$stringinclude=$null

   if ($search.exclude)
   {
      $stringexclude ="%20-"
      $stringexclude +=$search.exclude -join "%20-"
   }

   if ($search.include)
   {
      $stringinclude ="%20-"
      $stringinclude =$search.include -join "%20-"
   }

   write-verbose "Exclude: $stringexclude"
   write-verbose "Include: $stringinclude"

   foreach($category in $search.category)
   {
      write-verbose "$(Get-date) - category :$category"
      $url = "http://uk.ebid.net/perl/rss.cgi?type1=a&type2=a&words=$title$stringinclude$stringexclude&category2=$category&categoryid=$category&categoryonly=on&mo=search&type=keyword"

      write-verbose "Querying Ebid $url"
      $ebidresults=Get-ebidresults -url "$url"

	  [int]$OpenCount=0

      if ($ebidresults -is [system.array])
      {
         $OpenCount=$ebidresults.count
      }
      else
      {
         if ($ebidresults)
		 {
	        $OpenCount=1
	     }
      }

      add-ebidarray -results $ebidresults -title $search.title
   }

   Write-Host "`nEBid Stats" -foregroundcolor yellow
   Write-Host "Open:    $OpenCount" -foregroundcolor cyan
}

function Get-allrecords
{
   <#
      .SYNOPSIS
       Retrieves records from ebay and ebid

      .EXAMPLE
      C:\PS> Get-allrecords -title "THE WALKING DEAD" -exclude "Magazine"

   #>

   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$search
   )

   Write-Host "`nFinding: $($search.title)" -ForegroundColor cyan
   Get-ebidrecords -search $search
   Get-records     -search $search
   write-verbose "`r`nComplete."
}

function Open-Covers
{
  <#
      .SYNOPSIS
       Opens location where a comics cover images are stored

      .EXAMPLE
      C:\PS> open-covers -title "The Walking Dead" -issue 1

   #>
   param(
   [string]$title=$null,
   [string]$issue)

   $padtitle=$title -replace(" ","-")
   $path= "f:\comics\covers\$padtitle\$issue"
   Write-host "Opening $path"
   & explorer "`"$path`""
}

new-alias gb Get-bestbuy -force
new-alias fr Finalize-Records -force
new-alias ur Update-Recordset -force
new-alias np c:\windows\notepad.exe -force
new-alias cr closing-record -force
new-alias ep Get-priceestimate -force
new-alias ap Get-allprices -force
new-alias uo update-open -force
new-alias bs Get-selleritems -force
new-alias byseller Get-selleritems -force
new-alias oc open-covers -force
new-alias vm view-market -force
new-alias dr Remove-Record -force
