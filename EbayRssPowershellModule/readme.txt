Module: 	EbayRssPowershellModule
Purpose: 	Module to query Ebay's RSS feeds and parse the results into collection of items. This an alternative to using Ebay's developer Shopping API for basic search functions.

Function Get-EbayRssItems 
	[string] Keywords - Required Parameter. The keywords to query for.
	[string] ExcludeWords - Optional Parameter. Specify words that you do not want in the item's title. Seperate by spaces, not commas.
	[int] CategoryId - Optional Parameter. Specify the Ebay category ID to filter results.
	
Example call:
Get-EbayRssItems -Keywords "Sandy Koufax 1955 Topps" -ExcludeWords "Reprint RP"

Result:
The Get-EbayRssItems function returns an array of PSObjects(representing sale items available). Each PSObject will contain the following properties:

Title         : 1955 Topps Sandy Koufax RC BVG 6 Rookie Beckett BGS EX-MT Brooklyn Dodgers LA
EbayItem      : 360763948823
Link          : http://www.ebay.com/itm/1955-Topps-Sandy-Koufax-RC-BVG-6-Rookie-Beckett-BGS-EX-MT-Brooklyn-Dodgers-/360763948823
CloseDate     : 10/17/2013 7:33:35 PM
ImageSrc      : http://thumbs4.ebaystatic.com/m/mE1dw8MlmWEH8V84Rt_6u9g/80.jpg
BidCount      : 11
BuyItNowPrice : 0
CurrentPrice  : 330
AuctionType   : Auction
BestOffer     : False
PublishDate   : 10/12/2013 7:33:35 PM