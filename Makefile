run:
	@node idl.js < webgl.idl

webgl.json:
	node idl.js < webgl.idl | jq -S '{"!name":"webgl"} + add' > webgl.json
