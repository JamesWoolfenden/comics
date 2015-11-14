function Scan
{
   <#
      .SYNOPSIS 
       Reviews all selected comics and updates db with new and updated items
        
      .EXAMPLE
      C:\PS> scan
      This loads the search json db and scan ebay and ebid.
   #>

   param(
	   [string]$title)

   $searches=(Get-Content "$PSScriptRoot\search-data.json") -join "`n" |ConvertFrom-Json

   #restrict to just this title
   if ($title)
   {
      $searches=$searches|where{$_.title -eq $title}
   }

   foreach($search in $searches)
   {
     if (($($search.comictitle) -eq "") -or ( $($search.comictitle) -eq $null)) 
     {
        $search.comictitle="$($search.title)"
     }

     if ($search.Enabled)
     { 
        get-allrecords -search $search
     }
     Else
     {
        Write-host "`r`nSearch disabled for $($search.title)" -foregroundcolor cyan
     }
     
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
      write-verbose "get-priceestimate -title $($record.title) -issue $($record.issue)"
      $prices=get-priceestimate -title $($record.title) -issue $($record.issue)

      $CurrentPrice=0
      $AveragePrice=0
      $Margin=0

      if ($prices)
      {
         $CurrentPrice=$($prices.CurrentPrice)
         $AveragePrice=$($prices.AveragePrice)
         $Margin=$($prices.CurrentPrice)-$($record.price)
      }

      $record | Add-Member -type NoteProperty -name CurrentPrice -value $CurrentPrice
      $record | Add-Member -type NoteProperty -name AveragePrice -value $AveragePrice
      $record | Add-Member -type NoteProperty -name Margin -Value $Margin
   }

   $results
}

function get-bestbuy
{
    <#
      .SYNOPSIS 
       Gets and sorts an array of a certain table by margin
        
      .EXAMPLE
      C:\PS> get-bestbuy -title "THE WALKING DEAD"

   #>
    param([string]$title,
    [switch]$nogrid)

    $results=search-db -wherestring "where title='$title' and status='Verified'"
    if ($nogrid)
    {
       best-buys $results| sort-Object -property Margin -Descending
    }
    else
    {
       best-buys $results| sort-Object -property Margin -Descending |ogv
    }
}

function clean-records
{
    <#
      .SYNOPSIS 
       Gets all verified records in close order, the sets up review
        
      .EXAMPLE
      C:\PS> clean-records

   #>
   
   $records=search-db -wherestring "where status='verified' and Ebayitem is not null  order by CloseDate desc"
   if ($records -is [System.Array])
   {
      Write-host "Found $($records.count)"
   }

   foreach($record in $records)
   {
      Update-Record $record
   }  
}

function combine-data
{
<#
      .SYNOPSIS 
       combine market feed results
        
      .EXAMPLE
      C:\PS> combine-data $title

   #>
   param([string]$title)

   $filetitle=$title.replace(" ","")
   $files=gci "$PSScriptRoot\livedata" -Filter "$filetitle*"
   
   $data=@()
   foreach($file in $files)
   {
      $data+=(Get-Content "$($file.FullName)") -join "`n" | ConvertFrom-Json
   }

   $data|sort-object issue
}

function get-price
{
  <#
      .SYNOPSIS 
       For return numeric price from a dirty string
        
      .EXAMPLE
      C:\PS> get-price "$3.59"

   #>

   param( 
   [Parameter(Mandatory=$true)]
   [string]$price)

   if ($price -eq "")
   {
     return ""
   }
    
   [string]$currency=$null

   if ($price.contains("£"))
   {
      $price=$price.Replace("£","")
      $currency="&pound;"
   }

   if ($price.contains("`$"))
   {
      $price=$price.Replace("`$","")
      $currency='$'
   }

   if ($price.contains("€"))
   {
      $price=$price.Replace("€","")
      $currency='Euro'
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

function get-issue
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$rawissue)
   
   [string]$variant=""

   if ($rawissue.Contains("#"))
   {
      write-verbose "splitting on # $rawissue"
      $rawissue=$rawissue.split("#")[1]
   }
   elseif(($rawissue.ToUpper()).Contains("PROG"))
   {
      write-verbose "splitting on prog $rawissue"
      $rawissue=($rawissue.ToUpper() -split("PROG"))[1]
   }
   
   $split=$rawissue.split(" ")
   $cover=$split[0]
   $variant=$rawissue
   write-verbose "Variant is $variant"

   if ($variant -eq $null)
   {
      write-Error "Variant is undefined"
   }
   else
   {
      write-verbose "Variant is $variant"
   }

   $issue= New-Object System.Object
   $issue| Add-Member -type NoteProperty -name cover -value $cover
   $issue| Add-Member -type NoteProperty -name variant -value $variant
   
   $issue
}

function read-hostdecimal
{
    <#
      .SYNOPSIS 
       Same as read host but only accepts decimal entries
        
      .EXAMPLE
      C:\PS> read-hostdecimal
   #>

   do 
   {
      try 
      {
        $numOk = $true
        [Decimal]$Entry = Read-host 
      } # end try
      catch 
      {
         write-Host "Decimal entry required" -ForegroundColor  Yellow
         $numOK = $false
      }
    } # end do 
    until ($numOK)
 
   $Entry
 }

function update-set
{
    <#
      .SYNOPSIS 
       Allows the individual update of a resultset 
        
      .EXAMPLE
      C:\PS> update-set $(get-selleritems -seller blackadam -nogrid)

   #>

   param(   
   [Parameter(Mandatory=$true)]
   [psobject]$results)

   foreach($record in $results)
   {
      Update-Record $record 
   }
}

function get-numeric
{
   param([string]$string)
   $found=$string -match '(\d+)'
   if ($found)
   {
      $result=$matches[1]
      return $result	
   }
   
   $null
}