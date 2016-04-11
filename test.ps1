$SoldPrice=& node.exe $PSScriptRoot\scrape.js http://www.ebay.co.uk/itm/172122547645? 'span.notranslate'
write-host "SoldPrice $SoldPrice"
$SoldPrice -replace"[^ -x7e]",""
