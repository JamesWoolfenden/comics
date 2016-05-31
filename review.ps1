function Get-RecordView
{
   param
	 (
	   [Parameter(Mandatory=$true)]
	   [PSObject]$record)

     if ($record.ebayitem)
     {
        switch ($record.site.ToUpper())
        {
         "EBAY"
         {
            $ie=View $record.ebayitem
         }
         "EBID"
         {
            $ie=Get-URLView -URL $record.link
         }
         default
         {
            $ie=View $record.ebayitem
         }
      }
   }
   else
   {
      Write-Warning "$($record.ebayitem) is null or empty"
   }

   $ie
}

function Set-Quantity
{
  param([psobject]$record,
        [string]$Issue)

   $quantity=1

   if ($Issue -eq "SET" -And $($record.Quantity) -eq 1)
   {
      $readquantity=Read-Host "Number in set:$($record.Quantity)"
      if  ($readquantity -gt 0)
      {
         $quantity = $readquantity
      }
   }

   $quantity
}

function Set-ComicStatus
{
   param(
     [PSObject]$record,
     [string]$salestatus=$NULL)

   Write-host "$salestatus"
   if ($salestatus)
   {
     switch($salestatus)
     {
       {($_ -match 'LIVE') -or ($_ -match 'VERIFIED')}
       {
         $record.Status="VERIFIED"
       }
       'SOLD'
       {
         $record.Status="CLOSED"
       }
     }
   }
   else{
      [string]$newstatus=read-host $record.Status "(V)erified, (C)losed, (E)xpired, (B)ought, (W)atch"

      switch($newstatus)
      {
      "C"
      {
         $record.Status="CLOSED"
      }
      "V"
      {
         $record.Status="VERIFIED"
      }
      "E"
      {
         $record.Status="EXPIRED"
      }
      "B"
      {
         $record.Status="CLOSED"
         $record.bought="true"
      }
      "W"
      {
         $record.Status="VERIFIED"
         $record.watch=0
      }
      default
      {
         if ($record.status -eq "Open")
         {
            $record.Status="VERIFIED"
         }
      }
   }
   }

   $record
}

function Set-Title
{
   param(
     [Parameter(Mandatory=$true)]
     [string]$rawtitle)

   Write-Verbose "Set-title"
   $newtitle=($rawtitle.ToUpper()).Split("#")
   $padtitle=$newtitle.replace(" ","-")

   if (Test-Path "$PSScriptRoot\covers\$padtitle")
   {
      Write-Verbose "Title at $PSScriptRoot\covers\$padtitle"
      Write-Host "Title $($newtitle[0]):" -NoNewline -ForegroundColor green
   }
   else
   {
      Write-Host "New Title? $($newtitle[0]):" -NoNewline -ForegroundColor Yellow
   }

   $title=[string](Read-Host)

   If (($title -eq $null) -or ($title -eq ""))
   {
      $returntitle=$($newtitle[0]).trim()
   }
   else
   {
      $returntitle=$title
   }

   $padtitle=$returntitle -replace(" ","-")
   if (!(test-Path $PSScriptRoot\covers\$padtitle))
   {
      Write-Host "New title: $returntitle" -ForegroundColor cyan
   }

   $returntitle.ToUpper()
}

function Set-Issue
{
   param(
        [Parameter(Mandatory=$true)]
        [string]$rawissue,
        [Parameter(Mandatory=$true)]
        [string]$rawtitle,
        [Parameter(Mandatory=$true)]
        [string]$title,
        [Parameter(Mandatory=$true)]
        [string]$color)

   Write-Verbose "$rawissue $rawtitle $color"

   [string]$tempstring=$null
   [string]$variant=$null

   #if its a new record
   if ($rawissue -eq "0")
   {
      $lowertitle=$rawtitle.ToLower()
      #might have string saying issue variant
      if (($rawtitle.Contains("1st")) -or ($lowertitle.Contains("first print")))
      {
        $variant="A"
        $rawtitle=$rawtitle -replace "1st"
      }

      #might have string saying issue variant
      if (($rawtitle.Contains("2nd")) -or ($lowertitle.Contains("second print")))
      {
        $variant="B"
        $rawtitle=$rawtitle -replace "2nd"
      }

      if (($rawtitle.Contains("3rd")) -or ($lowertitle.Contains("third print")))
      {
        $variant="C"
        $rawtitle=$rawtitle -replace "3rd"
      }

      #are we lucky to have an issue no?
      if ($rawtitle.Contains("#"))
      {
         $tempstring=$rawtitle.Split("#")[1]
      }
      elseif (($rawtitle.ToUpper()).Contains("PROG"))
      {
         $tempstring=($rawtitle.ToUpper() -split("PROG"))[1]
      }else{
         $tempstring=$rawtitle -replace '\D+'+$Variant
      }

      #has it split
      if ($tempstring -ne $null)
      {
          Write-Verbose "Before estimate tempstring $tempstring"
          $splitstring=($tempstring.Trim()).split(" ")

          if ($splitstring -is [system.array])
          {
             $splitstring= $splitstring[0]
          }

          if ($splitstring)
          {
             $estimateIssue=$splitstring
          }
          else
          {
             $estimateIssue=$null
          }

          Write-Verbose "Tempstring $tempstring $($tempstring.GetType())"
          Write-Verbose "GuessTitle -title $title -issue $estimateIssue"
          $estimateIssue=GuessTitle -title $title -issue $estimateIssue
          Write-Verbose "After estimate $estimateIssue"
      }
      else
      {
         $tempstring=@()
         Write-Verbose "No split # $($rawtitle -split('No'))"
         #maybe used no to indicate version

         if ($rawtitle -Contains("No"))
         {
            $tempstring=$rawtitle -split("No")
            Write-Verbose "Split on No $tempstring"

            $splitspaces=($tempstring[1].Trim()).split(" ")

            if ($splitspaces -is [system.array])
            {
               $estimateIssue =$splitspaces[0]
            }
            else
            {
               $estimateIssue=$tempstring
            }

            Write-Host "Before estimate estimateIssue $estimateIssue"
            $estimateIssue=GuessTitle -title $title -issue "$estimateIssue"
            Write-Verbose "After estimate $estimateIssue"
         }
         else
         {
            $edition=""
            Write-Verbose "No splits $rawissue"
            if ($rawtitle -match "1st")
            {
               $rawtitle =$rawtitle.Replace("1st","")
               $edition = "A"
            }

            #ok best chance did not work now edge cases
            $estimateIssue=($rawtitle -replace("\D",""))
            if ($estimateIssue)
            {
               $estimateIssue=GuessTitle -title $title -issue $estimateIssue
            }
            else
            {
               #no numbers
               $estimateIssue=$rawtitle
            }
         }
      }

      #while nothings been entered continue
      while (($estimateIssue -eq "0") -or ($estimateIssue -eq ""))
      {
         Write-Host "Estimate issue ($rawIssue):" -Foregroundcolor $color -nonewline
         $estimateIssue=read-host
      }
   }
   else
   {
      $estimateIssue=$rawIssue
   }

   #decide whether to add string
   if (!(Test-Image -title $title -issue $estimateIssue))
   {
     $estimateIssue+=$Variant
   }

   #Varianttypes
   $VariantKeys=("PHANTOM","FIRSTS","SDCC","GHOST","HASTINGS")
   foreach($key in $VariantKeys)
   {
       if ($rawtitle.ToUpper() -match $key)
       {
          $estimateIssue=($estimateIssue -replace '\D+')+$key
       }
   }


   #modifiers
   $keys=("CGC","SIGNED")
   foreach($key in $Keys)
   {
      if ($rawtitle.ToUpper() -match $key)
      {
         if ($estimateIssue -notmatch $key)
         {
            $estimateIssue+=$key
            Write-Host "Added $key to $estimateIssue"
         }
         else
         {
            Write-Host "Found $key in $estimateIssue"
         }
      }
   }

   Write-Host "Issue $($estimateIssue) - (i)dentify, (c)lose:" -Foregroundcolor $color -nonewline
   $actualIssue=(read-host).ToUpper()

   switch($actualIssue)
   {
      "I"
      {
          if (($estimateIssue -replace("\D","")) -eq "")
          {
             Write-Host "Estimate Cover Issue:" -Foregroundcolor $color -nonewline
             $cover=read-host
          }
          else
          {
             $cover=Get-Cover $estimateIssue
          }

          $actualIssue=Get-ImageTitle -issue $cover -title $newtitle
          Write-Host "Choose $actualIssue" -ForegroundColor cyan
      }
      "C"
      {
         Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
         return $False
      }
      default
      {
         if ($actualIssue -eq $NULL -or $actualIssue -eq "")
         {
            $actualIssue=$estimateIssue
         }
      }
   }

   if (!(Test-Image -title $newtitle -issue $actualIssue))
   {
      if ($($record.ImageSrc))
      {
         Write-Host "Updating Library with image of $newtitle : $actualIssue" -foregroundcolor cyan
         $filepath= Get-ImageFilename -title $newtitle -issue $actualIssue
         Write-Host "Downloading from $($record.Imagesrc) "
         Write-Host "Writing to $filepath"
         Set-ImageFolder $newtitle $actualIssue|Out-null

         try
         {
            Invoke-WebRequest $record.ImageSrc -outfile $filepath
         }
         catch
         {
            Write-Host "Cannot download  $($record.ImageSrc)"
         }
      }
      Else
      {
         Write-Host "No image data"
      }
   }
   Write-Verbose "Finished setting title"
   $actualIssue

 }

function GuessTitle
{
    param(
    [Parameter(Mandatory=$true)]
    [string]$title,
    [string]$issue=$null)

    $issue=$issue.replace(".","")
    $issue=$issue.replace(",","")

    if ($Issue)
    {
       $cover=Get-cover $issue
    }
    else
    {
      $cover="set"
    }

    $padtitle=$title -replace(" ","-")
    Write-Host "looking for $PSScriptRoot\covers\$padtitle\$cover\$issue.jpg"

    if (test-path "$PSScriptRoot\covers\$padtitle\$cover\$issue.jpg")
    {
       return $issue
    }
    else
    {
       if (test-path "$PSScriptRoot\covers\$padtitle\$cover\$($issue)A.jpg")
       {
          return "$($issue)A"
       }
       else
       {
          Write-Host "Guessing a set $issue"
          return "set"
       }
    }
 }

function Get-EbidSeller
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$url,
   [string]$oldseller)

   $seller=$oldseller

   $result=scrape -url $url -target h4.fs-14
   if ($result)
   {
      $seller=($result[1].trim()).split(" ")[0]
   }

   $seller
}

function Get-EbaySeller
{
    param(
      [Parameter(Mandatory=$true)]
      [PSObject]$record)
    $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"

    & node.exe $PSScriptRoot\scrape.js $url 'span.mbg-nw@html'
}

function Scrape
{
  param(
    [string]$url,
    [string]$target)

    & node.exe $PSScriptRoot\scrape.js $url $target
}

function Get-EbaySoldPrice
{
    param(
      [Parameter(Mandatory=$true)]
      [PSObject]$record)
    $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"

    $SoldPrice=scrape $url 'prcIsum_bidPrice'

    if (!($SoldPrice))
    {
      #Write-Host "Looking for 'span.notranslate'"
      $money=scrape $url 'span.notranslate'
      if ($money -is [system.array])
      {
        $SoldPrice=$money[1].trim()
      }
      else
      {
        $SoldPrice=$money
      }
    }

    if (!($SoldPrice))
    {
       #Write-Host "Looking for 'span#prcIsum.notranslate'"
       $money=scrape $url 'span#prcIsum.notranslate'
       $SoldPrice=$money[1].trim()
    }

    #Write-Host $SoldPrice
    (Get-Price $SoldPrice).Amount
}

function Get-EbaySaleStatus
{
    param(
      [Parameter(Mandatory=$true)]
      [PSObject]$record,
      [string]$salestatus="LIVE")

    $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"

    [string]$Status=(scrape $url 'span#w1-3-_msg')

    [string]$delisted=(scrape $url 'div.sml-cnt').trim()
    if (!($delisted)){
      $delisted=[string]$delisted=(scrape $url 'h1.pivHdr').trim()
    }

    if (!([BOOL]$delisted))
    {
      Write-Verbose "Not delisted, checking state: $Status"
      switch ($Status.trim())
      {
          "This Buy it now listing has ended."
          {
             Write-Verbose "This Buy it now listing has ended."
             $salestatus="EXPIRED"
          }
          {($_ -match "Bidding has ended on this item")}
          {
             Write-Verbose "Bidding has ended on this item."
             #returns no of bids as string
             $bids=scrape $url  "a#vi-VR-bid-lnk.vi-bidC"
             $salestatus="SOLD"

             if ($bids)
             {
                #check to see if no bids
                if (Test-NoBids -bids $bids)
                {
                   $salestatus="EXPIRED"
                }
             }
          }
          {($_ -match "This listing was ended") }
          {
             Write-Verbose     "This listing was ended by the seller because the item is no longer available."
             $result=scrape $url span.vi-qtyS.vi-bboxrev-dsplblk.vi-qty-vert-algn.vi-qty-pur-lnk

             if ($result)
             {
                $salestatus="SOLD"
             }
             else
             {
                $salestatus="EXPIRED"
             }
          }
          {($_ -match "This listing has ended") }
          {
             Write-Verbose "Caught by or logic"
             $result=scrape $url span.vi-qtyS.vi-bboxrev-dsplblk.vi-qty-vert-algn.vi-qty-pur-lnk
             if ($result)
             {
               $salestatus="SOLD"
             }
             else
             {
                $salestatus="EXPIRED"
             }
           }
          default
          {
            Write-Host "Default"
            $salestatus="LIVE"
          }
         }
    }
    else
    {
        $salestatus="EXPIRED"
    }
  $salestatus
}

function Get-EbidSaleStatus
{
    param(
      [Parameter(Mandatory=$true)]
      [string]$url)

    $status=scrape -url $record.link -target div.dis-inline-block.red
    $salestatus="VERIFIED"

    switch ($status.trim())
    {
        "Listing Closed"
        {
          $salestatus="CLOSED"
        }
    }

    $salestatus
}

function Get-EbayShippingCost
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"
   $estimate=0

   #fshippingCost > span
   $result=scrape $url span."notranslate.sh-cst"
   if ($result)
   {
      $bestestimate=($result)[1].trim()
      $estimate=(Get-Price $bestestimate).Amount
   }

   $estimate
}

function GetEbidPrice
{
  param(
    $link,
    $salestatus,
    $OldPrice)

   $price=$OldPrice

   if ($salestatus -ne "CLOSED")
   {
     $scrapePrice=scrape -url $link -target ins.bid
     if ($scrapePrice)
     {
       Write-Host "scrapePrice: $scrapePrice"
       $price=(Get-Price $scrapePrice).Amount
     }
   }

}

function Update-RecordOld
{
  param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record,
   [string]$newstatus)

   [PSObject]$OldRecord=$record

   #postage
   $estimate  =$null
   $seller    =$null
   $salestatus=$null

   $ie=Get-RecordView $record

   switch($record.site.ToUpper())
   {
      'EBAY'
	    {
         $salestatus=Get-EbaySaleStatus -record $record
         Write-Host ""

         Write-Host "SaleStatus : $salestatus"
         switch ($salestatus.ToUpper())
         {
           'EXPIRED'
           {
             Write-Verbose "Update-DB -ebayitem $($record.ebayitem) -Status EXPIRED"
             Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
             $IE[1].Application.Quit()
             return
           }
           'SOLD'
           {
             $price=Get-EbaySoldPrice -record $record
           }
           'LIVE'
           {
             $price=Get-EbaySoldPrice -record $record
           }
           'DELISTED'
           {

             $IE[1].Application.Quit()
             return
           }
         }

		     $estimate=Get-EbayShippingCost -record $record
         $seller  =Get-EbaySeller -record $record
         Write-Host "Seller : $seller"
	    }
	    default
	    {
           Write-Host "Detected default ebid"
	         Write-Verbose "Record: $($record.postage)"
           $estimate=$record.postage

           $seller=Get-EbidSeller -url $record.link
           $salestatus=Get-EBidSaleStatus -url $record.link
           $price=GetEbidPrice -url $record.link -Status $salestatus -OldPrice $record.Price
       }
   }

   $color      =Get-Image  -title $($record.Title) -issue $record.Issue
   Write-Verbose  "Set-Title -rawtitle $($record.Title)"
   $newtitle   =Set-Title -rawtitle $($record.Title)
   Write-Verbose "Set-Issue -rawissue `"$($record.Issue)`" -rawtitle `"$($record.Description)`" -title `"$newtitle`" -color $color"
   $ActualIssue=Set-Issue -rawissue $record.Issue -rawtitle $record.Description -title $newtitle -color $color

   #crap hack
   if(!$ActualIssue)
   {
     $IE[1].Application.Quit()
     write-host "Premature return"
     return
   }

   Write-Verbose "ActualIssue:$ActualIssue"
   $color      =Get-Image  -Title $newtitle -Issue $ActualIssue
   $newquantity=Set-Quantity -record $record -Issue $ActualIssue

   $priceestimate=0
   [double]$marketprice=0
   [double]$marketprice=Get-CurrentPrice -issue $ActualIssue -title $newtitle

   $foregroundcolor="red"

   if ($marketprice -gt [double]$($record.Price))
   {
      $foregroundcolor="green"
   }

   $marketprice="{0:N2}" -f $marketprice

  Write-Host "Price: $Price : market: $marketprice : " -foregroundcolor $foregroundcolor -NoNewline
  if ($salestatus -eq 'LIVE')
  {
    $overrideprice=read-hostdecimal
    if ($overrideprice)
    {
       $price=$overrideprice
       Write-Host "Overide set price at $price"
    }
  }else{Write-Host ""}

#postage
   if ($estimate -match "Free")
   {
      $estimate=[decimal]0
   }

   if ($estimate -notlike $NULL)
   {
      $converted=Get-Price $estimate
      $estimate=$converted.Amount
   }

   try
   {
      $estimate=[decimal]$estimate
      $postage=$estimate
   }
   catch
   {
      Write-Host "Postage: $($record.postage) estimate:$estimate" -NoNewline
      $postage=read-hostdecimal
      $postage="{0:N2}" -f $postage

      if ($postage -eq $NULL -or $postage -eq "")
      {
         $postage=$record.Postage
      }
   }

   Write-Host "Postage estimate:$estimate"

   $TCO ="{0:N2}" -f ([decimal]$postage+[decimal]$price)/$newquantity
   Write-Host "TCO per issue $TCO" -foregroundcolor cyan

   if ($salestatus)
   {
      $record=Set-ComicStatus -record $record -salestatus $salestatus
   }
   else
   {
      $record=Set-ComicStatus -record $record
   }

   $IE[1].Application.Quit()

   try
   {
      Write-Verbose "Update-DB -ebayitem $($record.ebayitem) -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $($record.status) -bought $($record.bought) -quantity $newquantity -seller $seller -watch $($record.watch)"
      Update-DB -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $record.status -bought $record.bought -quantity $newquantity -seller $seller -watch $record.watch
   }
   catch
   {
	   Write-Warning "Update Record Failure"
	   throw
   }
}

function Update-Record
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record,
   [string]$newstatus,
   [switch]$old)

   if ($old)
   {
     Write-Verbose "Using Legacy Update method"
     Update-RecordOld -record $record -newstatus $newstatus
   }
   else
   {
     Write-Verbose "Using new method"
     Update-RecordNew -record $record
   }
}
