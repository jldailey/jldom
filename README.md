
domjs

Doesn't attempt to be compliant, but it supports everything you actually need.
Including full CSS3 selector support from NWMatcher (the only full CSS3 implementation I can find.)

Unlike the similar 'jsdom' project, starting out is trivial.
It assumes the document is going to act like it would in a browser.
No attempt has been made to support XML or Xpath or anything exotic.

Example:
	document = require('dom').createDocument()

	document.body.innerHTML = "<div>Hello, World.</div>"

	document.toString() === "<html><head/><body><div>Hello, World.</div></body></html>"

	document.querySelector("div").toString() == "<div>Hello, World.</div>"

It should be usably fast, I built it to facilitate generating server-side HTML for a web application.

