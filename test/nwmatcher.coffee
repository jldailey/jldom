
dom = require("../dom")
assert = (c, msg) ->
	if not c
		throw Error msg

assertEqual = (a, b, label) ->
	if a isnt b
		throw Error "#{label} (#{a?.toString()}) should equal (#{b?.toString()})"

document = dom.createDocument()
document.body.innerHTML = "<div><p id='pId' class='c'><span class='c'></span></p><input name='foo' /></div>"

nw = require("../css/nwmatcher")
matcher = nw.init(global, document)

p = matcher.byId('pId')
c = matcher.byClass('c')
f = matcher.byName('foo')
s = matcher.byTag('span')
x = matcher.select('p + input')
assertEqual p.constructor.name, "HTMLParagraphElement"
assertEqual c.constructor.name, "Array"
assertEqual c.length, 2
assertEqual f.constructor.name, "Array"
assertEqual f.length, 1
assertEqual s.constructor.name, "Array"
assertEqual s.length, 1
assertEqual x.constructor.name, "Array"
assertEqual x.length, 1
assert matcher.match(c[0], '.c')
assert matcher.match(c[1], '.c')
assert !matcher.match(c[1], 'c')
console.log "All tests passed."

# vim: ft=coffee
