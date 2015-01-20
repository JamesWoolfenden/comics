
import-module "$PSScriptRoot\core.ps1" -force

function get-auctiondata
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title)
   
   $results=query-db -wherestring "where title='$title' and status='verified'"

   $counter=0
   $auction=@()
   
   While($counter -ne $results.count)
   {
      $record= New-Object System.Object
      
      $url="<a href=`"$($results[$counter].link)`">$($results[$counter].link)</a>"
      $record| Add-Member -type NoteProperty -name link -value $results[$counter].link
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $NULL
      $record| Add-Member -type NoteProperty -name title    -value $results[$counter].title

	  $cover=get-cover $results[$counter].issue

      $record| Add-Member -type NoteProperty -name issue    -value "$cover"
      $record| Add-Member -type NoteProperty -name variant  -value $results[$counter].issue
      $record| Add-Member -type NoteProperty -name price    -value $results[$counter].price
      $record| Add-Member -type NoteProperty -name currency -value "pounds"
      $record| Add-Member -type NoteProperty -name rundate  -value $(datestring)
      $record| Add-Member -type NoteProperty -name site     -value "Auction"
      #$record| Add-Member -type NoteProperty -name postage  -value $results[$counter].postage

      $auction+=$record
	  $counter++
   }
  
   write-host "Record $counter"
   $auction
}