clear = (a) -> a.length = 0
get = (a) -> a.join("")
parse = (input, document, debug) ->
	i = 0
	mode = 0
	fragment = document.createDocumentFragment()
	cursor = fragment
	tagName = []
	attrName = []
	attrVal = []
	text = []
	attributes = {}
	emitNode = () ->
		node = document.createElement(get(tagName))
		for a of attributes
			node.setAttribute(a, attributes[a])
		cursor.appendChild(node)
		cursor = node
		clear(text)
		clear(tagName)
		clear(attrName)
		clear(attrVal)
		for a of attributes
			delete attributes[a]
		mode = 0
	closeNode = () -> cursor = cursor.parentNode
	emitAttr = () ->
		attributes[get(attrName)] = get(attrVal)
		clear(attrName)
		clear(attrVal)
		mode = 2
	emitText = () ->
		if text.length > 0
			cursor.appendChild(document.createTextNode(get(text)))
			clear(text)
	states = [
			"<": [emitText, 1]
			"": [text, 0]
		,
			"/": [9]
			"": [tagName, 2]
		,
			" ": [3]
			"/": [8]
			">": [emitNode]
			"": [tagName]
		,
			"=": [4]
			"/": [8]
			">": [emitNode]
			"": [attrName]
		,
			'"': [5]
			"'": [6]
			"": [attrVal, 7]
		,
			'"': [emitAttr]
			"": [attrVal]
		,
			"'": [emitAttr]
			"": [attrVal]
		,
			" ": [emitAttr, 2]
			">": [emitAttr, emitNode]
			"/": [emitAttr, 8]
		,
			">": [emitNode, closeNode]
		,
			">": [closeNode, 0]
	]
	while c = input[i++]
		m = states[mode]
		result = m[c] or m[""] or []
		for x in result
			if x.call
				x()
			else if /^\d/.test x
				mode = x
			else if x.push
				x.push c
	return cursor

if exports
	exports.parse = parse

# vim: ft=coffee
