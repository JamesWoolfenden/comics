$imageroot= "$PSScriptRoot\covers"

import-module "$PSScriptRoot\rss\EbayRssPowershellModule.psm1" -force
import-module "$PSScriptRoot\database.ps1"
import-module "$PSScriptRoot\split-set.ps1"
import-module "$PSScriptRoot\show-image.ps1"
import-module "$PSScriptRoot\form.ps1"
import-module "$PSScriptRoot\info.ps1"
import-module "$PSScriptRoot\core.ps1"
import-module "$PSScriptRoot\search-data.ps1"
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
      query-db "$querystring" 
   }
   else
   {
      query-db "$querystring"|ogv 
   }
}

function add-array
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
   #$test=read-db
   
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
             else{
                $CurrentPrice=0
             }

             add-record -title $title -issue $issue -price $CurrentPrice -bought $false -PublishDate $set.PublishDate -Ebayitem $set.Ebayitem `
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

function verify
{
   param(
   [string]$title,
   [string]$Issue)
   
   query-db "where title='$title' and issue='$issue' and status='open'"
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
   #$browser
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

function Finalize-Records
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

function update-open
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
      if ($results -is [system.array])
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

function clean-string
{
   param([string]$dirty)
   
   [string]$clean=$dirty.Replace("Â", "")
   $clean.substring(0, [System.Math]::Min(250, $clean.Length))
}

function get-ebidresults
{
   param([string]$url)
   
   Write-debug "Getting $url"
   $Results = invoke-restmethod -uri "$url"
   $Results 
}

function add-ebidarray
{
   param(
   [psobject]$results,
   [string]$title)
       
   foreach ($record in $results)
   {       
       if ((get-db $record.id) -eq 0)
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

function get-records
{
 <#
   .SYNOPSIS 
   Retrieves ebay records and adds them to the db
	    
   .EXAMPLE
   C:\PS> get-records -title "The Walking Dead" -exclude "Poster"   
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
   write-debug "Soldresult=Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'sold'|where {`$_.BidCount -ne '0'}"
   $soldresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'sold' -categories $search.category |where {$_.BidCount -ne '0'}

   if ($soldresult)
   {
     $sold=1
     if ($soldresult -is [system.array])
     {
        $sold=$soldresult.count
     }
     
     write-host "`n`tFound Sold $($sold)" -foregroundcolor cyan
     add-array $soldresult -title $writetitle -issue 0 -Status Closed
   }
   
   # this is the closed results
   write-debug "Get-EbayRssItems -Keywords $keywords -ExcludeWords $exclude -state 'closed'|where {`$_.BidCount -ne '0'}"
   $expiredresult=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'closed' -categories $search.category|where {$_.BidCount -eq "0"}
   if ($expiredresult)
   {
      write-host "`r`nExpired" -foregroundcolor cyan
      add-array $expiredresult -title $writetitle -issue 0 -Status Expired
   }
   
   #these 
   if ($search.enabled)
   {
      $result=Get-EbayRssItems -Keywords "$keywords" -ExcludeWords "$exclude" -state 'Open' -categories $search.category
      $found=0
      if ($result)
      {
         write-debug "`r`nOpen" 
	     if ($result -is [system.array])
	     {
	       $found=$($result.count)
	     }
	     else
         {
            $found=1
         }

         write-host "`n`tebay Found $($found)" -foregroundcolor cyan
         add-array $result -title $writetitle -issue 0
      }
      else
      {
         write-host "`n`tEbay found: 0"
      }
   }
   else
   {
      write-warning "Disabled new records for $title"
   }
}

function get-issues
{
 <#
      .SYNOPSIS 
    Retrieves sold issue records for a title.
	       
      .PARAMETER title
	Specifies the comic.
	    
    .EXAMPLE
    C:\PS> get-issues -title "The Walking Dead" 
          
 #>
   param(
   [Parameter(Mandatory=$true)]
   [string]$title)
   
   $result=query-db "where title='$title'  and status = 'closed'"
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

function get-allprices
{
   <#
      .SYNOPSIS 
    Retrieves sold issue records for a title.
	       
      .PARAMETER title
	Specifies the comic.
	    
    .EXAMPLE
    C:\PS> get-issues -title "The Walking Dead"        
   #>

   param(
   [Parameter(Mandatory=$true)]
   [string]$title)
      
   $issues=get-issues -title $title

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
   [Parameter(Mandatory=$true)]
   [string]$Issue)
   
   update-recordset -title $title -Issue $Issue -sortby DateOfSale
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

function get-ebidrecords
{
   <#
      .SYNOPSIS 
       Rereiving and adding new records from ebid site
	    
      .EXAMPLE
      C:\PS> get-ebidrecords -title "THE WALKING DEAD"
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
   
   Write-debug "Exclude: $stringexclude"
   Write-debug "Include: $stringinclude"

   foreach($category in $search.category)
   {
      Write-debug "$(Get-date) - category :$category"
      $url = "http://uk.ebid.net/perl/rss.cgi?type1=a&type2=a&words=$title$stringinclude$stringexclude&category2=$category&categoryid=$category&categoryonly=on&mo=search&type=keyword"

      write-debug "Querying ebid $url"
      $ebidresults=get-ebidresults -url "$url"

      if ($ebidresults -is [system.array])
      {
         write-host "`tEbid found: $($ebidresults.count)" -foregroundcolor green
      }
      else
      {
         write-host "`tEbid found: 0"
      }

      add-ebidarray -results $ebidresults -title $search.title
   }
}

function get-allrecords
{
   <#
      .SYNOPSIS 
       Retrieves records from ebay and ebid
	    
      .EXAMPLE
      C:\PS> get-allrecords -title "THE WALKING DEAD" -exclude "Magazine"
      
   #>

   param(
   [Parameter(Mandatory=$true)]
   [PSCustomObject]$search
   )
   
   Write-Host "`nFinding $($search.title)" -ForegroundColor cyan  
   get-ebidrecords -search $search
   get-records -search $search
   Write-debug "`r`nComplete."
}

function open-covers
{
   param(
   [string]$title=$null,
   [string]$issue)
  
   $padtitle=$title -replace(" ","-")
   $path= "c:\comics\covers\$padtitle\$issue"
   Write-host "Opening $path"
   & explorer "`"$path`""  
}

new-alias gb get-bestbuy -force
new-alias fr Finalize-Records -force
new-alias ur update-recordset -force
new-alias np c:\windows\notepad.exe
new-alias cr closing-record -force  
new-alias ep estimate-price -force
new-alias ap get-allprices -force
new-alias uo update-open -force
new-alias bs get-selleritems -force
new-alias byseller get-selleritems -force
new-alias oc open-covers -force
new-alias vm view-market -force
