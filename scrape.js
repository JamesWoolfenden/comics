var args = process.argv.slice(2);

var Xray = require('x-ray');
var x = Xray();
x(args[0], args[1])(function(err, title) {
  console.log(title.toString('utf8')) // Google
})
