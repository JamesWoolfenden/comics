$dbfile="C:\comics\data.XML"

function read-db
{
   [xml]$comics= Get-Content $dbfile
   $comics
}

function add 
{
   param(
   [Parameter(Mandatory=$true)]
   [string]$title,
   [Parameter(Mandatory=$true)]
   [string]$issue,
   [Parameter(Mandatory=$true)]
   [string]$price,
   [bool]$bought=$false,
   [string]$PublishDate,
   [string]$Ebayitem,
   [string]$Status="Closed",
   [string]$Description="")

   if (!(test-path $dbfile))
   {
      new-xmlfile $dbfile
   }
   
   write-host "Updating $dbfile"
   
   $doc = [xml](Get-Content -Path $dbfile) 
   $element   = $doc.CreateElement("Comic")
   $element.SetAttribute('Title',$title)
   $element.SetAttribute('Description',$Description)
   $element.SetAttribute('Price',$Price)
   $element.SetAttribute('Issue',$Issue)
   $element.SetAttribute('Bought',$bought)
   $element.SetAttribute('PublishDate',$PublishDate)
   $element.SetAttribute('EbayItem', $EbayItem)
   $element.SetAttribute('Status', $Status)
   $saledate = Get-Date 
   $element.SetAttribute('DateOfSale',$saledate)
   
   $doc.DocumentElement.AppendChild($element)

   $doc.Save($dbfile)
   write-host "Updated $dbfile."
}

function new-xmlfile ()
{
   param ([string]$filename)

   $doc = new-object xml
   $decl = $doc.CreateXmlDeclaration("1.0", $null, $null)
   $rootNode = $doc.CreateElement("root");
   $doc.InsertBefore($decl, $doc.DocumentElement)
   $doc.AppendChild($rootNode);
   $doc.Save($filename)
   write-warning "Created new db file $filename"
}

function find()
{
   param([string]$title,[string]$Issue)
   $test=read-db
   $result=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And $_.Status -eq "CLOSED"}
   
   [double]$total=0
   [double]$maximum=0
   [double]$minimum=0
   
   [int]$count=1
   [int]$owned=$NULL
   [double]$paid=$NULL
   
   if ($result -eq $NULL)
   {
      return "None Found"
   }
   
   if($result.count)
   {
      $count=$result.count
      $minimum=$result[0].Price
   }
   else
   {
      $minimum=$result.Price
   }
   
   foreach($comic in $result)
   {      
      #write-host  $comic.Price $minimum
      $minimum=[System.Math]::Min($comic.Price,$minimum)
      $maximum=[System.Math]::Max($comic.Price,$maximum)
      if ($comic.Bought -eq $true)
      {
         $paid += $comic.Price
         $owned ++ 
      }
          
      #Write-host "Paid  $($comic.Bought) $paid"
      #Write-host "Price  $($comic.Price)"
      $total += $comic.Price    
   }
   
    $averagepaid=$paid/$owned
    if ($result.Count)
    {
      $average=$total/$result.Count
    }
    else
    {
       $average=$total
    }
    
   
    $average="{0:N2}" -f $average
    
    $objStats = New-Object System.Object
    $objStats | Add-Member -type NoteProperty -name Title -value $($comic.Title)
    $objStats | Add-Member -type NoteProperty -name Issue -value $Issue
    $objStats | Add-Member -type NoteProperty -name TargetPrice -value $average
    $objStats | Add-Member -type NoteProperty -name Minimum -value $minimum
    $objStats | Add-Member -type NoteProperty -name Maximum -value $maximum
    $objStats | Add-Member -type NoteProperty -name Count -value $count
    $objStats | Add-Member -type NoteProperty -name AveragePaid -value $averagepaid
    $objStats | Add-Member -type NoteProperty -name Stock -value $owned
   return $objStats 
}

function stat()
{
   param([string]$title,[string]$Issue)
   $test=read-db
   if ($Issue)
   {
      $test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue}|Format-Table 
   }
   else
   {
      $test.root.comic| where-object {$_.Title -eq $title}| Sort-Object Issue | Format-Table -groupby Issue 
   }
}

function add-array()
{
   param(
   [Parameter(Mandatory=$true)]
   $resultset, 
   [Parameter(Mandatory=$true)]
   $title, 
   [Parameter(Mandatory=$true)]
   $issue)
   
   #first lets read in all existing related items
   $test=read-db
   $existingrecords=$test.root.comic| where-object {$_.Title -eq $title}
   
   #$existingrecords.count
   #$resultset.count
   
   foreach ($old in $existingrecords)
   {
      $resultset=$resultset|where {$_.Ebayitem -ne $old.ebayItem}
      #$resultset.count
   }
   
   #test $existingrecords.Ebayitem  $result.Ebayitem 
   #add state as pending for live auctions
   
   foreach($result in $resultset)
   {
      add $title $issue $result.CurrentPrice $false $result.PublishDate $result.Ebayitem "Open" $result.Title
   }
   
   #$resultset
   "$($resultset.count) Added"
}


function verify()
{
   param([string]$title,[string]$Issue)
   $test=read-db
   $result=$test.root.comic| where-object {$_.Title -eq $title -And $_.Issue -eq $Issue -And $_.Status -eq "Open"}
   $result
}

function update()
{
   param( 
   [Parameter(Mandatory=$true)]
   [string]$ebayitem,
   [string]$UpdateValue
   )
   
   # if loading the XML from file then do this
   $doc = New-Object System.Xml.XmlDocument
   $doc.Load($dbfile)

   $selectstring="//Comic[@EbayItem = '$ebayitem']"
   $comic = $doc.SelectSingleNode("$selectstring")
   
   if ($UpdateValue -eq $NULL -or $UpdateValue -eq "" )
   {
      $comic.Issue = $comic.Issue
   }
   else
   {
      $comic.Issue = $UpdateValue
   }
   
   $comic.Status = "VERIFIED"

   $doc.Save($dbfile)
}

function view
{
   param($ebayid)
   $IE=new-object -com internetexplorer.application
   $url="www.ebay.co.uk/itm/$ebayid"
   write-host "Opening $url`?"
   $IE.navigate2("$url`?")
   $IE.visible=$true
}

