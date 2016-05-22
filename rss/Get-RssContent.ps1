function Get-RssContent 
{
	Param(
		[Parameter(Mandatory=$true)]
		[ValidateNotNull()]
		[string] $Keywords = $(throw "Keywords parameter is required"),
		[string] $ExcludeWords,
		[Parameter(Mandatory=$true)]
		[string]$state,
		[int]$CategoryId=0,
		[int]$Page=$NULL
	)
	
	$url = Build-Url -Keywords $Keywords -ExcludeWords $ExcludeWords -state $state -CategoryId $CategoryId -page $Page
	Write-Verbose "Reading $url"
	try
    {
		$Results=Invoke-webrequest $url
		$content=$Results.Content
		return [xml] "${Content}" 
	} 
    catch
    {
		Write-Host $_
	}
}
