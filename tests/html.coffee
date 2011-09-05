
dom = require('../dom')
document = dom.createDocument()
html = require('../html/parser')

test = (input, output, debug = false) ->
	result = html.parse(input, document, debug).toString(false, true)
	output ?= input
	if result isnt output
		throw Error result+" !== "+output

test "<div/>"
test "<div>Harro?</div>"
test "<div><p>Hi.</p></div>"
test "<div><p><span>Bye.</span></p></div>"
test "<div />", "<div/>"
test "<div><p  /></div>","<div><p/></div>"
test "<div><p /></div>","<div><p/></div>"
test "<div><p/></div>","<div><p/></div>"
test "<div key='val'></div>", '<div key="val"/>'
test "<div key='val' ></div>", '<div key="val"/>'
test "<div key='val'/>", '<div key="val"/>'
test "<div key='val' />", '<div key="val"/>'
test '<div id="test"></div>', '<div id="test"/>'
test '<eval>CurrencyFormat(Application.User.balance)</eval>'
test '<p>','<p/>'
test "<div>foo</div>", "<div>foo</div>"
test '<div>1,2</div>', '<div>1,2</div>'
console.log "All tests passed."

# vim: ft=coffee
