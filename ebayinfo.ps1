finding
http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByProduct&SECURITY-APPNAME=RedWolfS-f525-478e-b13e-8893d513d683&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&productId.@type=UPC&productId=024543611363


completed
http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findCompletedItems&SERVICE-VERSION=1.7.0&SECURITY-APPNAME=RedWolfS-f525-478e-b13e-8893d513d683&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&keywords=MANIFEST+DESTINY&itemFilter(0).name=SoldItemsOnly&itemFilter(0).value=true&sortOrder=PricePlusShippingLowest&paginationInput.entriesPerPage=100

#Get completed items from uk
$coreurl="http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findCompletedItems&SERVICE-VERSION=1.7.0&SECURITY-APPNAME=RedWolfS-f525-478e-b13e-8893d513d683&RESPONSE-DATA-FORMAT=JSON&REST-PAYLOAD&GLOBAL-ID=EBAY-GB"
$query="&keywords=MANIFEST+DESTINY&itemFilter(0).name=SoldItemsOnly&itemFilter(0).value=true&sortOrder=EndTimeSoonest&paginationInput.entriesPerPage=500"

$url=$coreurl+$query 
$test=invoke-restmethod -Uri $url -Method GET
$comic=$test.findCompletedItemsResponse.searchresult.item[0]

#page2
$query="&keywords=MANIFEST+DESTINY&itemFilter(0).name=SoldItemsOnly&itemFilter(0).value=true&sortOrder=EndTimeSoonest&paginationInput.entriesPerPage=100&paginationInput.pageNumber=2"
$url=$coreurl+$query 
$test=invoke-restmethod -Uri $url -Method GET
$comic=$test.findCompletedItemsResponse.searchresult.item[0]

paginationInput.pageNumber=2


filters
http://developer.ebay.com/DevZone/finding/HowTo/GettingStarted_JS_NV_JSON/GettingStarted_JS_NV_JSON.html
http://developer.ebay.com/DevZone/finding/CallRef/findCompletedItems.html#Samples


sniping starts here
http://developer.ebay.com/DevZone/XML/docs/Reference/eBay/PlaceOffer.html#samplebid




