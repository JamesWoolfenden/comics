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
      write-warning "$($record.ebayitem) is null or empty"
   }

   $ie
}

function Update-Record
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
         switch ($salestatus.ToUpper())
         {
           'EXPIRED'
           {
             Write-Host "SaleStatus : $salestatus"
             Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
             $IE[1].Application.Quit()
             return
           }
           'SOLD'
           {
             Write-Host "SaleStatus : $salestatus"
           }
           'LIVE'
           {
             Write-Host "SaleStatus : $salestatus"
           }
           'DELISTED'
           {
             Write-Host "SaleStatus : $salestatus"
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
	         Write-verbose "Record: $($record.postage)"
           $estimate=$record.postage
           if ($record.site -eq "ebid" -And $record.seller -eq "")
           {
              $seller=Get-EbidSellerIE -ie $ie
           }
           else
           {
              $seller=$record.seller
           }
	     }
   }

   $newtitle=(set-title -rawtitle $($record.Title)).ToUpper()

   $color        =Get-image  -title $newtitle -issue $record.Issue
   $estimateIssue=Set-Issue -rawissue $record.Issue -rawtitle $record.Description -title $newtitle -color $color
   $color        =Get-image  -title $newtitle -issue $estimateIssue

   write-host "Issue $($estimateIssue) - (i)dentify, (c)lose or (r)eplace:" -Foregroundcolor $color -nonewline
   $actualIssue=(read-host).ToUpper()

   switch($actualIssue)
   {
      "I"
      {
          if (($estimateIssue -replace("\D","")) -eq "")
          {
             write-host "Estimate Cover Issue:" -Foregroundcolor $color -nonewline
             $cover=read-host
          }
          else
          {
             $cover=Get-cover $estimateIssue
          }

          $actualIssue=Get-imagetitle -issue $cover -title $newtitle
          write-host "Choose $actualIssue" -ForegroundColor cyan
      }
	  "R"
	  {
    	 Write-host "R"
	     $filepath= Get-imagefilename -title $newtitle -issue $actualIssue
	     ri $filepath -Force | ForEach-Object {
             $removeErrors = @()
             $_ | Remove-Item -ErrorAction SilentlyContinue -ErrorVariable removeErrors
             $removeErrors | where-object { $_.Exception.Message -notlike '*it is being used by another process*' }
             }
	     Invoke-webRequest $record.ImageSrc -outfile $filepath
	  }
	  "C"
	  {
       Update-DB -ebayitem $record.ebayitem -Status "EXPIRED"
		   $IE[1].Application.Quit()
       return
	  }
      default
      {
         if ($actualIssue -eq $NULL -or $actualIssue -eq "")
         {
			      Write-Host "Assuming value $estimateIssue"
            $actualIssue=$estimateIssue
         }
      }
   }

   if (!(test-image -title $newtitle -issue $actualIssue))
   {
      if ($($record.ImageSrc))
      {
         Write-host "Updating Library with image of $newtitle : $actualIssue" -foregroundcolor cyan
         $filepath= Get-imagefilename -title $newtitle -issue $actualIssue
         Write-host "Downloading from $($record.Imagesrc) "
         Write-host "Writing to $filepath"
         set-imagefolder $newtitle $actualIssue

         try
         {
            Invoke-webRequest $record.ImageSrc -outfile $filepath
         }
         catch
         {
            write-host "Cannot download  $($record.ImageSrc)"
         }
      }
      Else
      {
         Write-host "No image data"
      }
   }

   $newquantity  = new-object int
   $newquantity=1

   if ($actualIssue -eq "SET" -And $($record.Quantity) -eq 1)
   {
      $readquantity=read-host "Number in set:$($record.Quantity)"
      if  ($readquantity -gt 0)
      {
         $newquantity = $readquantity
      }
   }

   $priceestimate=0
   [double]$marketprice=0
   [double]$marketprice=Get-CurrentPrice -issue $actualIssue -title $newtitle

   $foregroundcolor="red"

   if ($marketprice -gt [double]$($record.Price))
   {
      $foregroundcolor="green"
   }

   $marketprice="{0:N2}" -f $marketprice

   if ($record.site -eq "ebay")
   {
      $price=Get-EbaySoldPrice -record $record

      Write-host "Price $($record.Price):  market:$marketprice : " -foregroundcolor $foregroundcolor
   }
   else
   {
       Write-host "Price $($record.Price): market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline
       $price=read-hostdecimal
   }

   if ($price -eq $NULL -or $price -eq "")
   {
      $price=$record.Price
   }

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
      write-host "Postage: $($record.postage) estimate:$estimate" -NoNewline
      $postage=read-hostdecimal
      $postage="{0:N2}" -f $postage

      if ($postage -eq $NULL -or $postage -eq "")
      {
         $postage=$record.Postage
      }
   }

   write-host "Postage estimate:$estimate"

   $TCO ="{0:N2}" -f ([decimal]$postage+[decimal]$price)/$newquantity
   write-host "TCO per issue $TCO" -foregroundcolor cyan

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
      Update-DB -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $record.status -bought $record.bought -quantity $newquantity -seller $seller -watch $record.watch
   }
   catch
   {
	   Write-Warning "Update Record Failure"
	   throw
   }
}

function Set-ComicStatus
{
   param(
     [PSObject]$record,
   [string]$salestatus=$NULL)

   if ($salestatus)
   {
     switch($salestatus)
     {
       'LIVE'
       {
         $record.Status="VERIFIED"
       }
       'SOLD'
       {
         $record.Status="CLOSED"
       }
     }
     $record.Status="VERIFIED"
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
   param([string]$rawtitle)

   $newtitle=($rawtitle.ToUpper()).Split("#")
   $padtitle=$newtitle -replace(" ","-")
   $found=test-Path "$PSScriptRoot\covers\$padtitle"
   write-verbose "Title at $PSScriptRoot\covers\$padtitle"

   if ($found)
   {
      write-Host "Title $($newtitle[0]):" -NoNewline -ForegroundColor green
   }
   else
   {
      write-Host "New Title? $($newtitle[0]):" -NoNewline -ForegroundColor Yellow
   }

   $title=read-host

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
     write-Host "New title: $returntitle" -ForegroundColor cyan
   }

   $returntitle
}

function Set-Issue
{
   param(
   [string]$rawissue,
   [string]$rawtitle,
   [string]$title,
   [string]$color)

   write-verbose "$rawissue $rawtitle $color"

   #if its a new record
   if ($rawissue -eq "0")
   {
      [string]$tempstring=$null

      #are we lucky to have an issue no?
      if ($rawtitle.Contains("#"))
      {
         $tempstring=$rawtitle.Split("#")[1]
      }
      elseif (($rawtitle.ToUpper()).Contains("PROG"))
      {
         $tempstring=($rawtitle.ToUpper() -split("PROG"))[1]
      }

      #has it split
      if ($tempstring -ne $null)
      {
          write-verbose "Before estimate tempstring $tempstring"
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

          write-verbose "Tempstring $tempstring $($tempstring.GetType())"
          write-verbose "GuessTitle -title $title -issue $estimateIssue"
          $estimateIssue=GuessTitle -title $title -issue $estimateIssue
          write-verbose "After estimate $estimateIssue"
      }
      else
      {
         $tempstring=@()
         write-verbose "No split # $($rawtitle -split('No'))"
         #maybe used no to indicate version

         if ($rawtitle -Contains("No"))
         {
            $tempstring=$rawtitle -split("No")
            write-verbose "Split on No $tempstring"

            $splitspaces=($tempstring[1].Trim()).split(" ")

            if ($splitspaces -is [system.array])
            {
               $estimateIssue =$splitspaces[0]
            }
            else
            {
               $estimateIssue=$tempstring
            }

            write-host "Before estimate estimateIssue $estimateIssue"
            $estimateIssue=GuessTitle -title $title -issue "$estimateIssue"
            write-verbose "After estimate $estimateIssue"
         }
         else
         {
            $edition=""
            write-verbose "No splits $rawissue"
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
         write-host "Estimate issue ($rawIssue):" -Foregroundcolor $color -nonewline
         $estimateIssue=read-host
      }
   }
   else
   {
      $estimateIssue=$rawIssue
   }

   $Keys=("PHANTOM","CGC","SIGNED")

   foreach($key in $Keys)
   {
      if ($rawtitle.ToUpper() -match $key)
      {
         if ($estimateIssue -notmatch $key)
         {
            $estimateIssue+=$key
            write-host "Added $key to $estimateIssue"
         }
         else
         {
            write-host "Found $key in $estimateIssue"
         }
      }
   }

   $estimateIssue
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
    write-host "looking for $PSScriptRoot\covers\$padtitle\$cover\$issue.jpg"

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
          write-host "Guessing a set $issue"
          return "set"
       }
    }
 }

function Get-EbidSellerIE
{
   param(
   [Parameter(Mandatory=$true)]
   $ie)

   try
   {
      #$seller=($ie.Document.body.document.body.getElementsByTagName('a')| where{$_.innerHTML -eq "All about the seller"}).nameProp
      #$result=@($ie[1].Document.body.getElementsByClassName('t10 l5 f4 center'))
      #$result=@($ie[1].Document.body.getElementsByClassName('col-md-4 col-sm-12 clearfix nobottommargin center'))
	  $result=@($ie[1].Document.body.getElementsByClassName('fs-14'))

      #[string]$seller=($result.textContent.trim() -split(' '))[0]
	  $seller=$result.Innertext[1].Split('(')[0]
	  Write-host "Seller: $seller"
   }
   catch
   {
      Write-error "Page expired?"
      $seller=$null
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
      #Write-host "Looking for 'span.notranslate'"
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
       #Write-host "Looking for 'span#prcIsum.notranslate'"
       $money=scrape $url 'span#prcIsum.notranslate'
       $SoldPrice=$money[1].trim()
    }

    #write-host $SoldPrice
    (Get-Price $SoldPrice).Amount
}

function Get-EbaySaleStatus
{
    param(
      [Parameter(Mandatory=$true)]
      [PSObject]$record)
    $url="http://www.ebay.co.uk/itm/$($record.ebayitem)?"

    $salestatus="live"
    $status=scrape $url 'span#w1-3-_msg'

    $delisted=scrape $url 'div.sml-cnt'
    if (!($delisted))
    {
       If ($status -match "Bidding has ended on this item")
       {
         $salestatus="sold"
       }

       if ($status -match "This listing has ended")
       {
           $result=scrape $url span.vi-qtyS.vi-bboxrev-dsplblk.vi-qty-vert-algn.vi-qty-pur-lnk
           if ($result)
           {
              $salestatus="sold"
           }
           else
           {
              $salestatus="expired"
           }
       }
  }
  else
  {
    $salestatus='delisted'
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
