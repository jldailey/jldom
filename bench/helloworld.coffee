dom = require('../dom')

assign_and_output = () ->
	document = dom.createDocument()
	document.body.innerHTML = "<div class='content' id='content'>Hello World.</div>"
	return document.toString()

output = () ->
	node = (name, attrs = {}, children) ->
		attrs = (' '+k+'="'+attrs[k]+'"' for k of attrs).join('')
		if children.join
			children = children.join('')
		"<#{name}#{attrs}>#{children}</#{name}>"
	html = (children = []) -> node('html', {}, children)
	head = (attrs = {}, children = []) -> node('head', attrs, children)
	body = (attrs = {}, children = []) -> node('body', attrs, children)
	div = (attrs = {}, children = []) -> node('div', attrs, children)
	p = (attrs = {}, children = []) -> node('p', attrs, children)
	span = (attrs = {}, children = []) -> node('span', attrs, children)

	html([head(), body(null, div({id:'content','class':'content'}, "Hello World."))])

measure = (f, n) ->
	start = Date.now()
	for i in [0..n]
		f()
	return (Date.now() - start)

run = (f, n, interval) ->
	sum = 0
	sum_n = 0
	for i in [0...n] by interval
		ms = measure(f, interval)
		rps = interval * 1000 / ms
		sum += rps
		sum_n += 1
	console.log "Avg. requests per sec:", (sum/sum_n)

console.log "Using domjs"
console.log assign_and_output()
run assign_and_output, 1000,200

console.log "Using a raw tree"
console.log output()
run output, 100000, 20000

# vim: ft=coffee
