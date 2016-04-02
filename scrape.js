var args = process.argv.slice(2);


var Xray = require('x-ray');
var x = Xray();
x(args[0], 'span.mbg-nw@html')(function(err, title) {
  console.log(title.toString('utf8')) // Google
})
