###
Copyright (c) 2011 Jesse Dailey <jesse.dailey@gmail.com>
License: MIT License - http://www.opensource.org/licenses/mit-license.php
###
parser = require("./html/parser")
htmlparse = parser.parse
htmlescape = parser.escape
htmlunescape = parser.unescape
matcher = require("./css/nwmatcher")

NotSupported = () ->
	throw Error "NOT_SUPPORTED"

repeat = (s, n) ->
	n = Math.max(0, n)
	switch n
		when 0 then ""
		when 1 then s
		else s + repeat(s, n-1)

extend = (o, p) ->
	o ?= {}
	for k of p
		o[k] = p[k]
	return o

class Event
	@CAPTURING_PHASE = 1
	@AT_TARGET = 2
	@BUBBLING_PHASE = 3
	constructor: () ->
		@type = null
		@target = null
		@currentTarget = null
		@eventPhase = 0
		@bubbles = false
		@cancelable = true
		@timeStamp = 0
	stopPropagation: () ->
	initEvent: (type, canBubble, cancelable) ->
		@type = type
		@bubbles = canBubble
		@cancelable = cancelable
		@timeStamp = new Date().getTime()

class MutationEvent extends Event
	@MODIFICATION = 1
	@ADDITION = 2
	@REMOVAL = 3
	constructor: () ->
		@relatedNode = null
		@prevValue = null
		@newValue = null
		@attrName = null
		@attrChange = 0
	initMutationEvent: (type, canBubble, cancelable, relatedNode, prevValue, newValue, attrName, attrChange) ->
		@type = type
		@bubbles = canBubble
		@cancelable = cancelable
		@relatedNode = relatedNode
		@prevValue = prevValue
		@newValue = newValue
		@attrName = attrName
		@attrChange = attrChange

class Node
	@ELEMENT_NODE = 1
	@ATTRIBUTE_NODE = 2
	@TEXT_NODE = 3
	@CDATA_SECTION_NODE = 4
	@ENTITY_REFERENCE_NODE = 5
	@ENTITY_NODE = 6
	@PROCESSING_INSTRUCTION_NODE = 7
	@COMMENT_NODE = 8
	@DOCUMENT_NODE = 9
	@DOCUMENT_TYPE_NODE = 10
	@DOCUMENT_FRAGMENT_NODE = 11
	@NOTATION_NODE = 12

	# DocumentPosition constants
	@DOCUMENT_POSITION_DISCONNECTED = 1
	@DOCUMENT_POSITION_PRECEDING = 2
	@DOCUMENT_POSITION_FOLLOWING = 4
	@DOCUMENT_POSITION_CONTAINS = 8
	@DOCUMENT_POSITION_CONTAINED_BY = 16
	@DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC = 32

	constructor: (name, value = null, type = 1, ownerDocument = null) ->
		@_private =
			nodeName: null
			parentNode: null
			childIndex: -1
			classes: []
		@nodeName = name
		@nodeValue = value
		@nodeType = type
		@ownerDocument = ownerDocument
		@childNodes = []
		@attributes = {}
		@listeners =
			true: {}
			false: {}

	# compareDocumentPosition: NotSupported
	# isDefaultNamespace: NotSupported
	# isEqualNode: NotSupported
	# isSupported: NotSupported
	# normalize: NotSupported
	addEventListener: (type, listener, useCapture = false) ->
		list = (@listeners[useCapture][type] ?= [])
		if not listener in list
			list.push listener
	removeEventListener: (type, listener = null, useCapture = false) ->
		list = (@listeners[useCapture][type] ?= [])
		i = list.indexOf listener
		list.splice(i,1)
	dispatchEvent: (evt) ->
		prevented = false
		stopped = false
		evt.preventDefault = () ->
			if evt.cancelable
				prevented = true
		evt.stopPropagation = () ->
			stopped = true
		evt.target = @
		# compute the chain of capturing nodes
		evt.eventPhase = Event.CAPTURING_PHASE
		chain = [@]
		while chain[0].parentNode isnt @ownerDocument
			chain.unshift chain[0].parentNode
		chain.unshift @ownerDocument
		# CAPTURING_PHASE
		for ancestor in chain
			evt.currentTarget = ancestor
			list = ancestor.listeners[true][evt.type]
			handler(evt) for handler in list if list
			break if stopped

		# AT_TARGET
		evt.eventPhase = Event.AT_TARGET
		evt.currentTarget = evt.target
		# fire both capturing and non-capturing handlers
		list = @listeners[true][evt.type]
		handler(evt) for handler in list if list
		list = @listeners[false][evt.type]
		handler(evt) for handler in list if list

		# BUBBLING_PHASE
		if evt.bubbles
			for ancestor in chain.reverse()
				evt.currentTarget = ancestor
				list = ancestor.listeners[false][evt.type]
				handler(evt) for handler in list if list
	cloneNode: (deep = false) ->
		ret = new Node(@nodeName, @nodeValue, @nodeType, @ownerDocument)
		for a of @attributes
			ret.attributes[a] = @attributes[a]
		if deep
			for c in @childNodes
				ret.childNodes.push c.cloneNode(true)
	hasAttributes: () ->
		for a of @attributes
			return true
		return false
	isSameNode: (node) ->
		node is @
	hasChildNodes: () ->
		@childNodes.length > 0
	insertBefore: (newNode, refNode) ->
		if not refNode?
			return @appendChild(newNode)
		if refNode.parentNode isnt @
			throw Error "Cannot insertBefore a non-child."
		if newNode.nodeType is Node.DOCUMENT_FRAGMENT_NODE
			# could be optimized to be a single splice
			for c in newNode.childNodes
				@insertBefore(c, refNode)
		else
			i = refNode._private.childIndex
			if i > -1
				@childNodes.splice(i, 0, newNode)
				newNode._private.childIndex = i
				newNode._private.parentNode = @
				refNode._private.childIndex = i + 1
				i = 0
				for c in @childNodes
					c._private.childIndex = i++
		newNode
	appendChild: (node) ->
		if node == null
			return
		if node.nodeType is Node.DOCUMENT_FRAGMENT_NODE
			# TODO: could be optimized to do a single splice, if that was found to matter
			for c in node.childNodes
				@appendChild(c)
		else
			node._private.parentNode = @
			node._private.childIndex = @childNodes.length
			@childNodes.push node
	removeChild: (node) ->
		i = node._private.childIndex
		if i > -1 and node.parentNode is @
			node._private.parentNode = null
			node._private.childIndex = -1
			@childNodes.splice(i, 1)
			# re-index all the children
			i = 0
			for c in @childNodes # TODO: this could probably be done with more precision
				c._private.childIndex = i++
		else
			throw Error "Cannot removeChild a non-child."
		node
	replaceChild: (newNode, oldNode) ->
		if oldNode.parentNode isnt @
			throw Error "Cannot replaceChild a non-child."
		i = oldNode._private.childIndex
		if i < 0
			throw Error "DOM tree corruption, childIndex is < 0"
		if newNode.nodeType is Node.DOCUMENT_FRAGMENT_NODE
			# TODO: could be optimized to do a single splice
			for c in @childNodes
				@insertBefore(c, oldNode)
			return @removeChild(oldNode)
		newNode._private.parentNode = @
		newNode._private.childIndex = i
		oldNode.parentNode = null
		oldNode._private.childIndex = -1
		@childNodes.splice(i, 1, newNode)
	toString: (pretty=false,deep=true,indentLevel=0) ->
		# console.log("Node::toString[#{@nodeName}] from #{@nodeValue}")
		if pretty
			indent = repeat("  ", indentLevel)
			newline = "\n"
		else
			indent = ""
			newline = ""
		switch @nodeType
			when Node.TEXT_NODE
				"#{indent}#{@nodeValue}" + newline
			when Node.ELEMENT_NODE
				Element::toString.call @, pretty, deep, indentLevel
			when Node.ATTRIBUTE_NODE
				"#{indent}#{@nodeName}=\"#{@nodeValue}\""
			when Node.CDATA_SECTION_NODE
				"#{indent}<![CDATA[#{@nodeValue}]]>" + newline
			when Node.COMMENT_NODE
				"#{indent}<!-- #{@nodeValue} -->" + newline
			when Node.DOCUMENT_TYPE_NODE
				"#{indent}<!DOCTYPE #{@nodeValue}>" + newline
			when Node.DOCUMENT_NODE
				Element::toString.call @, pretty, deep, indentLevel
			when Node.DOCUMENT_FRAGMENT_NODE
				NotSupported() # TODO

Node::__defineGetter__ 'nodeName', () -> @_private.nodeName
Node::__defineSetter__ 'nodeName', (v) -> @_private.nodeName = v?.toUpperCase()
Node::__defineGetter__ 'previousSibling', () -> @parentNode?.childNodes[@_private.childIndex-1]
Node::__defineSetter__ 'nextSibling', () -> @parentNode?.childNodes[@_private.childIndex+1]
Node::__defineGetter__ 'parentNode', () -> @_private.parentNode
Node::__defineSetter__ 'parentNode', (v) ->
	if v isnt null
		throw Error "Must use one of appendChild, insertBefore, etc. to give a Node a new parent."
	@_private.parentNode?.removeChild @
	@_private.parentNode = null
	@_private.childIndex = -1
Node::__defineGetter__ 'firstChild', () -> @childNodes[0]
Node::__defineGetter__ 'lastChild', () -> @childNodes[-1]
Node::__defineGetter__ 'id', () -> @attributes['id']
Node::__defineSetter__ 'id', (value) ->
	o = @ownerDocument?
	if o
		if @attributes.id?
			delete @ownerDocument._private.idMap[@attributes.id]
	if value in [null, undefined, "undefined"]
		delete @attributes.id
	else
		if o
			@ownerDocument._private.idMap[value] = @
		@attributes.id = value
Node::__defineGetter__ 'className', () -> @attributes['class']
Node::__defineSetter__ 'className', (value) ->
	if value in [null, undefined, "undefined"]
		delete @attributes.class
		@_private.classes.length = 0
	else
		@attributes['class'] = value
		# Optimization for getElementsByClassName, cache the split form
		@_private.classes = value.split(' ')

class Element extends Node
	@Map = { # map tag names to classes, for use in .createElement
		_: class HTMLElement extends Element
			constructor: (a...) ->
				super a...
		a: class HTMLAnchorElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "A"
				super a...
		area: class HTMLAreaElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "AREA"
				super a...
		audio: class HTMLAudioElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "AUDIO"
				super a...
		base: class HTMLBaseElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "BASE"
				super a...
		blockquote: class HTMLBlockquoteElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "BLOCKQUOTE"
				super a...
		body: class HTMLBodyElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "BODY"
				super a...
		br: class HTMLBRElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "BR"
				super a...
		button: class HTMLButtonElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "BUTTON"
				super a...
		canvas: class HTMLCanvasElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "CANVAS"
				super a...
		caption: class HTMLTableCaptionElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "CAPTION"
				super a...
		col: class HTMLTableColElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "COL"
				super a...
		colgroup: class HTMLTableColElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "COLGROUP"
				super a...
		del: class HTMLDelElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "DEL"
				super a...
		details: class HTMLDetailsElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "DETAILS"
				super a...
		div: class HTMLDivElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "DIV"
				super a...
		dl: class HTMLDListElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "DL"
				super a...
		embed: class HTMLEmbedElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "EMBED"
				super a...
		fieldSet: class HTMLFieldSetElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "FIELDSET"
				super a...
		form: class HTMLFormElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "FORM"
				super a...
		h1: class HTMLHeadingElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "H1"
				super a...
		h2: class HTMLHeading2Element extends HTMLHeadingElement
			constructor: (a...) ->
				a[0] = "H1"
				super a...
		h3: class HTMLHeading3Element extends HTMLHeadingElement
			constructor: (a...) ->
				a[0] = "H1"
				super a...
		h4: class HTMLHeading4Element extends HTMLHeadingElement
			constructor: (a...) ->
				a[0] = "H1"
				super a...
		h5: class HTMLHeading5Element extends HTMLHeadingElement
			constructor: (a...) ->
				a[0] = "H1"
				super a...
		h6: class HTMLHeading6Element extends HTMLHeadingElement
			constructor: (a...) ->
				a[0] = "H6"
				super a...
		head: class HTMLHeadElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "HEAD"
				super a...
		hr: class HTMLHRElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "HR"
				super a...
		html: class HTMLHtmlElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "HTML"
				super a...
		iframe: class HTMLIFrameElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "IFRAME"
				super a...
		image: class HTMLImageElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "IMAGE"
				super a...
		input: class HTMLInputElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "INPUT"
				super a...
		ins: class HTMLInsElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "INS"
				super a...
		keygen: class HTMLKeygenElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "KEYGEN"
				super a...
		label: class HTMLLabelElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "LABEL"
				super a...
		legend: class HTMLLegendElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "LEGEND"
				super a...
		li: class HTMLLIElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "LI"
				super a...
		link: class HTMLLinkElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "LINK"
				super a...
		map: class HTMLMapElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "MAP"
				super a...
		menu: class HTMLMenuElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "MENU"
				super a...
		meta: class HTMLMetaElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "META"
				super a...
		meter: class HTMLMeterElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "METER"
				super a...
		object: class HTMLObjectElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "OBJECT"
				super a...
		ol: class HTMLOListElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "OL"
				super a...
		optgroup: class HTMLOptGroupElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "OPTGROUP"
				super a...
		option: class HTMLOptionElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "OPTION"
				super a...
		output: class HTMLOutputElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "OUTPUT"
				super a...
		p: class HTMLParagraphElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "P"
				super a...
		param: class HTMLParamElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "PARAM"
				super a...
		pre: class HTMLPreElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "PRE"
				super a...
		progress: class HTMLProgressElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "PROGRESS"
				super a...
		quote: class HTMLQuoteElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "QUOTE"
				super a...
		script: class HTMLScriptElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "SCRIPT"
				super a...
		select: class HTMLSelectElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "SELECT"
				super a...
		source: class HTMLSourceElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "SOURCE"
				super a...
		style: class HTMLStyleElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "STYLE"
				super a...
		table: class HTMLTableElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TABLE"
				super a...
		thead: class HTMLTableHeadElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "THEAD"
				super a...
		tbody: class HTMLTableBodyElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TBODY"
				super a...
		tfoot: class HTMLTableFootElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TFOOT"
				super a...
		td: class HTMLTableCellElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TD"
				super a...
		th: class HTMLTableHeadElement extends HTMLTableCellElement
			constructor: (a...) ->
				a[0] = "TH"
				super a...
		tr: class HTMLTableRowElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TR"
				super a...
		textarea: class HTMLTextAreaElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TEXTAREA"
				super a...
		title: class HTMLTitleElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "TITLE"
				super a...
		ul: class HTMLUListElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "UL"
				super a...
		video: class HTMLVideoElement extends HTMLElement
			constructor: (a...) ->
				a[0] = "VIDEO"
				super a...
	}
	constructor: (a...) ->
		a[2] ?= Node.ELEMENT_NODE
		super a...
		@style = {}
	getElementsByClassName: (name) ->
		ret = []
		for c in @childNodes
			if c.nodeType is Node.ELEMENT_NODE
				if name is "*" or name in c._private.classes
					ret.push c
				for i in c.getElementsByClassName(name)
					ret.push i
		return ret
	getElementsByTagName: (name) ->
		ret = []
		uname = name.toUpperCase()
		for c in @childNodes
			if c.nodeType is Node.ELEMENT_NODE
				if uname in ["*", c.tagName]
					ret.push c
				for i in c.getElementsByTagName(uname)
					ret.push i
		return ret
	# attributes
	getAttribute: (name) ->
		@attributes[name] ? ""
	getAttributeNode: (name) ->
		n = new Attr(name, @getAttribute(name))
		n.ownerElement = @
		n.ownerDocument = @.ownerDocument
		n
	hasAttribute: (name) ->
		name of @attributes
	setAttribute: (name, value) ->
		if value == null
			@removeAttribute(name)
		switch name
			when "class"
				@className = value
			when "id"
				@id = value
			else
				@attributes[name] = value
	removeAttribute: (name) ->
		delete @attributes[name]
		switch name
			when "class"
				@_private.classes = []
			when "id"
				delete @ownerDocument?._private.idMap[@id]
	# selectors
	matchesSelector: (selector) ->
		@ownerDocument?._private.matcher.match(@, selector)
	querySelector: (selector) ->
		@ownerDocument?._private.matcher.select(selector, @)[0]
	querySelectorAll: (selector) ->
		@ownerDocument?._private.matcher.select(selector, @)
	# scrolling
	# scrollByLines: NotSupported
	# scrollByPages: NotSupported
	# scrollIntoView: NotSupported
	# scrollIntoViewIfNeeded: NotSupported
	# size and position
	# getBoundingClientRect: NotSupported
	# getClientRects: NotSupported
	# focus
	# focus: NotSupported
	# blur: NotSupported
	# render
	toString: (pretty=false, deep=true, indentLevel = 0) ->
		try
			name = @nodeName?.toLowerCase()
		catch err
			console.log @
			throw err
		if pretty and deep
			indent = repeat("  ", indentLevel)
			newline = "\n"
		else
			indent = ""
			newline = ""
		attrs = (" #{a}=\"#{@attributes[a]}\"" for a of @attributes).join('')
		len = @childNodes.length
		end = ""
		if len is 0
			end = "/"
		ret = [indent + "<#{name}#{attrs}#{end}>" + newline]
		r = 1
		if deep
			for c in @childNodes
				ret[r++] = c.toString pretty, deep, indentLevel + 1
		else if len > 0
			ret[r++] = indent + "...#{len} children..." + newline
		if len > 0
			ret[r++] = indent + "</#{name}>" + newline
		ret.join('')

Element::__defineGetter__ 'tagName', () -> @nodeName
Element::__defineGetter__ 'innerHTML', () ->
	h = []
	for c in @childNodes
		h.push c.toString()
	return h.join('')
Element::__defineSetter__ 'innerHTML', (v) ->
	fragment = htmlparse(v, @ownerDocument)
	for c in @childNodes
		c._private.parentNode = null
		c._private.childIndex = -1
	@childNodes.length = 0
	@appendChild fragment

getAllTextNodes = () ->
	t = []
	for c in @childNodes
		if c.nodeType in [Node.TEXT_NODE, Node.CDATA_SECTION_NODE]
			t.push c.toString(false, false)
		else if c.nodeType isnt Node.COMMENT_NODE
			t.push getAllTextNodes(c)
	return t.join ''
Element::__defineGetter__ 'innerText', getAllTextNodes
Element::__defineGetter__ 'textContent', getAllTextNodes

class Attr extends Node
	constructor: (name, value) ->
		super name, value, Node.ATTRIBUTE_NODE, null
		@name = @nodeName
		@value = @nodeValue
		@ownerElement = null

class CData extends Node
	constructor: (value, owner) ->
		super "#cdata", value, Node.CDATA_SECTION_NODE, owner

class Comment extends Node
	constructor: (value, owner) ->
		super "#comment", value, Node.COMMENT_NODE, owner

class Text extends Node
	constructor: (value, owner) ->
		super "#text", value, Node.TEXT_NODE, owner
Text::__defineSetter__ 'data', (v) -> @nodeValue = htmlescape(v)

class DocumentFragment extends Node
	constructor: (owner) ->
		super "#document-fragment", null, Node.DOCUMENT_FRAGMENT_NODE, owner
	toString: (pretty=false, deep=true) ->
		ret = []; r = 0
		for c in @childNodes
			ret[r++] = c.toString pretty, deep
		return ret.join('')

DocumentFragment::__defineSetter__ 'parentNode', (v) ->
	throw Error "DocumentFragment cannot have a parentNode"

class Document extends Element
	constructor: (a...) ->
		a[0] ?= "#document"
		a[2] = Node.DOCUMENT_NODE
		super a...
		@documentElement = @
		@documentURI = null
		@_private = extend @_private, {
			idMap: {}
		}
	createCDATASection: (value) ->
		new CData(value, @)
	createComment: (value) ->
		new Comment(value, @)
	createDocumentFragment: () ->
		new DocumentFragment(@)
	createElement: (name) ->
		nodeClass = Element.Map[name?.toLowerCase()]
		if not nodeClass?
			new Element.Map['_'](name.toUpperCase())
		else
			new nodeClass(null,null,null,@)
	# createEntityReference: NotSupported
	createEvent: (type) ->
		switch type
			when "MutationEvents"
				new MutationEvent()
			else
				new Event()
	createTextNode: (text) ->
		new Text(text, @)
	getElementById: (id) ->
		@_private.idMap[id]

class HTMLDocument extends Document
	constructor: () ->
		super "HTML", null, Node.DOCUMENT_NODE, @
		Document::appendChild.call @,@createElement('head')
		Document::appendChild.call @,@createElement('body')
		@head = @childNodes[0]
		@body = @childNodes[1]
		@_private = extend @_private, {
			matcher: matcher.init(global, @)
		}
	# over-ride the child manipulators, you can't touch .head or .body
	hasChildNodes: () -> true
	insertBefore: NotSupported
	appendChild: NotSupported
	removeChild: NotSupported
	replaceChild: NotSupported
	# what is all this crap? HTMLDocument has it in Chrome...
	# captureEvents: NotSupported
	# clear: NotSupported
	# close: NotSupported
	# hasFocus: NotSupported
	# open: NotSupported
	# releaseEvents: NotSupported
	# should support these but we don't have an html parser...
	write: NotSupported
	writeln: NotSupported

exports.createDocument = () ->
	new HTMLDocument()

exports.registerGlobals = (g) ->
	g.Element = Element
	g.Node = Node
	g.Document = Document
	g.DocumentFragment = DocumentFragment
	g.NodeList = Array # HACK: for now...
	g.Event = {} # HACK

# vim: ft=coffee
