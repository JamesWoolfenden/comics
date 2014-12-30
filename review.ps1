function update-record
{
   param(
   [Parameter(Mandatory=$true)]
   $record, 
   [string]$newstatus)

   #postage
   $estimate=$null
   $seller=$null

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
      if ($ie.Document.getElementByID('fshippingCost'))
      {
         $estimate=$ie.Document.getElementByID('fshippingCost').innerText
      }
      else
      {
         write-host "Postage cannot be estimated"
      }

      if ($record.seller -eq "" -or $record.seller -eq $NULL)
      {
         
         write-host "Finding seller" -NoNewline
         $result=@($ie.Document.body.getElementsByClassName('mbg-nw'))

         #could be old and return nothing
         if ($result)
         {
            $seller=$result[0].innerText
            Write-Host " $seller" -ForegroundColor green
         }
         else
         {
            Write-Host " not found" -ForegroundColor red
         }
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
   
   $newtitle=(set-title -rawtitle $($record.Title)).ToUpper()

   $color=found-image  -title $newtitle -issue $record.Issue
   
   $estimateIssue=set-issue -rawissue $($record.Issue) -rawtitle $($record.Description) -title $newtitle -color $color

   $color=found-image  -title $newtitle -issue $estimateIssue
   
   write-host "Issue $($estimateIssue) or (i)dentify:" -Foregroundcolor $color -nonewline
   $actualIssue=read-host  
   
   if ($actualIssue -eq "i")
   {
     if (($estimateIssue -replace("\D","")) -eq "")
     {
        write-host "Estimate Cover Issue:" -Foregroundcolor $color -nonewline
        $cover=read-host  
     }
     else
     {
        $cover=get-cover $estimateIssue
     }

     $actualIssue=get-imagetitle -issue $cover -title $newtitle
     write-host "Choose $actualIssue" -ForegroundColor cyan
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
      if ($ie.Document.getElementByID('prcIsum'))
      {
         $priceestimate= $ie.Document.getElementByID('prcIsum').innerText
      }
      else
      {
         if ($ie.Document.getElementByID('prcIsum_bidPrice'))
         {
            $priceestimate= ($ie.Document.getElementByID('prcIsum_bidPrice').innerText)      
         }
      }

      #still null must have stopped auction?
      if ($priceestimate -eq $NULL)
      {
         $closedpriceestimate = @($ie.Document.body.getElementsByClassName('notranslate vi-VR-cvipPrice'))
         $priceestimate=$closedpriceestimate[0].innerText
      }
      else
      {
         if ($priceestimate -is [string])
         {
            $priceestimate=$priceestimate.replace("£","")    
         }
      }
      
      Write-host "Price $($record.Price): estimate:$priceestimate market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline    
   }
   else
   {
       Write-host "Price $($record.Price): market:$marketprice : " -foregroundcolor $foregroundcolor -NoNewline      
   }
    
   $price=read-hostdecimal 
   
   if ($price -eq $NULL -or $price -eq "")
   {
      $price=$record.Price
   }
    
   if ($estimate -notlike $NULL)
   {
      $estimate=($estimate.Replace("£","")).Replace('$',"")
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
         if ($record.status -eq "Open")
         {
            $newstatus="VERIFIED"
         }
         else{
            $newstatus=$record.status
         }
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
   $padtitle=$newtitle -replace(" ","-")
   $found=test-Path "$root\covers\$padtitle"
   write-debug "Title at $root\covers\$padtitle"

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
   if (!(test-Path $root\covers\$padtitle))
   {
     write-Host "New title: $returntitle" -ForegroundColor cyan
   }

   $returntitle
}

function set-issue
{
   param(
   [string]$rawissue,
   [string]$rawtitle,
   [string]$title,
   [string]$color)
  
   write-debug "$rawissue $rawtitle $color"

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
	      write-debug "Before estimate tempstring $tempstring"
          $splitstring=($tempstring.Trim()).split(" ")
        
          if ($splitstring -is [system.array])
          {
             $splitstring= $splitstring[0]
          }     

          #found-image  -title $newtitle -issue $record.Issue
          if ($splitstring)
          {
             $estimateIssue=$splitstring 
          }
          else
          {
             $estimateIssue=$null
          }
          
          write-debug "Tempstring $tempstring $($tempstring.GetType())"
          write-debug "guess-title -title $title -issue $estimateIssue"
          $estimateIssue=guess-title -title $title -issue $estimateIssue
          write-debug "After estimate $estimateIssue"
      }
      else
      {
	     $tempstring=@()
         write-debug "No split # $($rawtitle -split('No'))"
         #maybe used no to indicate version
         
		 if ($rawtitle -Contains("No"))
         {
		    $tempstring=$rawtitle -split("No")
		    write-debug "Split on No $tempstring"
            
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
            $estimateIssue=guess-title -title $title -issue "$estimateIssue"
            write-debug "After estimate $estimateIssue"
         }
         else
         {
            $edition=""
            write-debug "No splits $rawissue"
            if ($rawtitle -match "1st")
            { 
               $rawtitle =$rawtitle.Replace("1st","")
               $edition = "A"  
            } 

            #ok best chance did not work now edge cases
            $estimateIssue=($rawtitle -replace("\D",""))
            if ($estimateIssue)
            {
               $estimateIssue=guess-title -title $title -issue $estimateIssue
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

   $estimateIssue
 }  

 function guess-title
 {
    param(
    [Parameter(Mandatory=$true)]
    [string]$title,
    [string]$issue=$null)

    $issue=$issue.replace(".","")
    $issue=$issue.replace(",","")
      
    if ($Issue)
    {
       $cover=get-cover $issue
    }
    else
    {
      $cover="set"
    }

    $padtitle=$title -replace(" ","-")
    write-host "looking for $root\covers\$padtitle\$cover\$issue"

    if (test-path "$root\covers\$padtitle\$cover\$issue.jpg")
    {
       return $issue 
    }
    else
    {
       if (test-path "$root\covers\$padtitle\$cover\$($issue)A.jpg")
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
 