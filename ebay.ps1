
import-module "$PSScriptRoot\core.ps1" -force

function get-ebayitem()
{
   #curl --include --request GET "https://www.kimonolabs.com/api/afv7qe7k?apikey=01f250503b7c40eb0ce695da7d74cbb1"
   param (
   [string]$ebayid="201080445741",
   [string]$title="The Walking Dead")

#http://www.ebay.co.uk/ itm / 201080445741 /
#Parameter 	Default value 	Parameter to append
#kimpath1 	itm 	&kimpath1=newvalue
#kimpath2 	201080445741 	&kimpath2=newvalue
   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $fullfilter="&kimpath2=$ebayid"
   $url="https://www.kimonolabs.com/api/afv7qe7k?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"

   $results=Invoke-RestMethod -Uri $url
}