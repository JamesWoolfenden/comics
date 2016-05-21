
import-module "$PSScriptRoot\..\core.ps1" -force

function Get-AuctionData
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record)
   
   $results=Search-DB -wherestring "where title='$($record.title)' and status='verified'"
   Write-Host "$(Get-Date) - Looking for $($record.title) @ Auctions"

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

      $cover=Get-cover $results[$counter].issue
      $price=($result.price) -as [decimal]

      $record| Add-Member -type NoteProperty -name issue    -value $cover
      $record| Add-Member -type NoteProperty -name variant  -value $result.issue
      $record| Add-Member -type NoteProperty -name price    -value $price
      $record| Add-Member -type NoteProperty -name currency -value "&pound;"
      $record| Add-Member -type NoteProperty -name rundate  -value $(datestring)
      $record| Add-Member -type NoteProperty -name site     -value "Auction"
      #$record| Add-Member -type NoteProperty -name postage  -value $result.postage

      $auction+=$record
      $counter++
   }
  
   Write-Host "$(Get-Date) - Found $counter"
   $auction
}