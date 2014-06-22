Function Build-Url
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Keywords = $(throw "Keywords parameter is required"),
		[string] $ExcludeWords,
		[Parameter(Mandatory=$true)]
        [string]$state,
        [int] $CategoryId=0
	)
	
	$ExcludeWords.Split(' ') | % {
		$Keywords += " -${_}"
	}

	$Keywords = $Keywords.Replace(" ", "+")
	$Keywords = $Keywords.Replace("(", "%28")
	$Keywords = $Keywords.Replace(")", "%29")
	
	$url= 'http://www.ebay.co.uk/sch/US-Comics-/64755/i.html?rt=nc&_nkw=${Keywords}&LH_PrefLoc=3'
	
	switch ($state)
	{
	   "Closed"
	   {
	      $url = $url+'&LH_Complete=1'   	      
	   }
	   "Sold"
	   {
	      $url = $url+'&LH_Complete=1&LH_Sold=1'   
	   }
	   default
	   {
	     #do nothing
	   }
	}
	
	$url=$url+"&_rss=1&"
	
	$url = $ExecutionContext.InvokeCommand.ExpandString($url)
	
	return $url
}
