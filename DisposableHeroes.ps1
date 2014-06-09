function get-dhdata()
{
   param (
   [string]$title="The Walking Dead")
#Parameter 	Default value 	Parameter to append
#kimpath1 	index.php 	&kimpath1=newvalue
#act 	search 	&act=newvalue
#catId 		&catId=newvalue
#name 	walking+dead 	&name=newvalue
#cat_id 	0 	&cat_id=newvalue
#min_price 		&min_price=newvalue
#max_price 		&max_price=newvalue
#submit 	Search 	&submit=newvalue
   $title=$title.ToUpper()
   $comic=$title.replace(" ","+")
   $fullfilter="&name=$comic"
   $url="http://www.kimonolabs.com/api/aaaaq44g?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"
   write-Host "Looking for $title @ `"Disposable Heroes`""

<# Postage
   1X  £1.00  1.00
   2X  £1.00  0.50 
   3X  £2.00  0.67
   4X  £2.00  0.50 
   5X  £2.00  0.40
   6X  $3.00  0.50
   7X  $3.00  0.43
   8X  $4.00  0.50
   9X  $4.00  0.44
   10X $4.00  0.40
   11X $5.50  0.55 
   50X $5.50  0.11
#>
   $dhresults=Invoke-RestMethod -Uri $url
   if ($dhresults.lastrunstatus -eq "failure")
   {
      return $null
   }
   
   $results=$dhresults.results.collection1| where {$_.title -ne ""}
   $results=$results|where {$_.title.text -match "$title"}
   $counter=0
   $dh=@()

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

   While($counter -ne $results.count)
   {
      $record= New-Object System.Object
      
      $record| Add-Member -type NoteProperty -name url -value $results[$counter].title.href
      $record| Add-Member -type NoteProperty -name orderdate -value $null
      $record| Add-Member -type NoteProperty -name title -value $title

      if ($results[$counter].title.text.Contains("#"))
      {
         $rawissue=$results[$counter].title.text.split("#")[1]
      }
      else
      {
         $rawissue=$results[$counter].title.text
      }

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

      $price=$results[$counter].price.Replace("£","")
      $price=$price.split("")
      if ($price -is [system.array] )
      {
         $price=$price[1]
      }  

      
      $record| Add-Member -type NoteProperty -name issue -value $issue
      $record| Add-Member -type NoteProperty -name variant -value $variant
      $record| Add-Member -type NoteProperty -name price -value $price
      $record| Add-Member -type NoteProperty -name rundate -value $dhresults.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Disposable Heroes"
      
      $dh+=$record
      $counter++
   }
   
   write-host "Record $counter"
   $dh
}