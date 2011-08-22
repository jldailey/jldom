
all: dom.js
	make -C html

test: dom.coffee $(shell ls test/*.coffee)
	for i in $^; do coffee $$i; done
	touch test

%.js: %.coffee
	coffee -c $<

clean:
	make -C css clean
	make -C html clean
	rm -f dom.js
