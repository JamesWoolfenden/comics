function Get-Records
{
 <#
   .SYNOPSIS
   Retrieves ebay records and adds them to the db

   .EXAMPLE
   C:\PS> Get-records -title "The Walking Dead" -exclude "Poster"
    This loads the search json db and scan ebay and ebid.
 #>

   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$search)

   $include=$search.include -join ' '
   $exclude=$search.exclude -join ' '

   if ($search.comictitle)
   {
      $writetitle=$search.comictitle
   }
   else
   {
      $writetitle=$search.title
   }

   if ($search.include)
   {
      $keywords="$($search.title) $include"
   }
   else
   {
      $keywords=$search.title
   }

   #this is the sold items
   Write-Verbose "Soldresult=Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'sold'|where {`$_.BidCount -ne '0'}"
   $soldresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'sold' -categories $search.category

   [int]$SoldCount=0
   if ($soldresult)
   {
     $SoldCount=1
     if ($soldresult -is [system.array])
     {
        $SoldCount=$soldresult.count
     }

     Write-Host "Soldcount is $Soldcount"
	 #filter out any records that are already in closed or exipred state

     add-array $soldresult -title $writetitle -issue 0 -Status Closed
   }

   # this is the closed results
   Write-Verbose "Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'closed'|where {`$_.BidCount -ne '0'}"
   $expiredresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'closed' -categories $search.category|where {$_.BidCount -eq "0"}

   [int]$ExpiredCount = 0
   if ($expiredresult)
   {
      $ExpiredCount=1
      if ($expiredresult -is [System.Array])
      {
         $ExpiredCount=$expiredresult.count
      }

      #should only update
      Write-Host "Expired is $ExpiredCount"
	    add-array $expiredresult -title $writetitle -issue 0 -Status Expired
   }

   [int]$OpenCount=0
   if ($search.enabled)
   {
      $result=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'Open' -categories $search.category

      if ($result)
      {
	     $OpenCount=1
         if ($result -is [system.array])
         {
           $OpenCount=$result.count
         }

         Write-Host "Open is $OpenCount"
         add-array $result -title $writetitle -issue 0 -status Open
      }
   }
   else
   {
      Write-Warning "Disabled new records for $title"
   }

   Write-Host "`nEbay Stats" -foregroundcolor yellow
   Write-Host "Expired: $ExpiredCount" -foregroundcolor cyan
   Write-Host "Sold:    $SoldCount" -foregroundcolor cyan
   Write-Host "Open:    $OpenCount" -foregroundcolor cyan
}

function Get-SoldPrice
{
  param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record,
   [Parameter(Mandatory=$true)]
   [string]$site,
   [string]$salestatus)

   if ($site -eq "EBAY")
   {
     Get-EbaySoldPrice -record $record
   }
   else
   {
     Get-EbidSoldPrice -url $record.link -Status $salestatus -OldPrice $record.Price
   }
}

function Get-SaleStatus
{
  param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record,
   [Parameter(Mandatory=$true)]
   [string]$site)


   if ($site -eq "EBAY")
   {
     Get-EbaySaleStatus -record $record
   }
   else
   {
     Get-EbidSaleStatus -url $record.link
   }
}

function ScrapeBlock
{
  param(
    [string]$url,
    [string]$PriceID,
    [string]$PostageID,
    [string]$SellerID)

    #& node.exe $PSScriptRoot\scrapeBlock.js $url $target
    & node.exe .\scrapeBlock.js $url $PriceID $PostageID $SellerID
}

function Get-EbayRecordBlock
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$ebayitem)

   $url="http://www.ebay.co.uk/itm/$($ebayitem)?"

   #scrape $url "div#CenterPanelInternal"
   Write-Verbose "ScrapeBlock $url span#prcIsum.notranslate .sh-fr-cst mbg-nw  span.mbg-nw"
   ScrapeBlock $url  "span#prcIsum.notranslate" ".sh-fr-cst" "span.mbg-nw"
}

function Update-RecordNew
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   $site=$record.site.ToUpper()
   $salestatus=Get-SaleStatus -record $record -site $site

   Write-Host "SaleStatus : $salestatus"
   Write-Host "Site       : $Site"

   switch ($salestatus.ToUpper())
   {
     {($_ -match 'EXPIRED') -or ($_ -match 'DELISTED')}
     {
        Write-Verbose "Setting to Expired"
        Write-Verbose  "Update-DB -ebayitem $($record.ebayitem) -Status `"EXPIRED`""
        if (!($record.Status -eq 'CLOSED'))
        {
           Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
        }
        Else{ Write-Host "Already Closed"}
     }
     'CLOSED'
     {
        $soldPrice=Get-SoldPrice -record $record -site $site -SaleStatus $SaleStatus
        Write-Host "Sold Price: $soldPrice  Issue: $($record.Issue)"
        Update-DB -ebayitem $record.ebayitem -Issue $record.Issue -Price $soldPrice -Status "CLOSED"
     }
     'VERIFIED'
     {
        Write-Verbose "Do Nothing"
     }
     default
     {
        Throw "SALE STATUS FAILED"
     }
   }
}
