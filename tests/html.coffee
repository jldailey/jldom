
dom = require('../dom')
document = dom.createDocument()
html = require('../html/parser')

test_parse = (input, output, debug = false) ->
	message = ""
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
test_parse '<body><!-- comment --><span>foo</span></body>'
test_parse '<a>Hello<b>World</b></a>'
test_parse '<head><meta charset="utf-8"><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
test_parse '<head><meta charset="utf-8"/><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
test_parse '<head><meta charset="utf-8"></meta><span>foo</span></head>', '<head><meta charset="utf-8"/><span>foo</span></head>'
test_escape '<p>', '&lt;p&gt;'
test_escape '&amp;', '&amp;'
test_escape '?input=foo&amp;bar&key=value', '?input=foo&amp;bar&key=value',
# TODO: more escape and unescape tests
console.log "All tests passed."

# vim: ft=coffee
