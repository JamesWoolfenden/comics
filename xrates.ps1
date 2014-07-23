function get-xrates()
{
   #$uri="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20%28%22USDGBP%22%29&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
   $uri="https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDGBP%22%2C%22EURGBP%22)&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback="
   $rates=invoke-restmethod $uri

   $usdrate=$rates.query.results.rate[0].Rate
   $eurrate=$rates.query.results.rate[1].Rate
   
   $rates.query.results.rate
}
