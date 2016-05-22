import-module "$PSScriptRoot\core.ps1" -force

function Get-fpdata
{
   param (  
   [Parameter(Mandatory=$true)]
   [PSObject]$record)

   $title=$record.title.ToUpper()
   $comic=$title.replace(" ","+")
   $search="&q=$comic+comics"
   $filter="&filter_instock=on"
   $size="&size=30"
   $fullfilter=$size+$filter+$search
   $site="Forbidden Planet"
   #$url="https://www.kimonolabs.com/api/ca9vxpfa?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   $url="https://www.kimonolabs.com/api/ondemand/ca9vxpfa?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   Write-Verbose "Accessing $url"
   Write-Host "$(Get-Date) - Looking for $title @ `"$site`""

<# Postage
   1X  �1.00  1.00
   2X  �1.00  0.50 
   3X  �2.00  0.67
   4X  �2.00  0.50 
   5X  �2.00  0.40
   6X  $3.00  0.50
   7X  $3.00  0.43
   8X  $4.00  0.50
   9X  $4.00  0.44
   10X $4.00  0.40
   11X $5.50  0.55 
   50X $5.50  0.11
#>
   try
   {
      $fpresults=Invoke-RestMethod -Uri $url 
      $results=$fpresults.results.collection1| where {$_.title -ne ""}
      
      if ($results -eq $null)
      {
         throw
      }
   }
   catch
   {
      Write-Warning "$(Get-Date) No data returned from $url"
      return $null
   }
   
  
   $counter=0
   $fp=@()

   $datetime=Get-Date

   foreach($result in $results)
   {
      $record= New-Object System.Object
      Write-Verbose "Counter $counter"
      if (($result.price[0] -eq "Pre-order") -or ($result.price[0] -eq "Web Price"))
      {
         $url=$null
         $price=($result.price[1]) -as [decimal]

         if ($result.title.Contains("#"))
         {
            $rawissue=$result.title.split("#")[1]
         }
         else
         {
            $rawissue=$result.title
         }
      }
      else
      {   
         $url=$result.price.href[1] 
         $price=($result.price.text[1]) -as [decimal] 
         if ($result.title.text.Contains("#"))
         {
            $rawissue=$result.title.text.split("#")[1]
         }
         else
         {
            $rawissue=$result.title.text
         }
      }
      
      $url="<a href=`"$($result.title.href)`">$($result.title.href)</a>"
      $record| Add-Member -type NoteProperty -name link -value $result.title.href
      $record| Add-Member -type NoteProperty -name url -value $url
      $record| Add-Member -type NoteProperty -name orderdate -value $result.orderdate.replace("before ","")
      $record| Add-Member -type NoteProperty -name title -value $title

      if ($rawissue.Contains("("))
      {
         $rawissue=$rawissue.split("(?=()")
         $issue=$rawissue[0]
         $variant=$rawissue[1]
      }
      Else
      {
         $issue=$rawissue
         $variant=$rawissue
      }

      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name rundate -value $datetime
      $record| Add-Member -type NoteProperty -name site -value $site
      
      $fp+=$record
      $counter++
   }
   
   Write-Host "$(Get-Date) - Found $counter"
   $fp
}