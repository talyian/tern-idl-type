webgl.json:
	@node idl.js < webgl.idl | jq 'map( select(.[0] == "interface") | {(.[1]):(.[2] | select (.[0]) | map({(.name):.type}) | add )}) | add | {"!name": "webgl"} + .' > webgl.json
