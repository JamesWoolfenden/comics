
import-module "$PSScriptRoot\core.ps1" -force

function get-auctiondata
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record)
   
   $results=query-db -wherestring "where title='$($record.title)' and status='verified'"
   write-Host "$(Get-Date) - Looking for $($record.title) @ Auctions"

   $counter=0
   $auction=@()
   
   foreach($result in $results)
   {
      $record= New-Object System.Object
      
      $url="<a href=`"$($result.link)`">$($result.link)</a>"
      $record| Add-Member -type NoteProperty -name link -value $result.link
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title    -value $result.title

	  $cover=get-cover $results[$counter].issue

      $record| Add-Member -type NoteProperty -name issue    -value $cover
      $record| Add-Member -type NoteProperty -name variant  -value $result.issue
      $record| Add-Member -type NoteProperty -name price    -value $result.price
      $record| Add-Member -type NoteProperty -name currency -value '£'
      $record| Add-Member -type NoteProperty -name rundate  -value $(datestring)
      $record| Add-Member -type NoteProperty -name site     -value "Auction"
      #$record| Add-Member -type NoteProperty -name postage  -value $result.postage

      $auction+=$record
	  $counter++
   }
  
   write-host "Record $counter"
   $auction
}