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
   write-verbose "Soldresult=Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'sold'|where {`$_.BidCount -ne '0'}"
   $soldresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'sold' -categories $search.category

   [int]$SoldCount=0
   if ($soldresult)
   {
     $SoldCount=1
     if ($soldresult -is [system.array])
     {
        $SoldCount=$soldresult.count
     }

     Write-host "Soldcount is $Soldcount"
	 #filter out any records that are already in closed or exipred state

     add-array $soldresult -title $writetitle -issue 0 -Status Closed
   }

   # this is the closed results
   write-verbose "Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'closed'|where {`$_.BidCount -ne '0'}"
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
      Write-host "Expired is $ExpiredCount"
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

         Write-host "Open is $OpenCount"
         add-array $result -title $writetitle -issue 0 -status Open
      }
   }
   else
   {
      write-warning "Disabled new records for $title"
   }

   write-host "`nEbay Stats" -foregroundcolor yellow
   write-host "Expired: $ExpiredCount" -foregroundcolor cyan
   write-host "Sold:    $SoldCount" -foregroundcolor cyan
   Write-Host "Open:    $OpenCount" -foregroundcolor cyan
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
   write-host "ScrapeBlock $url span#prcIsum.notranslate .sh-fr-cst mbg-nw"
   ScrapeBlock $url  "span#prcIsum.notranslate" ".sh-fr-cst" "span.mbg-nw"
}

function Update-RecordNew
{
  param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   switch($record.site.ToUpper())
   {
      'EBAY'
	    {
         $salestatus=Get-EbaySaleStatus -record $record
         $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"
         write-host "Opening $url"
         $BrowserProcess = [Diagnostics.Process]::Start("chrome.exe", "--window-size=800,600 --window-position=50,50 --app=$url")
         #$DirtyBlock=Get-EbayRecordBlock -record $record

         Write-Host "SaleStatus : $salestatus"

         switch ($salestatus.ToUpper())
         {
           'EXPIRED'
           {
             Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
           }
           'SOLD'
           {
             $soldPrice=Get-EbaySoldPrice -record $record
             Write-Host "Sold Price: $soldPrice"
             Update-DB -ebayitem $record.ebayitem -price $soldPrice -Status "SOLD"
           }
           'LIVE'
           {

           }
           'DELISTED'
           {
             Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
           }
         }

         Stop-Process -Name $BrowserProcess.ProcessName -ErrorAction Ignore

     }
  }
}
