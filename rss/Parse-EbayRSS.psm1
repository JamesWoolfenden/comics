function Get-RssContent 
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Keywords = $(throw "Keywords parameter is required"),
		[string] $ExcludeWords,
		[Parameter(Mandatory=$true)]
		[string]$state,
		[int]$CategoryId=0
	)
	
	$url = Build-Url -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $CategoryId

	write-verbose "Reading $url"
	try
    {
		$Results=Invoke-webrequest $url
		$content=$Results.Content
		return [xml] "${Content}" 
	} 
    catch
    {
		Write-host $_
	}
}

function Get-EbayRssItems 
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
	   $items = @()
	   write-verbose "Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $Category"
	   $xml = Get-RssContent -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $Category
	   $xml.rss | % {$_.channel.item} | % {
		  $item = $_
		  try
		  {
		     $items += Parse-ListingInfo $item
		  }
		  catch 
		  {
             write-warning "`nFailed to parse item"
		  }
	   }
    }

    $results+=$items

	return $results
}