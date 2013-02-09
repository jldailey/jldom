JAVA=$(shell which java)
COFFEE=node_modules/.bin/coffee
MOCHA=node_modules/.bin/mocha

all: lib/dom.js

lib/dom.min.js: lib/dom.js
	$(JAVA) -jar ./build/yuicompressor.jar $< -v -o $@

lib/dom.js: $(COFFEE) html/parser.js css/nwmatcher.js dom.coffee
	(echo "var privates = {};" \
		&& cat html/parser.js css/nwmatcher.js | sed -E 's/exports/privates/g' \
		&& $(COFFEE) -bp dom.coffee \
	) | sed -e 's/= require[^;]*;/= privates;/g' > $@

%.min.js: %.js
	$(JAVA) -jar ./build/yuicompressor.jar $< -v -o $@

html/parser.js: $(COFFEE) html/parser.coffee
	$(COFFEE) -o ./html -c html/parser.coffee

$(COFFEE):
	npm install coffee-script

$(MOCHA):
	npm install mocha

test: test/passing

test/passing: $(MOCHA) test/all.coffee lib/dom.js
	$^ --compilers coffee:coffee-script --globals document,window,dom -R dot \
		&& echo > $@

clean:
	rm -f test/passing
	rm -f lib/dom.js
	rm -f lib/dom.min.js

