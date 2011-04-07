assert = (c, msg) ->
	if not c
		throw Error msg

assertEqual = (a, b, label) ->
	if a isnt b
		throw Error "#{label} (#{a?.toString()}) should equal (#{b?.toString()})"

dom = require('../dom')
global.document = dom.createDocument()
global.window = global

assert(document?, "document should exist")
assert(document.body?, "document.body should exist")
assert(document.head?, "document.head should exist")
assertEqual(document.nodeType, 9, "document.nodeType")

div = document.createElement('div')
assertEqual(div.nodeType, 1, "div.nodeType")
assertEqual(div.nodeName, "DIV", "div.nodeName")

document.body.appendChild(div)
assertEqual(document.body.childNodes.length, 1, "document.body.childNodes.length")
nodesByTagName = document.body.getElementsByTagName('DIV')
assertEqual(nodesByTagName.length, 1, "nodesByTagName.length")
div = document.createElement("div")
div.id = "testId"
assertEqual(div.attributes['id'], div.id, "div.attributes.id")
document.body.appendChild(div)
assertEqual(document.body.childNodes.length, 2, "document.body.childNodes.length")
nodeById = document.getElementById("testId")
assertEqual(nodeById, div, "nodeById")

span = document.createElement("span")
div.appendChild(span)
assertEqual div.childNodes.length, 1, "div.childNodes.length"
nodesByTagName = div.getElementsByTagName("span")
assertEqual nodesByTagName.length, 1, "nodesByTagName"
assertEqual nodesByTagName[0], span, "nodesByTagName[0]"
p = document.createElement("p")
p.id = 'classTest'
p.className = "alpha beta"
div.appendChild(p)
assertEqual div.childNodes.length, 2, "div.childNodes.length"
assertEqual div.childNodes[0], span, "div.childNodes[0]"
assertEqual div.childNodes[1], p, "div.childNodes[1]"
alphaNodes = div.getElementsByClassName("alpha")
betaNodes = div.getElementsByClassName("beta")
assertEqual alphaNodes.length, 1, "alphaNodes.length"
assertEqual betaNodes.length, 1, "betaNodes.length"
assertEqual alphaNodes[0], p, "alphaNodes[0]"
assertEqual betaNodes[0], p, "betaNodes[0]"

fragment = document.createDocumentFragment()
fragment.appendChild(document.createElement("div"))
fragment.appendChild(document.createElement("p"))

assertEqual fragment.childNodes.length, 2, "fragment.childNodes.length"
assertEqual fragment.toString(), "<div/><p/>", "fragment.toString()"

div.appendChild(fragment)

text = document.createTextNode("Harro!")
div.appendChild(text)
div.setAttribute("name", "foo")
assertEqual div.getAttribute("name"), "foo", "div.getAttribute('foo')"

attr = div.getAttributeNode("name")
assertEqual attr.value, "foo", "attr.value"
assertEqual attr.nodeValue, "foo", "attr.nodeValue"

testSelector = (s, output) ->
	x = document.querySelectorAll(s)
	assertEqual x.toString(), output, s

testSelector "p#classTest", '<p id="classTest" class="alpha beta"/>'
testSelector "p.alpha.beta", '<p id="classTest" class="alpha beta"/>'
testSelector "p", '<p id="classTest" class="alpha beta"/>,<p/>'
testSelector "div *", '<span/>,<p id="classTest" class="alpha beta"/>,<div/>,<p/>'

# console.log document.toString(true,true)
console.log "All tests passed."

# vim: ft=coffee
