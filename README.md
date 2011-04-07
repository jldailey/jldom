
domjs

An implementation of the DOM in CoffeeScript.

Intended for use generating HTML in a Node.js application.

I haven't checked the actual DOM compliance, but everything you need is there:

* 110% CSS3 support via NWMatcher.
* The world's smallest HTML parser.

Unlike the similar 'jsdom' project, starting out is trivial.

It assumes the document is going to act like it would in a browser.

No attempt has been made to support XML or Xpath or anything exotic.

Example:
	document = require('dom').createDocument()

	document.body.innerHTML = "<div>Hello, World.</div>"

	document.toString()
		=== "<html><head/><body><div>Hello, World.</div></body></html>"

	document.querySelector("div").toString()
		=== "<div>Hello, World.</div>"

It should be usably fast, I built it to facilitate generating server-side HTML for a web application.

Install:
	git clone git://github.com/jldailey/domjs.git

To compile all the CoffeeScript:
	cd domjs
	make


