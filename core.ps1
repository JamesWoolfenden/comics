function scan
{
   <#
      .SYNOPSIS 
       Reviews all selected comics and updates db with new and updated items
	    
      .EXAMPLE
      C:\PS> scan
      This loads the search json db and scan ebay and ebid.
   #>

   $searches=(Get-Content "$root\search-data.json") -join "`n" | ConvertFrom-Json

   foreach($search in $searches)
   {
     if (($($search.comictitle) -eq "") -or ( $($search.comictitle) -eq $null)) 
     {
        $search.comictitle="$($search.title)"
     }

     Write-Host "`nFinding $($search.title)" -ForegroundColor cyan
     Write-debug "get-allrecords -title $($search.title) -include $($search.include)  -exclude $($search.exclude) -comictitle $($search.comictitle)"
     get-allrecords -title "$($search.title)" -include "$($search.include)"  -exclude "$($search.exclude)" -comictitle "$($search.comictitle)"
     write-host ""
     Write-debug "Complete."
   }
}

function best-buys
{
   <#
      .SYNOPSIS 
       Given a results object, this function add average and current price plus the margin available and returns the new array.
	    
      .EXAMPLE
      C:\PS> best-buys $resultarray

   #>

   param([pscustomobject]$results)
   
   foreach($record in $results)
   {
      $prices=estimate-price -title $record.title -issue $record.issue
      $record | Add-Member -type NoteProperty -name AveragePrice -value $prices.AveragePrice
      $record | Add-Member -type NoteProperty -name Margin -Value ($prices.CurrentPrice-$record.price)
      $record | Add-Member -type NoteProperty -name CurrentPrice -value $prices.CurrentPrice
   }
   $results
}

function get-bestbuy
{
    param([string]$title)

    $results=query-db -wherestring "where title='$title' and status='Verified'"
    best-buys $results| sort-Object -property Margin
}

function clean-records
{
   $records=query-db -wherestring "where status='verified' and Ebayitem is not null  order by CloseDate desc"
   
   Write-host "Found $($records.count)"
   
   foreach($record in $records)
   {
      update-record $record
   }  
}

function combine-data
{
<#
      .SYNOPSIS 
       combine market feed results
	    
      .EXAMPLE
      C:\PS> combine-date $title

   #>
   param([string]$title)

   $filetitle=$title.replace(" ","")
   $files=gci "$root\livedata" -Filter "$filetitle*"
   
   $data=@()
   foreach($file in $files)
   {
      $data+=(Get-Content "$($file.FullName)") -join "`n" | ConvertFrom-Json
   }

   $data|sort-object issue
}


function get-price
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$price)

   [string]$currency=""

   if ($price.contains("£"))
   {
      $price=$price.Replace("£","")
      $currency="£"
   }

   if ($price.contains('$'))
   {
      $price=$price.Replace('$',"")
      $currency='$'
   }

   if ($price.contains("€"))
   {
      $price=$price.Replace("€","")
      $currency="€"
   }

   $price=$price.split("")
   if ($price -is [system.array] )
   {
      $price=$price[1]
   }

   [decimal]$price=$price

   $cost= New-Object System.Object
   $cost| Add-Member -type NoteProperty -name Amount -value $price
   $cost| Add-Member -type NoteProperty -name Currency -value $currency
   $cost
}

function get-issue()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$rawissue)

   if ($rawissue.Contains("#"))
   {
      $rawissue=$rawissue.split("#")[1]
   }
   
   if ($rawissue.Contains("("))
   {
      $rawissue=$rawissue.split("(?=()")
      $cover=$rawissue[0]
      $variant=$rawissue[1]
   }
   Else
   {
      $cover=$rawissue -replace("\D","")
      $variant=$rawissue
   }

   $issue= New-Object System.Object
   $issue| Add-Member -type NoteProperty -name cover -value $cover
   $issue| Add-Member -type NoteProperty -name variant -value $variant
   
   $issue
}