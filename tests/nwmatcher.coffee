require "./common"

nw_doc = global.dom.createDocument()
nw_doc.body.innerHTML = "<div><p id='pId' class='c'><span class='c'>C</span></p><input name='foo' /></div>"

nw = require("../css/nwmatcher")
matcher = nw.init(global, nw_doc)

TestGroup 'nwmatcher', {
	id: () -> assertEqual matcher.byId('pId').constructor.name, "HTMLParagraphElement"
	class: () ->
		c = matcher.byClass('c')
		assertEqual c.constructor.name, "Array"
		assertEqual c.length, 2
		assert matcher.match(c[0], '.c')
		assert matcher.match(c[1], '.c')
		assert !matcher.match(c[1], 'c')
	name: () ->
		f = matcher.byName('foo')
		assertEqual f.constructor.name, "Array"
		assertEqual f.length, 1
	tag: () ->
		s = matcher.byTag('span')
		assertEqual s.constructor.name, "Array"
		assertEqual s.length, 1
	sibling: () ->
		x = matcher.select('p + input')
		assertEqual x.constructor.name, "Array"
		assertEqual x.length, 1
	star: () ->
		a = matcher.select('*')
		assertEqual a.constructor.name, "Array"
		assertEqual a.length, 6
}

TestReport()

# vim: ft=coffee
