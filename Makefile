JAVA=$(shell which java)

all: lib/dom.js

lib/dom.js: html/parser.js css/nwmatcher.js dom.coffee
	coffee -o ./lib -c dom.coffee
	cat html/parser.js css/nwmatcher.js $@ > lib/tmp.js
	rm html/parser.js
	mv lib/tmp.js $@
	sed -e 's/= require[^;]*;/= exports;/g' -i .bak $@
	rm lib/*.bak
	$(JAVA) -jar ./build/yuicompressor.jar lib/dom.js -v -o lib/dom.js

%.min.js: %.js
	$(JAVA) -jar ./build/yuicompressor.jar $< -v -o $@

html/parser.js: html/parser.coffee
	coffee -o ./html -c html/parser.coffee

test: dom.coffee
	for i in $(shell ls tests/*.coffee); do coffee $$i; done

clean:
	rm -f html/parser.js
	rm -f lib/dom.js
	rm -f lib/dom.min.js

