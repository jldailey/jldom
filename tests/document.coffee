require "./common"

testSelector = (s, output) ->
	x = document.querySelectorAll(s)
	assertEqual x.toString(), output, s


TestGroup 'document', {
	exists: () -> assert(document?, "document should exist")
	head1: () -> assert(document.head?, "document.head should exist")
	body1: () -> assert(document.body?, "document.body should exist")
	type: () -> assertEqual(document.nodeType, 9, "document.nodeType")
	createElement1: () -> assertEqual(document.createElement('div').nodeType, 1)
	createElement2: () -> assertEqual(document.createElement('div').nodeName, "DIV")
	createElement3: () -> assert(document.createElement('div').style)
	appendChild: () ->
		document.body.appendChild(document.createElement('div'))
		document.body.appendChild(document.createElement('div'))
		assertEqual document.body.childNodes.length, 2
	nodesByTagName: () ->
		document.body.appendChild(document.createElement('div'))
		assert document.body.getElementsByTagName('DIV').length > 1
	attribute_dict: () ->
		div = document.createElement("div")
		div.id = "testId"
		assertEqual(div.attributes['id'], div.id)
	attribute_get_set: () ->
		div = document.createElement("div")
		div.setAttribute("name", "foo")
		assertEqual div.getAttribute("name"), "foo", "div.getAttribute('foo')"
	attribute_has1: () ->
		div = document.createElement("div")
		div.setAttribute("name", "foo")
		assertEqual div.hasAttribute("name"), true, "div.hasAttribute"
	attribute_has2: () ->
		div = document.createElement("div")
		div.setAttribute("name", "")
		assertEqual div.hasAttribute("name"), true, "div.hasAttribute"
	attribute_node: () ->
		div = document.createElement("div")
		div.setAttribute("name", "foo")
		attr = div.getAttributeNode("name")
		assertEqual attr.value, "foo", "attr.value"
		assertEqual attr.nodeValue, "foo", "attr.nodeValue"
	getElementById: () ->
		div = document.createElement("div")
		div.id = "getElemId"
		document.body.appendChild(div)
		assertEqual document.getElementById("getElemId"), div, "nodeById"
	subChildren: () ->
		div = document.createElement("div")
		div.id = "subChildren_parent"
		document.body.appendChild(div)
		span = document.createElement("span")
		div.appendChild(span)
		assertEqual div.childNodes.length, 1, "div.childNodes.length"
		nodesByTagName = div.getElementsByTagName("span")
		assertEqual nodesByTagName.length, 1, "nodesByTagName"
		assertEqual nodesByTagName[0], span, "nodesByTagName[0]"
	getElementsByClassName: () ->
		div = document.createElement("div")
		div.id = "getElemClass_parent"
		document.body.appendChild(div)
		p = document.createElement("p")
		p.id = 'classTest'
		p.className = "alpha beta"
		div.appendChild(p)
		alphaNodes = div.getElementsByClassName("alpha")
		betaNodes = div.getElementsByClassName("beta")
		assertEqual alphaNodes.length, 1, "alphaNodes.length"
		assertEqual betaNodes.length, 1, "betaNodes.length"
		assertEqual alphaNodes[0], p, "alphaNodes[0]"
		assertEqual betaNodes[0], p, "betaNodes[0]"
	fragment: () ->
		fragment_doc = global.dom.createDocument()
		fragment = fragment_doc.createDocumentFragment()
		fragment.appendChild(fragment_doc.createElement("div"))
		fragment.appendChild(fragment_doc.createElement("p"))
		assertEqual fragment.childNodes.length, 2, "fragment.childNodes.length"
		assertEqual fragment.toString(), "<div/><p/>", "fragment.toString()"
		div = fragment_doc.createElement("div")
		div.id = "fragment_test"
		fragment_doc.body.appendChild(div)
		div.appendChild(fragment)
		assertEqual fragment_doc.toString(), '<html><head/><body><div id="fragment_test"><div/><p/></div></body></html>'
	text_nodeValue: () ->
		text = document.createTextNode("Harro!")
		assertEqual(text.nodeValue, "Harro!", "text.nodeValue")
	text_data_plain: () ->
		text = document.createTextNode("Harro!")
		text.data = "BB"
		assertEqual(text.nodeValue, "BB", "text.nodeValue")
	text_data_html: () ->
		text = document.createTextNode("Harro!")
		text.data = "<p>"
		assertEqual(text.nodeValue, "&lt;p&gt;", "text.nodeValue")
	text_appendChild: () ->
		text = document.createTextNode("Harro!")
		text.data = "<p>"
		div = document.createElement("div")
		div.appendChild(text)
		assertEqual(div.innerHTML, "&lt;p&gt;")
		text.data = "Goodbye!"
		assertEqual(div.innerHTML, "Goodbye!")
	text_appendChild_multiple: () ->
		text = document.createTextNode("&nbsp;")
		div = document.createElement("div")
		# first put some simple text in a div
		div.appendChild(text)
		# and confirm we see it properly via the innerHTML/Text getters
		assertEqual(div.innerHTML, "&nbsp;")
		assertEqual(div.innerText, "&nbsp;")
		# then create a span with some more text
		span = document.createElement("span")
		text2 = document.createTextNode("hello")
		span.appendChild(text2)
		assertEqual(span.innerText, "hello")
		# and insert it along side the existing text
		div.appendChild(span)
		# and confirm that the innerText getter puts the two together
		assertEqual(div.innerText, "&nbsp;hello")
	input_value: () ->
		input = document.createElement("input")
		input.value = 'bar'
		input.setAttribute('value', 'foo')
		assertEqual input.value, 'foo', 'input.value'
		assertEqual input.value, input.getAttribute('value'), 'input.getAttribute("value")'
	input_select: () ->
		select = document.createElement("select")
		optionA = document.createElement("option")
		optionB = document.createElement("option")
		assertEqual optionA.constructor.name, "HTMLOptionElement"
		assertEqual optionA.constructor.__super__.constructor.name, "HTMLInputElement"
		optionA.value = '1'
		optionA.innerText = 'A'
		optionB.innerText = 'B'
		assertEqual optionA.value, '1', 'optionA.value'
		assertEqual optionB.value, 'B', 'optionB.value'
		select.appendChild(optionA)
		select.appendChild(optionB)
		assertEqual select.selectedIndex, 0, 'select.selectedIndex'
		assertEqual select.value, '1', 'select.value'
		select.selectedIndex = 1
		assertEqual select.selectedIndex, 1, 'select.selectedIndex * 2'
		assertEqual select.value, 'B', 'select.value'
	input_radio: () ->
		test_doc = global.dom.createDocument()
		test_doc.body.innerHTML = "<input type='radio' selected>"
		input = test_doc.body.childNodes[0]
		assertEqual input.constructor.name, "HTMLInputElement"
		assertEqual input.hasAttribute('selected'), true, 'input.hasAttr'
		assertEqual input.getAttribute('selected'), ''
		assertEqual input.selected, true, 'input.selected'
		input.removeAttribute('selected')
		assertEqual input.selected, false, 'input.selected'
		assertEqual input.value, "on"
	input_checkbox: () ->
		test_doc = global.dom.createDocument()
		test_doc.body.innerHTML = "<input type='checkbox' checked >"
		input = test_doc.body.childNodes[0]
		assertEqual input.checked, true, 'input.checked'
		assertEqual input.value, "on"
	comment: () ->
		comment_doc = global.dom.createDocument()
		comment = comment_doc.createComment("comment text")
		assertEqual comment.nodeValue, "comment text"
		comment_doc.body.appendChild(comment)
		assertEqual comment_doc.body.toString(), '<body><!--comment text--></body>'
	conditional: () ->
		doc = global.dom.createDocument()
		comment = doc.createCComment("if lt IE 9")
		script = doc.createElement('script')
		script.setAttribute('src', 'ie.js')
		comment.appendChild script
		doc.body.appendChild(comment)
		assertEqual doc.body.toString(), '<body><!--[if lt IE 9]><script src="ie.js"/><![endif]--></body>'
	selector_id: () ->
		testSelector "p#classTest", '<p id="classTest" class="alpha beta"/>'
	selector_class: () ->
		testSelector "p.alpha.beta", '<p id="classTest" class="alpha beta"/>'
	selector_tag: () ->
		testSelector "p", '<p id="classTest" class="alpha beta"/>'
	selector_star: () ->
		testSelector "div *", '<span/>,<p id="classTest" class="alpha beta"/>'
}

TestReport()

# vim: ft=coffee
