assert = require 'assert'
dom = require "../dom"
dom.registerGlobals global
global.dom = dom
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

###
# vim: ft=coffee
	require "./common"
	html = require('../html/parser')

	test_parse = (input, output, debug = false) ->
		try
			result = html.parse(input, document, debug).toString(false, true)
			output ?= input
		catch err
			err.message = "Failed to Parse: #{input}, Error: #{err.message}"
			throw err
		if result isnt output
			throw Error result+" !== "+output

	test_escape = (input, output) ->
		result = html.escape(input)
		if result isnt output
			throw Error result+" !== "+output

	TestGroup 'parse', {
		div: () -> test_parse "<div/>"
		div_text1: () -> test_parse "<div>Harro?</div>"
		div_text2: () -> test_parse "<div>foo</div>", "<div>foo</div>"
		div_text3: () -> test_parse '<div>1,2</div>', '<div>1,2</div>'
		div_p_text: () -> test_parse "<div><p>Hi.</p></div>"
		div_p_span_text: () -> test_parse "<div><p><span>Bye.</span></p></div>"
		div_closed: () -> test_parse "<div />", "<div/>"
		div_p_closed: () -> test_parse "<div><p/></div>","<div><p/></div>"
		div_p_closed2: () -> test_parse "<div><p /></div>","<div><p/></div>"
		div_p_closed3: () -> test_parse "<div><p  /></div>","<div><p/></div>"
		div_attr1: () -> test_parse "<div key='val'></div>", '<div key="val"/>'
		div_attr2: () -> test_parse "<div key='val' ></div>", '<div key="val"/>'
		div_attr3: () -> test_parse "<div key='val'/>", '<div key="val"/>'
		div_attr4: () -> test_parse "<div key='val' />", '<div key="val"/>'
		div_attr5: () -> test_parse '<div id="test_parse"></div>', '<div id="test_parse"/>'
		div_attr_empty: () -> test_parse '<input checked/>'
		text_complex: () -> test_parse '<eval>CurrencyFormat(Application.User.balance)</eval>'
		p: () -> test_parse '<p>','<p/>'
		text_bare: () -> test_parse 'text', 'text' # parsing lone text as text nodes
		comment: () -> test_parse '<body><!-- comment --><span>foo</span></body>'
		text_broken: () -> test_parse '<a>Hello<b>World</b></a>'
		meta1: () -> test_parse '<head><meta charset="utf-8"><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
		meta2: () -> test_parse '<head><meta charset="utf-8"/><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
		meta3: () -> test_parse '<head><meta charset="utf-8"></meta><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
	}

	TestGroup 'escape', {
		p: () -> test_escape '<p>', '&lt;p&gt;'
		amp: () -> test_escape '&amp;', '&amp;'
		mixed: () -> test_escape '?input=foo&amp;bar&key=value', '?input=foo&amp;bar&key=value',
	}

	TestReport()

# vim: ft=coffee
	require "./common"

	nw_doc = global.dom.createDocument()
	nw_doc.body.innerHTML = "<div><p id='pId' class='c'><span class='c'>C</span></p><input name='foo' /></div>"

	nw = require("../css/nwmatcher")
	matcher = nw.init(global, nw_doc)

	TestGroup 'nwmatcher', {
		id: () -> assert.equal matcher.byId('pId').constructor.name, "HTMLParagraphElement"
		class: () ->
			c = matcher.byClass('c')
			assert.equal c.constructor.name, "Array"
			assert.equal c.length, 2
			assert matcher.match(c[0], '.c')
			assert matcher.match(c[1], '.c')
			assert !matcher.match(c[1], 'c')
		name: () ->
			f = matcher.byName('foo')
			assert.equal f.constructor.name, "Array"
			assert.equal f.length, 1
		tag: () ->
			s = matcher.byTag('span')
			assert.equal s.constructor.name, "Array"
			assert.equal s.length, 1
		sibling: () ->
			x = matcher.select('p + input')
			assert.equal x.constructor.name, "Array"
			assert.equal x.length, 1
		star: () ->
			a = matcher.select('*')
			assert.equal a.constructor.name, "Array"
			assert.equal a.length, 6
	}

	TestReport()

			
###
# vim: ft=coffee
