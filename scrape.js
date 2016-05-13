var args = process.argv.slice(2);

var Xray = require('x-ray');
var x = Xray();
x(args[0], args[1])(function(err, title) {
  process.stdout.write(title.toString());
})
