assert = require 'assert'
dom = require "../lib/dom.js"
dom.registerGlobals global
global.dom = dom # mocha seems to break some closure references
global.document = dom.createDocument()
global.window = global

testSelector = (s, output) ->
	x = document.querySelectorAll(s)
	assert.equal x.toString(), output, s

describe 'document', ->
	it "should exist", ->
		assert document?
	it "has a head", ->
		assert document.head?
	it "has a body", ->
		assert document.body?
	it "has DOCUMENT_ELEMENT node type", ->
		assert.equal document.nodeType, 9, "document.nodeType"
	describe '.createElement()', ->
		div = document.createElement('div')
		it 'has node type', ->
			assert.equal div.nodeType, 1
		it 'has node name', ->
			assert.equal div.nodeName, "DIV"
		it 'has a style object', ->
			assert div.style
		describe 'appending new element to document', ->
			it 'appears in parent.childNodes', ->
				document.body.innerHTML = ""
				document.body.appendChild div
				assert.equal document.body.childNodes.length, 1
			it 'can be removed', ->
				document.body.innerHTML = ""
				document.body.appendChild div
				document.body.removeChild div
				assert.equal document.body.childNodes.length, 0
	describe '.getElementsByTagName()', ->
		it "should find a single element", ->
			document.body.innerHTML = "<div/>"
			assert.equal document.body.getElementsByTagName('DIV').length, 1
		it "should find nested elements", ->
			document.body.innerHTML = "<p><div><div/></div></p>"
			assert.equal document.body.getElementsByTagName('DIV').length, 2
		it "is not case sensitive", ->
			document.body.innerHTML = "<p><div><div/></div></p>"
			assert.equal document.body.getElementsByTagName('div').length, 2
	describe '.getElementById()', ->
		it 'finds a single element', ->
			div = document.createElement("div")
			div.id = "getElemId"
			document.body.appendChild(div)
			assert.equal document.getElementById("getElemId"), div
	describe ".attributes", ->
		it "is read/write", ->
			div = document.createElement 'div'
			div.attributes.foo = 'bar'
			assert.equal div.attributes.foo, 'bar'
		it "appears in a .toString()", ->
			div = document.createElement 'div'
			div.attributes.foo = 'bar'
			assert.equal div.toString(), '<div foo="bar"/>'
		it "treats .id as a special attribute", ->
			div = document.createElement 'div'
			div.id = 'testId'
			assert.equal div.attributes.id, div.id
		it "treats .className special", ->
			div = document.createElement 'div'
			div.className = 'foo'
			assert.equal div.attributes.class, 'foo'
		describe ".get/setAttribute()", ->
			it "reads/writes the .attributes map", ->
				div = document.createElement("div")
				div.setAttribute("name", "foo")
				assert.equal div.getAttribute("name"), "foo"
		describe ".hasAttribute()", ->
			it "is true if attr exists", ->
				div = document.createElement("div")
				div.setAttribute("name", "")
				assert.equal div.hasAttribute("name"), true
			it "is false if attr does not exist", ->
				div = document.createElement("div")
				assert.equal div.hasAttribute("name"), false
		describe ".getAttributeNode()", ->
			it "returns an attribute node with value and nodeValue", ->
				div = document.createElement("div")
				div.setAttribute("name", "foo")
				attr = div.getAttributeNode("name")
				assert.equal attr.value, "foo"
				assert.equal attr.nodeValue, "foo"
	describe ".childNodes", ->
		it "every node should have .childNodes", ->
			div = document.createElement("div")
			div.id = "subChildren_parent"
			document.body.appendChild(div)
			span = document.createElement("span")
			div.appendChild(span)
			assert.equal div.childNodes.length, 1
			nodesByTagName = div.getElementsByTagName("span")
			assert.equal nodesByTagName.length, 1
			assert.equal nodesByTagName[0], span
	describe ".getElementsByClassName()", ->
		it "should find elements by class name", ->
			div = document.createElement("div")
			div.id = "getElemClass_parent"
			document.body.appendChild(div)
			p = document.createElement("p")
			p.id = 'classTest'
			p.className = "alpha beta"
			div.appendChild(p)
			alphaNodes = div.getElementsByClassName("alpha")
			betaNodes = div.getElementsByClassName("beta")
			assert.equal alphaNodes.length, 1, "alphaNodes.length"
			assert.equal betaNodes.length, 1, "betaNodes.length"
			assert.equal alphaNodes[0], p, "alphaNodes[0]"
			assert.equal betaNodes[0], p, "betaNodes[0]"
	describe "fragments",  ->
		fragment_doc = fragment = null
		it "can be created", ->
			fragment_doc = global.dom.createDocument()
			fragment = fragment_doc.createDocumentFragment()
		it "can have children", ->
			fragment.appendChild(fragment_doc.createElement("div"))
			fragment.appendChild(fragment_doc.createElement("p"))
			assert.equal fragment.childNodes.length, 2, "fragment.childNodes.length"
		it "can render toString", ->
			assert.equal fragment.toString(), "<div/><p/>", "fragment.toString()"
		it "can be appended to a node and disappear", ->
			div = fragment_doc.createElement("div")
			div.id = "fragment_test"
			fragment_doc.body.appendChild(div)
			div.appendChild(fragment)
			assert.equal fragment_doc.toString(), '<html><head/><body><div id="fragment_test"><div/><p/></div></body></html>'
	describe "anchor node", ->
		it "can be created", ->
			a = document.createElement("A")
		describe ".href", ->
			it "can be set", ->
				a = document.createElement("A")
				a.href = "ws://localhost"
				assert.equal a.href, "ws://localhost"
				a.href = "ws2://joe:secret@localhost:81/pa/th/?sea=rch&bar=baz#hash"
				assert.equal a.href, "ws2://joe:secret@localhost:81/pa/th/?sea=rch&bar=baz#hash"
				assert.equal a.protocol, "ws2:"
				assert.equal a.auth, 'joe:secret'
				assert.equal a.hostname, 'localhost'
				assert.equal a.port, '81'
				assert.equal a.pathname, '/pa/th/'
				assert.equal a.search, '?sea=rch&bar=baz',
				assert.equal a.hash, '#hash'
				a.protocol = "ws3:"
				a.auth = null
				assert.equal a.href, "ws3://localhost:81/pa/th/?sea=rch&bar=baz#hash"
			it "can be set with setAttribute", ->
				a = document.createElement("A")
				a.setAttribute 'href', "ws://localhost"
				assert.equal a.href, "ws://localhost"
				a.setAttribute 'href', "ws2://joe:secret@localhost:81/pa/th/?sea=rch&bar=baz#hash"
				assert.equal a.href, "ws2://joe:secret@localhost:81/pa/th/?sea=rch&bar=baz#hash"
				assert.equal a.protocol, "ws2:"
				assert.equal a.auth, 'joe:secret'
				assert.equal a.hostname, 'localhost'
				assert.equal a.port, '81'
				assert.equal a.pathname, '/pa/th/'
				assert.equal a.search, '?sea=rch&bar=baz',
				assert.equal a.hash, '#hash'
				a.protocol = "ws3:"
				a.auth = null
				assert.equal a.getAttribute('href'), "ws3://localhost:81/pa/th/?sea=rch&bar=baz#hash"

	describe "text nodes", ->
		it "can be created", ->
			text = document.createTextNode("&nbsp;")
		it "has nodeValue",  ->
			text = document.createTextNode("Harro!")
			assert.equal(text.nodeValue, "Harro!", "text.nodeValue")
		it "can set .data property",  ->
			text = document.createTextNode("Harro!")
			text.data = "BB"
			assert.equal(text.nodeValue, "BB", "text.nodeValue")
		it "can put html in .data",  ->
			text = document.createTextNode("Harro!")
			text.data = "<p>"
			assert.equal(text.nodeValue, "&lt;p&gt;", "text.nodeValue")
		it "can read .data back from .innerHTML (escaped)",  ->
			text = document.createTextNode("Harro!")
			text.data = "<p>"
			div = document.createElement("div")
			div.appendChild(text)
			assert.equal(div.innerHTML, "&lt;p&gt;")
			text.data = "Goodbye!"
			assert.equal(div.innerHTML, "Goodbye!")
		describe ".innerText", ->
			text = div = null
			it "includes direct text nodes", ->
				text = document.createTextNode("&nbsp;")
				div = document.createElement("div")
				# first put some simple text in a div
				div.appendChild(text)
				# and confirm we see it properly via the innerHTML/Text getters
				assert.equal div.innerHTML, "&nbsp;"
				assert.equal div.innerText, "&nbsp;"
			it "also includes deeply nested text nodes", ->
				# then create a span with some more text
				span = document.createElement "span"
				text2 = document.createTextNode "hello"
				span.appendChild text2
				assert.equal span.innerText, "hello"
				# and insert it along side the existing text
				div.appendChild(span)
				# and confirm that the innerText getter puts the two together
				assert.equal(div.innerText, "&nbsp;hello")
	describe "input nodes", ->
		it "treats .value as an attribute-property", ->
			input = document.createElement("input")
			input.value = 'bar'
			input.setAttribute('value', 'foo')
			assert.equal input.value, 'foo', 'input.value'
			assert.equal input.value, input.getAttribute('value'), 'input.getAttribute("value")'
		describe "<select/option>", ->
			select = optionA = optionB = null
			it "can be created", ->
				select = document.createElement("select")
				optionA = document.createElement("option")
				optionB = document.createElement("option")
				assert.equal optionA.constructor.name, "HTMLOptionElement"
				assert.equal optionA.constructor.__super__.constructor.name, "HTMLInputElement"
			it "<option> can have value", ->
				optionA.value = '1'
				optionA.innerText = 'A'
				optionB.innerText = 'B'
				assert.equal optionA.value, '1', 'optionA.value'
				assert.equal optionB.value, 'B', 'optionB.value'
			it "<select> can have <option> children", ->
				select.appendChild(optionA)
				select.appendChild(optionB)
			it ".selectedIndex is populated", ->
				assert.equal select.selectedIndex, 0, 'select.selectedIndex'
			it ".value is populated", ->
				assert.equal select.value, '1', 'select.value'
			it ".selectedIndex is settable and updates .value", ->
				select.selectedIndex = 1
				assert.equal select.selectedIndex, 1, 'select.selectedIndex * 2'
				assert.equal select.value, 'B', 'select.value'
		describe "<input type='radio'>", ->
			test_doc = global.dom.createDocument()
			test_doc.body.innerHTML = "<input type='radio' selected>"
			input = test_doc.body.childNodes[0]
			it "should be an HTMLInputElement", ->
				assert.equal input.constructor.name, "HTMLInputElement"
			it "has a 'selected' attribute", ->
				assert.equal input.hasAttribute('selected'), true
			it "having selected attribute means selected is true", ->
				assert.equal input.getAttribute('selected'), ''
				assert.equal input.selected, true
				input.removeAttribute('selected')
				assert.equal input.selected, false
			it "should have a default value of 'on'", ->
				assert.equal input.value, "on"
		describe "<input type='checkbox'>", ->
			test_doc = global.dom.createDocument()
			test_doc.body.innerHTML = "<input type='checkbox' checked >"
			input = test_doc.body.childNodes[0]
			it "should have a special .checked property", ->
				assert.equal input.checked, true, 'input.checked'
			it "should have a default value of 'on'", ->
				assert.equal input.value, "on"
	it "can create/render comments",  ->
		comment_doc = global.dom.createDocument()
		comment = comment_doc.createComment("comment text")
		assert.equal comment.nodeValue, "comment text"
		comment_doc.body.appendChild(comment)
		assert.equal comment_doc.body.toString(), '<body><!--comment text--></body>'
	it "can create/render conditional comments",  ->
		doc = global.dom.createDocument()
		comment = doc.createCComment("if lt IE 9")
		script = doc.createElement('script')
		script.setAttribute('src', 'ie.js')
		comment.appendChild script
		doc.body.appendChild(comment)
		assert.equal doc.body.toString(), '<body><!--[if lt IE 9]><script src="ie.js"/><![endif]--></body>'
	describe ".querySelectorAll()", ->
		it "id",  ->
			document.body.innerHTML = '<div><span/><p id="classTest" class="alpha beta"/></div>'
			testSelector "p#classTest", '<p id="classTest" class="alpha beta"/>'
		it "class",  ->
			document.body.innerHTML = '<div><span/><p id="classTest" class="alpha beta"/></div>'
			testSelector "p.alpha.beta", '<p id="classTest" class="alpha beta"/>'
		it "tag",  ->
			document.body.innerHTML = '<div><span/><p id="classTest" class="alpha beta"/></div>'
			testSelector "p", '<p id="classTest" class="alpha beta"/>'
		it "star",  ->
			document.body.innerHTML = '<div><span/><p id="classTest" class="alpha beta"/></div>'
			testSelector "div *", '<span/>,<p id="classTest" class="alpha beta"/>'
	
	describe "Events", ->
		it "can bind and trigger events", ->
			doc = global.dom.createDocument()
			doc.body.innerHTML = "<div id='a'><div id='b'></div></div>"
			a = doc.querySelector("#a")
			pass = false
			a.attachEventListener "dummy", ((evt) -> pass = true), false
			e = doc.createEvent "Events"
			e.initEvent "dummy", true, true
			a.dispatchEvent e
			assert pass
		it "propagates up", ->
			doc = global.dom.createDocument()
			doc.body.innerHTML = "<div id='a'><div id='b'></div></div>"
			a = doc.querySelector("#a")
			b = doc.querySelector("#b")
			pass = false
			a.attachEventListener "dummy", ((evt) -> pass = true), false
			e = doc.createEvent "Events"
			e.initEvent "dummy", true, true
			b.dispatchEvent e
			assert pass
			

	test_parse = (input, output, debug = false) ->
		html = require('../html/parser')
		try
			result = html.parse(input, document, debug).toString(false, true)
			output ?= input
		catch err
			err.message = "Failed to Parse: #{input}, Error: #{err.message}"
			throw err
		if result isnt output
			throw Error result+" !== "+output
	
	describe ".innerHTML can parse", ->
		cases = [
			["text", "text"],
			["<p>","<p/>"],
			["<div/>"],
			["<div />", "<div/>"],
			["<div>Harro?</div>"],
			["<div>foo</div>"],
			["<div>1,2</div>"],
			["<div><p>Hi.</p></div>"],
			["<div><p><span>Bye.</span></p></div>"],
			["<div><p/></div>"],
			["<div><p /></div>", "<div><p/></div>"],
			["<div><p  /></div>", "<div><p/></div>"],
			["<div key='val'></div>", '<div key="val"/>'],
			["<div key='val' ></div>", '<div key="val"/>'],
			["<div key='val'/>", '<div key="val"/>'],
			["<div key='val' />", '<div key="val"/>'],
			["<div id='test_parse'></div>", '<div id="test_parse"/>'],
			["<input checked/>"],
			["<eval>CurrencyFormat(Application.User.balance)</eval>"],
			['<body><!-- comment --><span>foo</span></body>'],
			['<a>Hello<b>World</b></a>'],
			['<head><meta charset="utf-8"><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'],
			['<head><meta charset="utf-8"/><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'],
			['<head><meta charset="utf-8"></meta><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'],
		]
		for c in cases
			it c[0], -> test_parse c...

	test_escape = (input, output) ->
		html = require('../html/parser')
		result = html.escape(input)
		if result isnt output
			throw Error result+" !== "+output
	
	describe ".innerHTML does escape", ->
		it '<p>', -> test_escape '<p>', '&lt;p&gt;'
		it '&amp;', -> test_escape '&amp;', '&amp;'
		it '?input=foo&amp;bar&key=value', -> test_escape '?input=foo&amp;bar&key=value', '?input=foo&amp;bar&key=value',

	describe 'nwmatcher', ->
		nw_doc = global.dom.createDocument()
		nw_doc.body.innerHTML = "<div><p id='pId' class='c'><span class='c'>C</span></p><input name='foo' /></div>"
		nw = require("../css/nwmatcher")
		matcher = nw.init(global, nw_doc)

		describe '.byId', ->
			it 'find DOM nodes', ->
				assert.equal matcher.byId('pId').constructor.name, "HTMLParagraphElement"

		describe '.byClass()', ->
			c = matcher.byClass('c')
			it "is an Array", -> assert.equal c.constructor.name, "Array"
			it "finds the right elements", ->
				assert.equal c.length, 2
				assert matcher.match(c[0], '.c')
				assert matcher.match(c[1], '.c')
				assert !matcher.match(c[1], 'c')

		describe '.byName()', ->
			f = matcher.byName('foo')
			it "is an Array", -> assert.equal f.constructor.name, "Array"
			it "find the right elements", -> assert.equal f.length, 1

		describe '.byTag()', ->
			s = matcher.byTag('span')
			it "is an Array", -> assert.equal s.constructor.name, "Array"
			it "finds the right elements", -> assert.equal s.length, 1

		describe '.select()', ->
			it "supports the '+' selector", ->
				x = matcher.select('p + input')
				assert.equal x.constructor.name, "Array"
				assert.equal x.length, 1
			it "supports the '*' selector", ->
				a = matcher.select('*')
				assert.equal a.constructor.name, "Array"
				assert.equal a.length, 6

describe 'window', ->
	it "should exist", ->
		assert window?
	it "should be the same as the global scope", ->
		assert window is global
	describe ".getComputedStyle()", ->
		it "should exist", ->
			assert typeof window.getComputedStyle is 'function'
		it "should return CSSStyleDeclaration", ->
			div = document.createElement('div')
			assert window.getComputedStyle(div).constructor.name is 'CSSStyleDeclaration'
		describe "CSSStyleDeclaration", ->
			div = document.createElement('div')
			style = window.getComputedStyle(div)
			it "defines the right interface", ->
				["getPropertyCSSValue","getPropertyValue","getPropertyPriority","getPropertyShorthand","isPropertyImplicit","removeProperty","setProperty"].forEach (method) ->
					assert typeof style[method] is 'function'

# vim: ft=coffee
