
all: dom.js
	make -C html

test: dom.coffee
	for i in $(shell ls test/*.coffee); do coffee $$i; done

%.js: %.coffee
	coffee -c $<

clean:
	make -C html clean
	rm -f dom.js
