
class Base
	constructor: (name, value) ->
		console.log "Base", name, value, arguments

class Sub	extends Base
	constructor: (a...) ->
		super a...
	

b = new Base("foo", "bar")
s = new Sub("baz", "bap")
