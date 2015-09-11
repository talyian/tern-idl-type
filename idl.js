var jison = require('jison')
var fs = require('fs')
var child_process = require('child_process')

var idl_parser = new jison.Parser(fs.readFileSync('idl.jison', 'utf8'));

idl_parser.Def = function Def(name, value) {
    var v = {};
    v[name] = value;
    return v;
};

idl_parser.Body = function Body(values) {
    var combined = {};
    values.forEach(function(v) { combined[v.name] = v.type; })
    return combined;
}

_types = {
    "unsigned long": 'number',
    "long": 'number',
    "long long": 'number',
    "unsigned short": 'number',
    "short": 'number',
    "byte": 'number',
    "octet": 'number',
    "unrestricted float": 'number',
    "float": 'number',
    "unrestricted double": 'number',
    "double": 'number',
    "boolean": 'boolean'
};

idl_parser.map_simple_type = function map_simple_type(t) {
    if (t in _types) return _types[t];
    return t;
}
var schema = idl_parser.parse(fs.readFileSync('/dev/stdin', 'utf8'));
console.log(JSON.stringify(schema, null, 2))
