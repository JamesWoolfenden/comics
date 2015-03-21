function get-xrates
{
   #$uri="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20%28%22USDGBP%22%29&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
   $uri="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDGBP%22%2C%22EURGBP%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
   $rates=invoke-restmethod $uri

   $usdrate=$rates.query.results.rate[0].Rate
   $eurrate=$rates.query.results.rate[1].Rate
   
   $rates.query.results.rate
}

function get-eurodollarrate
{
   $xml = New-Object xml
   $xml.Load('http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml')
   $rates = $xml.Envelope.Cube.Cube.Cube
   Write-host "$(Get-Date) - Current USD exchange rate:"
   $usd = $rates | Where-Object { $_.currency -eq 'USD' } | 
   Select-Object -ExpandProperty rate
   $usd
}

#function get-gbpdollarrate
#{
#   $url="http://rate-exchange.appspot.com/currency?from=USD&to=GBP"
#   $data=invoke-restmethod -uri $url
#   
#   Write-host "$(Get-Date) - Current USD exchange rate: $($data.rate)"
#   $data.rate
#}

function get-gbpdollarrate
{
   $url="http://openexchangerates.org/api/latest.json?app_id=37dfbc191d564cec930b8b8cf808e57c"
   $data=invoke-restmethod -uri $url
   $data.rates."GBP"
}