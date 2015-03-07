import-module "$PSScriptRoot\core.ps1" -force

function get-comicconnectdata
{
   param(
   [Parameter(Mandatory=$true)]
   [PSObject]$Record)

#curl --include --request GET "https://www.kimonolabs.com/api/4iuvcfgy?apikey=01f250503b7c40eb0ce695da7d74cbb1"
#Please remember to include your API key with each call to your API.
#URL PARAMETERS 
#When you use URL parameters, your API will disregard any crawling strategy and extract data at the time of your crawl (temporarily overriding any other settings previously set for this API).
#PARAMETER	DEFAULT VALUE	PARAMETER TO APPEND
#kimpath1	bookSearch.php	&kimpath1=newvalue
#title	walking+dead	&title=newvalue
#issue		&issue=newvalue
#pageSize	200	&pageSize=newvalue
   $title=$Record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $site="comicconnect"
   $url="https://www.kimonolabs.com/api/4iuvcfgy?apikey=01f250503b7c40eb0ce695da7d74cbb1&title=$comic"
   write-verbose "Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"$site`""

