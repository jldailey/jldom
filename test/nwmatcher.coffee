
dom = require("../dom")

document = dom.createDocument()
document.body.innerHTML = "<div><p id='pId' class='c'><span class='c'></span></p><input name='foo' /></div>"
console.log document.toString(true, true)

nw = require("../css/nwmatcher")
matcher = nw.init(global, document)

p = matcher.byId('pId')
c = matcher.byClass('c')
f = matcher.byName('foo')
s = matcher.byTag('span')
x = matcher.select('p + input')
console.log p.constructor.name, p.length or 0, p.toString()
console.log c.constructor.name, c.length or 0, c.toString()
console.log f.constructor.name, f.length or 0, f.toString()
console.log s.constructor.name, s.length or 0, s.toString()
console.log x.constructor.name, x.length or 0, x.toString()

# vim: ft=coffee
