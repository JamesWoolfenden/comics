Function Parse-ListingInfo 
{
	Param (
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		$item)

	$Title = ""
	$Link = ""
	$EbayItem = ""
	$CloseDate = $null
	$PublishDate = $null
	$ImageSrc = ""
	$BidCount = ""
	$BuyItNowPrice = ""
	$CurrentPrice = ""
	$AuctionType = ""
	$BestOffer = $false
	$Description = ""

	if ($item -eq $Null)
	{
	   Write-Warning "Passed value is null"
	   return $null
	}

	try	
    {
       $Title = $item.title."#cdata-section"
       $Title = $Title.Replace("`"", "")
       $Title = $Title.Replace(">", "")
       $Title = $Title.Replace("<", "")
		
       $Link = $item.link."#cdata-section"
			
       try
       {
          $EBAYITEM_REGEX = [regex] ".*(/)(?'Item'[0-9]+)(?+).*"
          if($Link -match $EBAYITEM_REGEX) 
          {
				$EbayItem = $Matches.Item
          }
       } 
       catch
       {}
       
       try 
        {
			[string]$Description = $item.description."#cdata-section"
		} 
		catch
		{
		   throw "Description Failed to cast"
		   exit 1
		}
	
		try { 
			$PubDate = $item.pubDate
			$PubDate = $PubDate.Replace(" PST", "")
			$PubDate = $PubDate.Replace(" PDT", "")
			$PublishDate = Get-Date $PubDate
		} 
        catch {}
		
		try {
			$IMAGE_REGEX = [regex] ".*(src=`"+)(?'ImageSrc'[^`"]+).*"
			if($description -match $IMAGE_REGEX) 
            {
				$ImageSrc = $Matches.ImageSrc
			}
		} 
        catch
        {}
		
		try 
        {
			$ENDDATE_REGEX = [regex]  ".*(End date: <span>+)(?'EndDate'[^<]+).*"
			Write-Verbose "$description"
			if($description -match $ENDDATE_REGEX) 
            {
				$EndDate = $Matches.EndDate
				$EndDate = $EndDate.Replace(" PST", "")
				$EndDate = $EndDate.Replace(" PDT", "")
				$EndDate = $EndDate.Replace(" GMT", "")
				$CloseDate = Get-Date $EndDate				
			}
		}
        catch
        {}

		try 
        {
			$BidCount = $item.BidCount."#text"
		} 
        catch
        {}
		
		try 
        {
			$b = $item.BuyItNowPrice."#text"
			$BuyItNowPrice = [int]$b/100	
		} 
        catch{}
		
		try {
			$c = $item.CurrentPrice."#text"
			$CurrentPrice = [int]$c/100
		} catch{}
		
		try {
			$AuctionType = $item.AuctionType."#text"
			if($CurrentPrice -eq $BuyItNowPrice) {
				$AuctionType = 'Buy it now'
			}
		} 
        catch{}
		
		try 
     {
			if($item.ItemCharacteristic."#text" -ne $null){		
				$BestOffer = $true
			}
		} 
        catch{}		

		$ItemInfo = New-Object PsObject
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'Title' -Value $Title
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'EbayItem' -Value $EbayItem
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'Link' -Value $Link
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'CloseDate' -Value $CloseDate
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'ImageSrc' -Value $ImageSrc
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'BidCount' -Value $BidCount
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'BuyItNowPrice' -Value $BuyItNowPrice
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'CurrentPrice' -Value $CurrentPrice
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'AuctionType' -Value $AuctionType
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'BestOffer' -Value $BestOffer
		$ItemInfo | Add-Member -MemberType NoteProperty -Name 'PublishDate' -Value $PublishDate
			
		return $ItemInfo	
	} 
    catch{}
}
