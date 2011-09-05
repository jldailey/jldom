
dom = require('../dom')
document = dom.createDocument()
html = require('../html/parser')

test_parse = (input, output, debug = false) ->
	result = html.parse(input, document, debug).toString(false, true)
	output ?= input
	if result isnt output
		throw Error result+" !== "+output

test_escape = (input, output) ->
	result = html.escape(input)
	if result isnt output
		throw Error result+" !== "+output

test_parse "<div/>"
test_parse "<div>Harro?</div>"
test_parse "<div><p>Hi.</p></div>"
test_parse "<div><p><span>Bye.</span></p></div>"
test_parse "<div />", "<div/>"
test_parse "<div><p  /></div>","<div><p/></div>"
test_parse "<div><p /></div>","<div><p/></div>"
test_parse "<div><p/></div>","<div><p/></div>"
test_parse "<div key='val'></div>", '<div key="val"/>'
test_parse "<div key='val' ></div>", '<div key="val"/>'
test_parse "<div key='val'/>", '<div key="val"/>'
test_parse "<div key='val' />", '<div key="val"/>'
test_parse '<div id="test_parse"></div>', '<div id="test_parse"/>'
test_parse '<eval>CurrencyFormat(Application.User.balance)</eval>'
test_parse '<p>','<p/>'
test_parse "<div>foo</div>", "<div>foo</div>"
test_parse '<div>1,2</div>', '<div>1,2</div>'
test_parse 'text', 'text' # parsing lone text as text nodes
test_escape '<p>', '&lt;p&gt;'
# TODO: more escape and unescape tests
console.log "All tests passed."

# vim: ft=coffee
