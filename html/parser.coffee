
# modes:
TAG = 0
ATTRNAME = 1
BEGINATTRVAL = 2
DQATTRVAL = 3
SQATTRVAL = 4
UQATTRVAL = 5
TEXT = 6
ENDTAG = 7
BEGINTAG = 8
CLOSETAG = 9

parse = (input, document, debug) ->
	i = 0
	mode = TEXT
	fragment = document.createDocumentFragment()
	cursor = fragment
	tagName = ""
	attrName = ""
	attrVal = ""
	text = ""
	attributes = {}
	emitNode = () ->
		node = document.createElement(tagName)
		for a of attributes
			node.setAttribute(a, attributes[a])
		cursor.appendChild(node)
		cursor = node
		text = ""
		tagName = ""
		attrName = ""
		attrVal = ""
		attributes = {}
		mode = TEXT
	closeNode = () ->
		cursor = cursor.parentNode
	emitAttr = () ->
		attributes[attrName] = attrVal
		attrName = ""
		attrVal = ""
		mode = TAG
	emitText = () ->
		cursor.appendChild(document.createTextNode(text))
		text = ""
	while c = input[i++]
		switch mode
			when TEXT
				if c is "<"
					mode = BEGINTAG
					if text.length > 0
						emitText()
				else
					text += c
			when BEGINTAG
				if c is "/"
					mode = CLOSETAG
				else
					tagName += c
					mode = TAG
			when TAG
				if c is " "
					mode = ATTRNAME
				else if c is "/"
					mode = ENDTAG
				else if c is ">"
					emitNode()
				else
					tagName += c
			when ATTRNAME
				if c is "="
					mode = BEGINATTRVAL
				else if c is "/"
					mode = ENDTAG
				else if c is ">"
					emitNode()
				else
					attrName += c
			when BEGINATTRVAL
				if c is '"'
					mode = DQATTRVAL
				else if c is "'"
					mode = SQATTRVAL
				else
					attrVal += c
					mode = UQATTRVAL
			when DQATTRVAL
				if c is '"'
					emitAttr()
				else
					attrVal += c
			when SQATTRVAL
				if c is "'"
					emitAttr()
				else
					attrVal += c
			when UQATTRVAL
				if c is " "
					mode = TAG
					emitAttr()
				else if c is ">"
					emitAttr()
					emitNode()
				else if c is "/"
					emitAttr()
					mode = ENDTAG
			when ENDTAG
				if c is ">"
					emitNode()
					closeNode()
			when CLOSETAG
				if c is ">"
					closeNode()
					mode = TEXT
	# if cursor isnt fragment
		# throw Error "unclosed tags in input: "+input+", cursor: "+cursor.nodeName
	return cursor

if exports
	exports.parse = parse

# vim: ft=coffee
