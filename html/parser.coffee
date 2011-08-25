clear = (a...) ->
	for i in a
		i.length = 0
get = (a) -> a.join("")
parse = (input, document) ->
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
		clear(text, tagName, attrName, attrVal)
		for a of attributes
			delete attributes[a]
		mode = 0
	closeNode = () -> cursor = cursor.parentNode
	emitAttr = () ->
		attributes[get(attrName)] = get(attrVal)
		clear(attrName, attrVal)
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
			else if typeof x is "number" # /^\d+$/.test x
				mode = x
			else if x.push
				x.push c
	return cursor

entity_table =
	"™": "&#8482;"
	"€": "&euro;"
	" ": "&nbsp;"
	'"': "&quot;"
	"&": "&amp;"
	"<": "&lt;"
	">": "&gt;"
	"¡": "&iexcl;"
	"¢": "&cent;"
	"£": "&pound;"
	"¤": "&curren;"
	"¥": "&yen;"
	"¦": "&brvbar;"
	"§": "&sect;"
	"¨": "&uml;"
	"©": "&copy;"
	"ª": "&ordf;"
	"«": "&laquo;"
	"¬": "&not;"
	"¯": "&shy;"
	"®": "&reg;"
	"¯": "&macr;"
	"°": "&deg;"
	"±": "&plusmn;"
	"²": "&sup2;"
	"³": "&sup3;"
	"´": "&acute;"
	"µ": "&micro;"
	"¶": "&para;"
	"·": "&middot;"
	"¸": "&cedil;"
	"¹": "&sup1;"
	"º": "&ordm;"
	"»": "&raquo;"
	"¼": "&frac14;"
	"½": "&frac12;"
	"¾": "&frac34;"
	"¿": "&iquest;"
	"À": "&Agrave;"
	"Á": "&Aacute;"
	"Â": "&Acirc;"
	"Ã": "&Atilde;"
	"Ä": "&Auml;"
	"Å": "&Aring;"
	"Æ": "&AElig;"
	"Ç": "&Ccedil;"
	"È": "&Egrave;"
	"É": "&Eacute;"
	"Ê": "&Ecirc;"
	"Ë": "&Euml;"
	"Ì": "&Igrave;"
	"Í": "&Iacute;"
	"Î": "&Icirc;"
	"Ï": "&Iuml;"
	"Ð": "&ETH;"
	"Ñ": "&Ntilde;"
	"Ò": "&Ograve;"
	"Ó": "&Oacute;"
	"Ô": "&Ocirc;"
	"Õ": "&Otilde;"
	"Ö": "&Ouml;"
	"×": "&times;"
	"Ø": "&Oslash;"
	"Ù": "&Ugrave;"
	"Ú": "&Uacute;"
	"Û": "&Ucirc;"
	"Ü": "&Uuml;"
	"Ý": "&Yacute;"
	"Þ": "&THORN;"
	"ß": "&szlig;"
	"à": "&agrave;"
	"á": "&aacute;"
	"â": "&acirc;"
	"ã": "&atilde;"
	"ä": "&auml;"
	"å": "&aring;"
	"æ": "&aelig;"
	"ç": "&ccedil;"
	"è": "&egrave;"
	"é": "&eacute;"
	"ê": "&ecirc;"
	"ë": "&euml;"
	"ì": "&igrave;"
	"í": "&iacute;"
	"î": "&icirc;"
	"ï": "&iuml;"
	"ð": "&eth;"
	"ñ": "&ntilde;"
	"ò": "&ograve;"
	"ó": "&oacute;"
	"ô": "&ocirc;"
	"õ": "&otilde;"
	"ö": "&ouml;"
	"÷": "&divide;"
	"ø": "&oslash;"
	"ù": "&ugrave;"
	"ú": "&uacute;"
	"û": "&ucirc;"
	"ü": "&uuml;"
	"ý": "&yacute;"
	"þ": "&thorn;"
	"ÿ": "&#255;"
	"Ā": "&#256;"
	"ā": "&#257;"
	"Ă": "&#258;"
	"ă": "&#259;"
	"Ą": "&#260;"
	"ą": "&#261;"
	"Ć": "&#262;"
	"ć": "&#263;"
	"Ĉ": "&#264;"
	"ĉ": "&#265;"
	"Ċ": "&#266;"
	"ċ": "&#267;"
	"Č": "&#268;"
	"č": "&#269;"
	"Ď": "&#270;"
	"ď": "&#271;"
	"Đ": "&#272;"
	"đ": "&#273;"
	"Ē": "&#274;"
	"ē": "&#275;"
	"Ĕ": "&#276;"
	"ĕ": "&#277;"
	"Ė": "&#278;"
	"ė": "&#279;"
	"Ę": "&#280;"
	"ę": "&#281;"
	"Ě": "&#282;"
	"ě": "&#283;"
	"Ĝ": "&#284;"
	"ĝ": "&#285;"
	"Ğ": "&#286;"
	"ğ": "&#287;"
	"Ġ": "&#288;"
	"ġ": "&#289;"
	"Ģ": "&#290;"
	"ģ": "&#291;"
	"Ĥ": "&#292;"
	"ĥ": "&#293;"
	"Ħ": "&#294;"
	"ħ": "&#295;"
	"Ĩ": "&#296;"
	"ĩ": "&#297;"
	"Ī": "&#298;"
	"ī": "&#299;"
	"Ĭ": "&#300;"
	"ĭ": "&#301;"
	"Į": "&#302;"
	"į": "&#303;"
	"İ": "&#304;"
	"ı": "&#305;"
	"Ĳ": "&#306;"
	"ĳ": "&#307;"
	"Ĵ": "&#308;"
	"ĵ": "&#309;"
	"Ķ": "&#310;"
	"ķ": "&#311;"
	"ĸ": "&#312;"
	"Ĺ": "&#313;"
	"ĺ": "&#314;"
	"Ļ": "&#315;"
	"ļ": "&#316;"
	"Ľ": "&#317;"
	"ľ": "&#318;"
	"Ŀ": "&#319;"
	"ŀ": "&#320;"
	"Ł": "&#321;"
	"ł": "&#322;"
	"Ń": "&#323;"
	"ń": "&#324;"
	"Ņ": "&#325;"
	"ņ": "&#326;"
	"Ň": "&#327;"
	"ň": "&#328;"
	"ŉ": "&#329;"
	"Ŋ": "&#330;"
	"ŋ": "&#331;"
	"Ō": "&#332;"
	"ō": "&#333;"
	"Ŏ": "&#334;"
	"ŏ": "&#335;"
	"Ő": "&#336;"
	"ő": "&#337;"
	"Œ": "&#338;"
	"œ": "&#339;"
	"Ŕ": "&#340;"
	"ŕ": "&#341;"
	"Ŗ": "&#342;"
	"ŗ": "&#343;"
	"Ř": "&#344;"
	"ř": "&#345;"
	"Ś": "&#346;"
	"ś": "&#347;"
	"Ŝ": "&#348;"
	"ŝ": "&#349;"
	"Ş": "&#350;"
	"ş": "&#351;"
	"Š": "&#352;"
	"š": "&#353;"
	"Ţ": "&#354;"
	"ţ": "&#355;"
	"Ť": "&#356;"
	"ť": "&#357;"
	"Ŧ": "&#358;"
	"ŧ": "&#359;"
	"Ũ": "&#360;"
	"ũ": "&#361;"
	"Ū": "&#362;"
	"ū": "&#363;"
	"Ŭ": "&#364;"
	"ŭ": "&#365;"
	"Ů": "&#366;"
	"ů": "&#367;"
	"Ű": "&#368;"
	"ű": "&#369;"
	"Ų": "&#370;"
	"ų": "&#371;"
	"Ŵ": "&#372;"
	"ŵ": "&#373;"
	"Ŷ": "&#374;"
	"ŷ": "&#375;"
	"Ÿ": "&#376;"
	"Ź": "&#377;"
	"ź": "&#378;"
	"Ż": "&#379;"
	"ż": "&#380;"
	"Ž": "&#381;"
	"ž": "&#382;"
	"ſ": "&#383;"
	"Ŕ": "&#340;"
	"ŕ": "&#341;"
	"Ŗ": "&#342;"
	"ŗ": "&#343;"
	"Ř": "&#344;"
	"ř": "&#345;"
	"Ś": "&#346;"
	"ś": "&#347;"
	"Ŝ": "&#348;"
	"ŝ": "&#349;"
	"Ş": "&#350;"
	"ş": "&#351;"
	"Š": "&#352;"
	"š": "&#353;"
	"Ţ": "&#354;"
	"ţ": "&#355;"
	"Ť": "&#356;"
	"ť": "&#577;"
	"Ŧ": "&#358;"
	"ŧ": "&#359;"
	"Ũ": "&#360;"
	"ũ": "&#361;"
	"Ū": "&#362;"
	"ū": "&#363;"
	"Ŭ": "&#364;"
	"ŭ": "&#365;"
	"Ů": "&#366;"
	"ů": "&#367;"
	"Ű": "&#368;"
	"ű": "&#369;"
	"Ų": "&#370;"
	"ų": "&#371;"
	"Ŵ": "&#372;"
	"ŵ": "&#373;"
	"Ŷ": "&#374;"
	"ŷ": "&#375;"
	"Ÿ": "&#376;"
	"Ź": "&#377;"
	"ź": "&#378;"
	"Ż": "&#379;"
	"ż": "&#380;"
	"Ž": "&#381;"
	"ž": "&#382;"
	"ſ": "&#383;"

escape = (input) ->
	for c of entity_table
		input = input.replace(c, entity_table[c])
	input

unescape = (input) ->
	for c of entity_table
		input = input.replace(entity_table[c],c)
	input

if exports
	exports.parse = parse
	exports.escape = escape
	exports.unescape = unescape

# vim: ft=coffee
