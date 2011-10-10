
### An implementation of the DOM in CoffeeScript/JavaScript

Intended for use in NodeJS.

I haven't checked the actual DOM compliance, but everything you need is there:

* Full CSS3 support via [NWMatcher](https://github.com/dperini/nwmatcher/).
* A very tiny HTML parser.
* DOM-compliant event binding and triggering (bubbling, cancelling, etc).
* Coming soon: (optional) Mutation Events.

This is not a fork of [jsdom](https://github.com/tmpvar/jsdom).

It assumes the document is going to act like it would in a browser (e.g. it automatically gets a head and body).

No attempt has been made to support XML or Xpath or anything exotic.

Example:

	document = require('./domjs/dom').createDocument()

	document.body.innerHTML = "<div>Hello, World.</div>"

	document.toString()
		=== "<html><head/><body><div>Hello, World.</div></body></html>"

	document.querySelector("div").toString()
		=== "<div>Hello, World.</div>"

I built this to generate server-side HTML from a NodeJS application. Benchmarks reveal that this is a waste of time.
I currently use it to unit test other javascript code that needs a reasonably well-behaved DOM to interact with.

Install:

	git clone git://github.com/jldailey/domjs.git

To compile all the CoffeeScript:

	cd domjs
	make

