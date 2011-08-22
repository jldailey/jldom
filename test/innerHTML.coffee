document = require("../dom").createDocument()
assertEqual = (a, b, label) ->
	if a isnt b
		throw Error "#{label} (#{a?.toString()}) should equal (#{b?.toString()})"

document.body.innerHTML = "<div></div>"

assertEqual document.toString(false, true), "<html><head/><body><div/></body></html>"
console.log "All tests passed."
