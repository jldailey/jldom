require "./common"
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
# TODO: more escape and unescape tests
}

TestReport()

# vim: ft=coffee
