
# LEVEL=ADVANCED_OPTIMIZATIONS
LEVEL=SIMPLE_OPTIMIZATIONS

all: parser.js

%.js: %.coffee
	coffee -c $<

clean:
	rm -f parser.js
