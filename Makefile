
all: dom.js
	make -C html

%.js: %.coffee
	coffee -c $<

clean:
	make -C css clean
	make -C html clean
	rm -f dom.js
