var args = process.argv.slice(2);

var Xray = require('x-ray');
var x = Xray();
x(args[0], args[1])(function(err, title) {
  process.stdout.write(title.toString());

  //console.log(title.toString('utf8')) // Google
})

x(args[0], args[2])(function(err, title) {
  process.stdout.write(title.toString());
  process.stdout.write(",");
  //console.log(title.toString('utf8')) // Google
})

x(args[0], args[3])(function(err, title) {
  process.stdout.write(title.toString());
    process.stdout.write(",");
  //console.log(title.toString('utf8')) // Google
})
