Function Get-EbayRssItems 
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string]$Keywords = $(throw "Keywords parameter is required"),
		[string]$ExcludeWords,
		[Parameter(Mandatory=$true)]
		[string]$state,
		[int]$CategoryId
	)

	$items = @()
	write-debug "Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $CategoryId"
	$xml = Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $CategoryId
	$xml.rss | % {$_.channel.item} | % {
		$item = $_
		$items += Parse-ListingInfo $item
	}
	return $items
}