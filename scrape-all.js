var args = process.argv.slice(2);

var Xray = require('x-ray');
var x = Xray();

  console.log(args[0])

x(args[0], 'span.notranslate')(function(err, price) {
  console.log(price.toString('utf8')) // Google
})

x(args[0], 'span.mbg-nw@html')(function(err, title) {
  console.log(title.toString('utf8')) // Google
})
x(args[0], '.sh-fr-cst')(function(err, title) {
  console.log(title.toString('utf8')) // Google
})

x(args[0], 'span#w1-3-_msg')(function(err, title) {
  console.log(title.toString('utf8')) // Google
})
