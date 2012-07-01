build:
	mkdir -p ./lib/html ./lib/css
	coffee -o ./lib -c *.coffee
	coffee -o ./lib/html -c html/parser.coffee
	cp css/nwmatcher.js ./lib/css

test: dom.coffee
	for i in $(shell ls tests/*.coffee); do coffee $$i; done

clean:
	rm -rf ./lib
