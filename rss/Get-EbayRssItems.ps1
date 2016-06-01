Function Get-EbayRssItems 
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string]$Keywords = $(throw "Keywords parameter is required"),
		[string]$ExcludeWords,
		[Parameter(Mandatory=$true)]
		[string]$state,
		[int[]]$Categories
	)

    $results=@()
    foreach($Category in $Categories)
    {
       $results+= Get-RSSSet -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -Category $Category
    }

	return $results
}


function Get-RSSSet
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string]$Keywords = $(throw "Keywords parameter is required"),
		[string]$ExcludeWords,
		[Parameter(Mandatory=$true)]
		[string]$state,
		[int]$Category)

	[int]$Page=1
	$items = @()

	Do
	{
	   $count=0
	   Write-Verbose "Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $Category"
	   $xml = Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $Category -Page $Page
	   $xml.rss | % {$_.channel.item} | % {
		  $item = $_
		  try
		  {
		     $items += Parse-ListingInfo $item
			 $count++
		  }
		  catch 
		  {
             Write-Warning "`nFailed to parse item"
		  }
	   }

       $Page++
	}
	While ($count -gt 49)

	return $items
}