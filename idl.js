var jison = require('jison')
var fs = require('fs')

var idl_parser = new jison.Parser(fs.readFileSync('idl.jison', 'utf8'));
var a = idl_parser.parse(fs.readFileSync('/dev/stdin', 'utf8'));
console.log(JSON.stringify(a));
