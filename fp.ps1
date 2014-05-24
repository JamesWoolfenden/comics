function get-fpdata()
{
   param ([string]$title="The Walking Dead")

   $comic=$title.replace(" ","+")
   $search="&q=$comic+comics"
   $filter="&filter_instock=on"
   $size="&size=30"
   $fullfilter=$size+$filter+$search
   $url="http://www.kimonolabs.com/api/ca9vxpfa?apikey=01f250503b7c40eb0ce695da7d74cbb1$fullfilter"
   write-Host "Accessing $url"

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
   $fpresults=Invoke-RestMethod -Uri $url
   $fpclean=$fpresults.results.collection1| where {$_.title -ne ""}
   $counter=0
   $fp=@()

   While($counter -ne $fpclean.count)
   {
      write-host "Record $counter"
      $record= New-Object System.Object
      
      $record| Add-Member -type NoteProperty -name url -value $fpclean[$counter].price.href[1]
      $record| Add-Member -type NoteProperty -name orderdate -value $fpclean[$counter].orderdate.replace("before ","")
      $record| Add-Member -type NoteProperty -name title -value $title
      $rawissue=$fpclean[$counter].title.text.split("#")[1]
      $issue=$rawissue.split("(?=()")
      $record| Add-Member -type NoteProperty -name issue -value $issue[0]
      $record| Add-Member -type NoteProperty -name variant -value $issue[1]
      $record| Add-Member -type NoteProperty -name price -value $fpclean[$counter].price.text[1]
      $record| Add-Member -type NoteProperty -name rundate -value $fpraw.lastsuccess
      $record| Add-Member -type NoteProperty -name site -value "Forbidden Planet"
      
      $fp+=$record
      $counter++
   }
   $fp
}