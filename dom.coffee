
NotSupported = () ->
	throw Error "NOT_SUPPORTED"

String::times = (n) ->
	switch n
		when 0 then ""
		when 1 then @
		else @ + @.times(n-1)

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
	# NodeType constants
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
		@_private = {
			parentNode: null
			childIndex: -1
		}
		@nodeName = name
		@nodeValue = value
		@nodeType = type
		@ownerDocument = ownerDocument
		@childNodes = []
		@attributes = {}
		@__defineGetter__ 'previousSibling', () -> @parentNode?.childNodes[@_private.childIndex-1]
		@__defineSetter__ 'nextSibling', () -> @parentNode?.childNodes[@_private.childIndex+1]
		@__defineGetter__ 'parentNode', () => @_private.parentNode
		@__defineSetter__ 'parentNode', (v) =>
			if v isnt null
				throw Error "Must use one of appendChild, insertBefore, etc. to give a Node a new parent."
			@_private.parentNode?.removeChild @
			@_private.parentNode = null
			@_private.childIndex = -1
		@__defineGetter__ 'firstChild', () => @childNodes[0]
		@__defineGetter__ 'lastChild', () => @childNodes[-1]
		@__defineGetter__ 'id', () => @attributes['id']
		@__defineSetter__ 'id', (value) =>
			if @ownerDocument?
				if @attributes.id?
					delete @ownerDocument._private.idMap[@attributes.id]
				@ownerDocument._private.idMap[value] = @
			@attributes.id = value
		@__defineGetter__ 'className', () => @attributes['class']
		@__defineSetter__ 'className', (value) =>
			### getElementsByClassName optimization for the future
			if @ownerDocument? # un-map old class values
				for cls in (@attributes['class'] ? "").split(/ +/)
					a = (@ownerDocument._private.classMap[cls] ?= [])
					i = a.indexOf @
					if i > -1
						a.splice(i, 1)
				# map the new class values
				for cls in value.split(/ +/)
					(@ownerDocument._private.classMap[cls] ?= []).push(@)
			###
			@attributes['class'] = value

		@listeners = {
			true: {}
			false: {}
		}
	compareDocumentPosition: NotSupported
	isDefaultNamespace: NotSupported
	isEqualNode: NotSupported
	isSupported: NotSupported
	normalize: NotSupported
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
		if refNode.parentNode isnt @
			throw Error "Cannot insertBefore a non-child."
		i = refNode._private.childIndex
		if i > -1
			@childNodes.splice(i, 0, newNode)
			newNode._private.childIndex = i
			refNode._private.childIndex = i + 1
	appendChild: (node) ->
		node._private.parentNode = @
		node._private.childIndex = @childNodes.length
		@childNodes.push node
	removeChild: (node) ->
		if node.parentNode isnt @
			throw Error "Cannot removeChild a non-child."
		i = node._private.childIndex
		if i > -1
			node.parentNode = null
			@childNodes.splice(i, 1)
	replaceChild: (newNode, oldNode) ->
		if oldNode.parentNode isnt @
			throw Error "Cannot replaceChild a non-child."
		i = oldNode._private.childIndex
		if i > -1
			newNode._private.parentNode = @
			newNode._private.childIndex = i
			oldNode.parentNode = null
			@childNodes.splice(i, 1, newNode)
	toString: () ->
		switch @nodeType
			when Node.TEXT_NODE
				"#text:#{@nodeValue}"
			when Node.ELEMENT_NODE
				Element::toString.apply(@)
			when Node.ATTRIBUTE_NODE
				"#{@nodeName}=\"#{@nodeValue}\""
			when Node.CDATA_SECTION_NODE
				"<![CDATA[#{@nodeValue}]]>"
			when Node.COMMENT_NODE
				"<!-- #{@nodeValue} -->"
			when Node.DOCUMENT_TYPE_NODE
				"<!DOCTYPE #{@nodeValue}>"
			when Node.DOCUMENT_NODE
				Element::toString.apply(@)
			when Node.DOCUMENT_FRAGMENT_NODE
				NotSupported() # TODO

class Element extends Node
	@Map = {
		_: class HTMLElement extends Element
			constructor: (a...) ->
				super a...
		a: class HTMLAnchorElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "A"
		area: class HTMLAreaElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "AREA"
		audio: class HTMLAudioElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "AUDIO"
		base: class HTMLBaseElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "BASE"
		blockquote: class HTMLBlockquoteElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "BLOCKQUOTE"
		body: class HTMLBodyElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "BODY"
		br: class HTMLBRElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "BR"
		button: class HTMLButtonElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "BUTTON"
		canvas: class HTMLCanvasElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "CANVAS"
		caption: class HTMLTableCaptionElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "CAPTION"
		col: class HTMLTableColElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "COL"
		colgroup: class HTMLTableColElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "COLGROUP"
		del: class HTMLDelElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "DEL"
		details: class HTMLDetailsElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "DETAILS"
		div: class HTMLDivElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "DIV"
		dl: class HTMLDListElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "DL"
		embed: class HTMLEmbedElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "EMBED"
		fieldSet: class HTMLFieldSetElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "FIELDSET"
		form: class HTMLFormElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "FORM"
		h1: class HTMLHeadingElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "H1"
		h2: class HTMLHeading2Element extends HTMLHeadingElement
			constructor: (a...) ->
				super a...
				@nodeName = "H1"
		h3: class HTMLHeading3Element extends HTMLHeadingElement
			constructor: (a...) ->
				super a...
				@nodeName = "H1"
		h4: class HTMLHeading4Element extends HTMLHeadingElement
			constructor: (a...) ->
				super a...
				@nodeName = "H1"
		h5: class HTMLHeading5Element extends HTMLHeadingElement
			constructor: (a...) ->
				super a...
				@nodeName = "H1"
		h6: class HTMLHeading6Element extends HTMLHeadingElement
			constructor: (a...) ->
				super a...
				@nodeName = "H6"
		head: class HTMLHeadElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "HEAD"
		hr: class HTMLHRElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "HR"
		html: class HTMLHtmlElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "HTML"
		iframe: class HTMLIFrameElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "IFRAME"
		image: class HTMLImageElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "IMAGE"
		input: class HTMLInputElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "INPUT"
		ins: class HTMLInsElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "INS"
		keygen: class HTMLKeygenElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "KEYGEN"
		label: class HTMLLabelElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "LABEL"
		legend: class HTMLLegendElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "LEGEND"
		li: class HTMLLIElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "LI"
		link: class HTMLLinkElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "LINK"
		map: class HTMLMapElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "MAP"
		menu: class HTMLMenuElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "MENU"
		meta: class HTMLMetaElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "META"
		meter: class HTMLMeterElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "METER"
		object: class HTMLObjectElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "OBJECT"
		ol: class HTMLOListElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "OL"
		optgroup: class HTMLOptGroupElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "OPTGROUP"
		option: class HTMLOptionElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "OPTION"
		output: class HTMLOutputElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "OUTPUT"
		p: class HTMLParagraphElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "P"
		param: class HTMLParamElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "PARAM"
		pre: class HTMLPreElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "PRE"
		progress: class HTMLProgressElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "PROGRESS"
		quote: class HTMLQuoteElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "QUOTE"
		script: class HTMLScriptElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "SCRIPT"
		select: class HTMLSelectElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "SELECT"
		source: class HTMLSourceElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "SOURCE"
		style: class HTMLStyleElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "STYLE"
		table: class HTMLTableElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TABLE"
		thead: class HTMLTableHeadElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "THEAD"
		tbody: class HTMLTableBodyElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TBODY"
		tfoot: class HTMLTableFootElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TFOOT"
		td: class HTMLTableCellElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TD"
		th: HTMLTableCellElement
			constructor: (a...) ->
				super a...
				@nodeName = "TH"
		tr: class HTMLTableRowElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TR"
		textarea: class HTMLTextAreaElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TEXTAREA"
		title: class HTMLTitleElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "TITLE"
		ul: class HTMLUListElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "UL"
		video: class HTMLVideoElement extends HTMLElement
			constructor: (a...) ->
				super a...
				@nodeName = "VIDEO"
	}
	constructor: (a...) ->
		super a...
		@nodeType = Node.ELEMENT_NODE
		@__defineGetter__ 'tagName', () => @nodeName
		@__defineSetter__ 'tagName', (v) => @nodeName = v
	getElementsByClassName: (name) ->
		ret = []
		for c in @childNodes
			# TODO: optimize this by caching the split form in className's setter
			if name in (c.className ? "").split(" ")
				ret.push c
			for i in c.getElementsByClassName(name)
				ret.push i
		return ret
	getElementsByTagName: (name) ->
		ret = []
		uname = name.toUpperCase()
		for c in @childNodes
			if c.tagName is uname
				ret.push c
			for i in c.getElementsByTagName(uname)
				ret.push i
		return ret
	# attributes
	getAttribute: (name) ->
		return @attributes[name] ? ""
	hasAttribute: (name) ->
		return name of @attributes
	setAttribute: (name, value) ->
		@attributes[name] = value
	removeAttribute: (name) ->
		delete @attributes[name]
	# selectors
	matchesSelector: () ->
	querySelector: () ->
	querySelectorAll: () ->
	# scrolling
	scrollByLines: NotSupported
	scrollByPages: NotSupported
	scrollIntoView: NotSupported
	scrollIntoViewIfNeeded: NotSupported
	# size and position
	getBoundingClientRect: NotSupported
	getClientRects: NotSupported
	# focus
	focus: NotSupported
	blur: NotSupported
	# render
	toString: (indentLevel = 0) ->
		name = @nodeName.toLowerCase()
		attrs = [" #{a}=\"#{@attributes[a]}\"" for a of @attributes].join('')
		indent = "  ".times(indentLevel)
		ret = indent + "<#{name}#{attrs}>"
		if @childNodes.length > 0
			ret += "\n"
		for c in @childNodes
			ret += c.toString(indentLevel + 1)
		if @childNodes.length > 0
			ret += indent
		ret += "</#{name}>\n"
		ret

class Attr extends Node
	constructor: (name, value) ->
		super name, value, Node.ATTRIBUTE_NODE
		@name = @nodeName
		@value = @nodeValue
		@ownerElement = null

class CData extends Node
	constructor: (value) ->
		super "#cdata", value, Node.CDATA_SECTION_NODE

class Comment extends Node
	constructor: (value) ->
		super "#comment", value, Node.COMMENT_NODE

class Text extends Node
	constructor: (value) ->
		super "#text", value, Node.TEXT_NODE

class DocumentFragment extends Node
	constructor: () ->
		@nodeName = "#document-fragment"
		@nodeType = Node.DOCUMENT_FRAGMENT_NODE

class Document extends Node
	constructor: () ->
		super "#document", null, Node.DOCUMENT_NODE
		@_private = {
			idMap: {}
		}
		@documentElement = null
		@documentURI = null
	adoptNode: NotSupported
	importNode: NotSupported
	caretRangeFromPoint: NotSupported
	createAttribute: (name) ->
		node = new Attr(name, null)
		node.ownerDocument = @
	createAttributeNS: NotSupported
	createCDATASection: (value) ->
		node = new CData(value)
		node.ownerDocument = @
	createComment: (value) ->
		node = new Comment(value)
		node.ownerDocument = @
	createDocumentFragment: () ->
		node = new DocumentFragment()
		node.ownerDocument = @
	createElement: (name) ->
		nodeClass = Element.Map[name.toLowerCase()]
		if not nodeClass?
			node = new Element.Map['_'](name.toUpperCase())
		else
			node = new nodeClass()
		node.ownerDocument = @
		node
	createEntityReference: NotSupported
	createEvent: (type) ->
		switch type
			when "MutationEvents"
				new MutationEvent()
			else
				new Event()
	createNodeIterator: NotSupported
	createProcessingInstruction: NotSupported
	createRange: NotSupported
	createTextNode: (text) ->
		new Text(text)
	createTreeWalker: NotSupported
	elementFromPoint: NotSupported
	evaluate: NotSupported
	execCommand: NotSupported
	getCSSCanvasContext: NotSupported
	getElementById: (id) ->
		@_private.idMap[id]
	getOverrideStyle: NotSupported
	getSelection: NotSupported
	queryCommandEnabled: NotSupported
	queryCommandIndeterm: NotSupported
	queryCommandState: NotSupported
	queryCommandSupported: NotSupported
	queryCommandValue: NotSupported

class HTMLDocument extends Document
	constructor: () ->
		super
		@nodeName = "HTML"
		Document::appendChild.call @,@createElement('head')
		Document::appendChild.call @,@createElement('body')
		@head = @childNodes[0]
		@body = @childNodes[1]
	# over-ride the child manipulators, you can't touch .head or .body
	hasChildNodes: () -> true
	insertBefore: NotSupported
	appendChild: NotSupported
	removeChild: NotSupported
	replaceChild: NotSupported
	# what is all this crap? HTMLDocument has it in Chrome...
	captureEvents: NotSupported
	clear: NotSupported
	close: NotSupported
	hasFocus: NotSupported
	open: NotSupported
	releaseEvents: NotSupported
	# should support these but we don't have an html parser...
	write: NotSupported
	writeln: NotSupported

### Document Traversal not supported yet
class TreeWalker
	constructor: (root, what, filter) ->
		@root = root
		@currentNode = root
		@whatToShow = what
		@filter = filter
	parentNode: () ->
		@currentNode = @currentNode.parentNode
	firstChild: () ->
		@currentNode = @currentNode.firstChild
	lastChild: () ->
		@currentNode = @currentNode.lastChild
	previousSibling: () ->
		@currentNode = @currentNode.previousSibling
	nextSibling: () ->
		@currentNode = @currentNode.nextSibling
	nextNode: () ->
		@currentNode = @currentNode.nextSibling or @currentNode.childNodes[0]
	previousNode: () ->
		if @currentNode is @root
			@currentNode = @currentNode.previousSibling
		else
			@currentNode = @currentNode.previousSibling or @currentNode.parentNode
class NodeFilter
	# Constants returned by acceptNode
	FILTER_ACCEPT = 1
	FILTER_REJECT = 2
	FILTER_SKIP   = 3
	# Constants for whatToShow
	SHOW_ALL = 0xFFFFFFFF
	SHOW_ELEMENT = 0x00000001
	SHOW_ATTRIBUTE = 0x00000002
	SHOW_TEXT = 0x00000004
	SHOW_CDATA_SECTION = 0x00000008
	SHOW_ENTITY_REFERENCE = 0x00000010
	SHOW_ENTITY = 0x00000020
	SHOW_PROCESSING_INSTRUCTION = 0x00000040
	SHOW_COMMENT = 0x00000080
	SHOW_DOCUMENT = 0x00000100
	SHOW_DOCUMENT_TYPE = 0x00000200
	SHOW_DOCUMENT_FRAGMENT = 0x00000400
	SHOW_NOTATION = 0x00000800
	constructor: (whatToShow = NodeFilter.SHOW_ALL) ->
		@whatToShow = whatToShow
	acceptNode: (node) ->
		if (node.nodeType & @whatToShow) isnt 0
			NodeFilter.FILTER_ACCEPT
		else
			NodeFilter.FILTER_REJECT
class NodeSkipper extends NodeFilter
	acceptNode: (node) ->
		if super(node) is NodeFilter.FILTER_REJECT
			NodeFilter.FILTER_SKIP
		NodeFilter.FILTER_ACCEPT
class NodeRejecter extends NodeFilter
	acceptNode: (node) ->
		if super(node) is NodeFilter.FILTER_ACCEPT
			NodeFilter.FILTER_REJECT
		NodeFilter.FILTER_ACCEPT
###

exports.createDocument = () ->
	new HTMLDocument()

# vim: ft=coffee
