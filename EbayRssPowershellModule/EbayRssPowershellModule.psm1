
# Source all the files in the module directory
Write-Verbose "Begin loading module from $PSScriptRoot"
Get-ChildItem -Path "$PSScriptRoot\*.ps1" | % {
	Write-Verbose "Sourcing $_"
	. $_.FullName
}
Write-Verbose "End loading module from $PSScriptRoot"

Export-ModuleMember -Function Get-EbayRssItems
