function update-record
{
   param(
   [Parameter(Mandatory=$true)]
   $record, 
   [string]$newstatus)
   
   if ($($record.ebayitem))
   { 
      switch ($($record.site))
      {
         "ebay"
         {
            $ie=view $($record.ebayitem)         
         }
         "ebid"
         {
            $ie=view-url $($record.link)
         }
         default
         {
	        $ie=view $($record.ebayitem)
	     }
      }
   }
   else 
   {
      write-warning "$($record.ebayitem) is null or empty"
   }
   
   waitforpageload
      
   if ($record.site -eq "ebay")
   {
      $estimate=$ie.Document.getElementByID('fshippingCost').innerText
     
      if ($record.seller -eq "" -or $record.seller -eq $NULL)
      {
         write-host "Finding seller"
         $result=@($ie.Document.body.getElementsByClassName('mbg-nw'))
         $seller=$result[0].innerText
      }
      else
      {
         $seller=$record.seller
      }
   }
   Else
   {
      write-debug "Record: $($record.postage)"
      $estimate=$record.postage
      if ($record.site -eq "ebid" -And $record.seller -eq "")
      {
         $seller=($ie.Document.body.document.body.getElementsByTagName('a')| where{$_.innerHTML -eq "All about the seller"}).nameProp
      }
      else
      {
         $seller=$record.seller
      }
   }

   
   $newtitle=set-title -rawtitle $($record.Title)

   $color=found-image  -title $newtitle -issue $record.Issue
   
   $estimateIssue=set-issue -rawissue $($record.Issue) -rawtitle $($record.Description) -color $color

   $color=found-image  -title $newtitle -issue $estimateIssue
   
   write-host "Issue $($estimateIssue) or (i)dentify:" -Foregroundcolor $color -nonewline
   $actualIssue=read-host  
   
   if ($actualIssue -eq "i")
   {
     $actualIssue=get-imagetitle -issue (get-cover $estimateIssue) -title $newtitle
   }
   
   if ($actualIssue -eq $NULL -or $actualIssue -eq "")
   {
      $actualIssue=$estimateIssue
   }   
   
   $actualIssue=$actualIssue.ToUpper()
   if (!(test-image -title $newtitle -issue $actualIssue))
   {
      if ($($record.ImageSrc))
      {
         Write-host "Updating Library with image of $newtitle : $actualIssue" -foregroundcolor cyan
         $filepath= get-imagefilename -title $newtitle -issue $actualIssue
         Write-host "Downloading from $($record.Imagesrc) " 
         Write-host "Writing to $filepath" 
         set-imagefolder $newtitle $actualIssue
         Invoke-webRequest $($record.ImageSrc) -outfile $filepath 
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
      
   write-host "Seller: $seller"
   $priceestimate=0
   [double]$marketprice=0
   [double]$marketprice=get-currentprice -issue $actualIssue -title $newtitle
   
   $foregroundcolor="red"
   
   if ($marketprice -gt [double]$($record.Price))
   {
      $foregroundcolor="green"
   }
   
   $marketprice="{0:N2}" -f $marketprice   
   
   if ($record.site -eq "ebay")
   {
      $priceestimate= $ie.Document.getElementByID('prcIsum').innerText
      if ($priceestimate -eq $NULL)
      {
         $priceestimate= ($ie.Document.getElementByID('prcIsum_bidPrice').innerText)      
      }
      
      #still null must have stopped auction?
      if ($priceestimate -eq $NULL)
      {
         $closedpriceestimate = @($ie.Document.body.getElementsByClassName('notranslate vi-VR-cvipPrice'))
         $priceestimate=$closedpriceestimate[0].innerText
      }
      else
      {
         $priceestimate=$priceestimate.replace("£","")    
      }
      
      Write-host "Price $($record.Price): estimate:$priceestimate market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline    
   }
   else
   {
       Write-host "Price $($record.Price): market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline      
   }
   
   [decimal]$price=read-host 
   
   if ($price -eq $NULL -or $price -eq "")
   {
      $price=$record.Price
   }
   
   write-debug "Before Estimate $estimate"
   if ($estimate -notlike $NULL)
   {
      $estimate=($estimate.Replace("£","")).Replace('$',"")
   }

   if ($estimate -match "Free")
   {
      $estimate=[decimal]0
   }

   if ($estimate -match "Free")
   {
      $estimate=[decimal]0
   }

   try
   {     
      $estimate=[decimal]$estimate 
      $postage=$estimate
   }
   catch
   {
      $postage=new-object decimal
      $postage=read-host "Postage: $($record.postage) estimate:$estimate"
      $postage="{0:N2}" -f $postage
    
      if ($postage -eq $NULL -or $postage -eq "")
      {
         $postage=$record.Postage
      }  
   }

   write-host "Postage estimate:$estimate"

   $TCO ="{0:N2}" -f ([decimal]$postage+[decimal]$price)/$newquantity
   write-host "TCO per issue $TCO" -foregroundcolor cyan
   
   $bought="false"
   [string]$newstatus=read-host $record.Status "(V)erified, (C)losed, (E)xpired, (B)ought, (W)atch"
   [boolean]$watch=$false
   
   switch($newstatus)
   {
      "C"
      {
         $newstatus="CLOSED"
      }
      "V"
      {
         $newstatus="VERIFIED"
      }
      "E"
      {
         $newstatus="EXPIRED"    
      }
      "B"
      {
         $newstatus="CLOSED"
         $bought="true"
      }
      "W"
      {
         $newstatus="VERIFIED"
         $watch=$true
      }
      default
      {
         $newstatus=$record.status
         $watch=$record.watch
      }
   }
   
   $IE.Quit()
   Write-debug "update-db -ebayitem $($record.ebayitem) -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -seller $seller -watch $watch"

   update-db -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $newstatus -bought $bought -quantity $newquantity -seller $seller -watch $watch
}



function set-title 
{
   param([string]$rawtitle)

   $newtitle=($rawtitle.ToUpper()).Split("#")
   $title=read-host "Title $($newtitle[0])"

   If (($title -eq $null) -or ($title -eq ""))
   {
      $($newtitle[0]).trim()
   }  
   else
   {
      $title
   }
}

function set-issue
{
   param(
   [string]$rawissue,
   [string]$rawtitle,
   [string]$color)
  
   write-debug "$rawissue $rawtitle $color"
   
   if ($rawissue -eq "0")
   {   
      $tempstring=$rawtitle.split("#")
      if ($tempstring[1] -ne $null)
      {
        $tempstring=($tempstring[1].Trim()).split(" ")
        
        if ($tempstring -is [system.array])
        {
           $tempstring =$tempstring[0]
        }
        
        $estimateIssue=$tempstring 
      }
      else
      {
            $estimateIssue=$rawissue
      }

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

   $estimateIssue
 }  
 