
function view-record
{
   param([PSObject]$record)

   #$ie=new-object -com internetexplorer.application
   
   if ($record.ebayitem)
   { 
      switch ($record.site.ToUpper())
      {
         "EBAY"
         {
            $ie=view $record.ebayitem         
         }
         "EBID"
         {
            $ie=view-url $record.link
         }
         default
         {
            $ie=view $record.ebayitem
         }
      }
   }
   else 
   {
      write-warning "$($record.ebayitem) is null or empty"
   }
   
   $ie
}

function update-record
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$record, 
   [string]$newstatus)

   [PSObject]$OldRecord=$record

   #postage
   $estimate=$null
   $seller  =$null

   $ie=view-record $record

   switch($record.site.ToUpper())
   {
      'EBAY'
	  {
	     if ($ie[1].Document.getElementByID('fshippingCost'))
         {
            $estimate=$ie[1].Document.getElementByID('fshippingCost').innerText
         }
         else
         {
            write-host "Postage cannot be estimated"
         }

         $seller=get-ebaysellerfromie -ie $ie -record $record
	  }
	  default
	  {
	     write-verbose "Record: $($record.postage)"
         $estimate=$record.postage
         if ($record.site -eq "ebid" -And $record.seller -eq "")
         {
            $seller=get-ebidsellerfromie -ie $ie
         }
         else
         {
            $seller=$record.seller
         }
	  }
   }
      
   $newtitle=(set-title -rawtitle $($record.Title)).ToUpper()

   $color        =get-image  -title $newtitle -issue $record.Issue
   $estimateIssue=set-issue -rawissue $record.Issue -rawtitle $record.Description -title $newtitle -color $color
   $color        =get-image  -title $newtitle -issue $estimateIssue
   
   write-host "Issue $($estimateIssue) - (i)dentify or (r)eplace:" -Foregroundcolor $color -nonewline
   $actualIssue=read-host
 
   switch($actualIssue)
   {
      "i"
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
	  "r"
	  {
    	 Write-host "r"
	     $filepath= get-imagefilename -title $newtitle -issue $actualIssue
	     ri $filepath -Force | ForEach-Object {
             $removeErrors = @()
             $_ | Remove-Item -ErrorAction SilentlyContinue -ErrorVariable removeErrors
             $removeErrors | where-object { $_.Exception.Message -notlike '*it is being used by another process*' }
             }
	     Invoke-webRequest $record.ImageSrc -outfile $filepath    
	  }
      default
      {
         if ($actualIssue -eq $NULL -or $actualIssue -eq "")
         {
            $actualIssue=$estimateIssue
         }   
      }
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
   [double]$marketprice=get-currentprice -issue $actualIssue -title $newtitle
   
   $foregroundcolor="red"
   
   if ($marketprice -gt [double]$($record.Price))
   {
      $foregroundcolor="green"
   }
   
   $marketprice="{0:N2}" -f $marketprice   
   
   if ($record.site -eq "ebay")
   {
      try
      {
         if ($ie[1].Document.getElementByID('prcIsum_bidPrice'))
         {
            $priceestimate= ($ie[1].Document.getElementByID('prcIsum_bidPrice').innerText)      
         }
      }
      catch
      {
         if ($ie[1].Document.getElementByID('prcIsum'))
         {
            $priceestimate= ($ie[1].Document.getElementByID('prcIsum').innerText)      
         }
      }

      #still null must have stopped auction?
      if ($priceestimate -eq $NULL)
      {
         $closedpriceestimate = @($ie[1].Document.body.getElementsByClassName('notranslate vi-VR-cvipPrice'))
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
 
   $record=set-comicstatus -record $record
      
   $IE[1].Application.Quit()
   update-db -ebayitem $record.ebayitem -UpdateValue $actualIssue -price $price -postage $postage -title $newtitle -Status $record.status -bought $record.bought -quantity $newquantity -seller $seller -watch $record.watch
}

function set-comicstatus
{
   param([PSObject]$record)

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

   $record
}


function set-title 
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

function set-issue
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
          write-verbose "guess-title -title $title -issue $estimateIssue"
          $estimateIssue=guess-title -title $title -issue $estimateIssue
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
            $estimateIssue=guess-title -title $title -issue "$estimateIssue"
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
 
function get-ebidsellerfromie
{
   param(
   [Parameter(Mandatory=$true)]
   $ie)

   try
   {
      #$seller=($ie.Document.body.document.body.getElementsByTagName('a')| where{$_.innerHTML -eq "All about the seller"}).nameProp
      $result=@($ie[1].Document.body.getElementsByClassName('t10 l5 f4 center'))
      [string]$seller=($result.textContent.trim() -split(' '))[0]
	  Write-host "Seller: $seller"
   }
   catch
   {
      Write-error "Page expired?"
      $seller=$null
   }

   $seller
}

function get-ebaysellerfromie
{
   param(
   [Parameter(Mandatory=$true)]
   $ie,
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   if (!($record.seller))
   {
       try
       {
          $result=@($ie[1].Document.getElementsByClassName('mbg-nw'))
		  if (!($result))
	      {
	         Write-warning "Using Old IE model"
             $result=@($ie[1].Document.body.getElementsByClassName('mbg-nw'))          
	      }
       }
       catch
       {
          Write-verbose "Failing over to Old IE model"
		  if ($ie[1].Document.body.getElementsByClassName('mbg-nw'))
	      {
             $result=@($ie[1].Document.body.getElementsByClassName('mbg-nw'))
          }
		  else
	      {
	         $result=$null
	      }
	   }
            
       #could be old and return nothing
       if ($result)
       {
         [string]$seller=($result.textContent.trim() -split(' '))[0]
       }
       else
       {
         write-host 'Seller is $Null'
         $seller=$NULL
       }
   }
   else
   {
      write-host "Seller unchanged $seller"
      $seller=$record.seller
   }

   Write-Host "Seller: $seller" -ForegroundColor green
   $seller
}