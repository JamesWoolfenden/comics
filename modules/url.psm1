
function get-urltocomicarray
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$url,
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$site,
   [string[]]$filters="")

   $result=$null

   write-verbose "Accessing $url"
   write-Host "$(Get-Date) - Looking for $title @ `"$site`""

   try
   {
      $rawresults=Invoke-RestMethod -Uri $url  
      $results=$rawresults.results.collection1| where {$_.title -ne ""}
      
      #title filters
      foreach($filter in $filters)
      {
         $results=$results| where {$_.title.text -notmatch "$filter"}
      }

      #pricefilters
      $results=$results| where {$_.price -ne ""}

      if ($results -eq $null)
      {
         throw
      }
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
   }

   $results
}