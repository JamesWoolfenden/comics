//node .\scrape-json.js $URL "span#prcIsum" "a.mbg-id"
var args = process.argv.slice(2);

var Xray = require('x-ray');
var x = Xray();

x(args[0], args[1])(function(err, title) {
 console.log(JSON.stringify({"PriceSum": (title.toString()).trim()}));
})
console.log(",")
x(args[0], args[2])(function(err, title) {
 console.log(JSON.stringify({"Seller": (title.toString()).trim()}));
})
