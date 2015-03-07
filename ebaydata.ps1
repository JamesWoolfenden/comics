import-module "$PSScriptRoot\core.ps1" -force

function get-ebaydata
{
   param ([string]$title="The Walking Dead")
   
#curl --include --request GET "https://www.kimonolabs.com/api/1vt19h34?apikey=01f250503b7c40eb0ce695da7d74cbb1"

#Please remember to include your API key with each call to your API.
#URL Parameters

#http://www.ebay.co.uk/ sch / Comics- / 63 / i.html ? _from=R40 & ssPageName=STRK%3AMEFSRCHX%3ASRCH%7CSTRK%3AMEFSRCHX%3ASRCH%7CSTRK%3AMEFSRCHX%3ASRCH%7CSTRK%3AMEFSRCHX%3ASRCH & _nkw=peter+panzerfaust+-volume+-vol+-chew+-pacific+-sex+-jesus & LH_PrefLoc=3 & _sop=16
#Parameter 	Default value 	Parameter to append
#kimpath1 	sch 	&kimpath1=newvalue
#kimpath2 	Comics- 	&kimpath2=newvalue
#kimpath3 	63 	&kimpath3=newvalue
#kimpath4 	i.html 	&kimpath4=newvalue
#_from 	R40 	&_from=newvalue
#ssPageName 	STRK%3AMEFSRCHX%3ASRCH%7CSTRK%3AMEFSRCHX%3ASRCH%7CSTRK%3AMEFSRCHX%3ASRCH%7CSTRK%... 	&ssPageName=newvalue
#_nkw 	peter+panzerfaust+-volume+-vol+-chew+-pacific+-sex+-jesus 	&_nkw=newvalue
#LH_PrefLoc 	3 	&LH_PrefLoc=newvalue
$title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $site="Ebay"
   $fullfilter=""
   $url="https://www.kimonolabs.com/api/1vt19h34?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-verbose "Accessing $url"
   write-Host "Looking for $title @ `"$site`""
   $ebayresults=Invoke-RestMethod -Uri $url
   if ($ebayresults.lastrunstatus -eq "failure")
   {
      return $null
   }

   $counter=0
   $ebaycounters=@()
   $results= $ebayresults.results.collection1
   switch ($results -is [system.array] )
   {
      $NULL 
      {
         return $NULL 
      }
      $true
      {
         #do nothing
      }
      $false 
      {
         $results = $results | Add-Member @{count="1"} -PassThru
      }
      default
      {
         return $NULL
      }
   }
_sop 	16 	&_sop=newvalue
