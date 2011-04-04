
PWD=/opt/domjs
BD=/opt/compilejs
CSSFILES=$(shell echo css/{parser.jison,search.coffee,Makefile})

min.%.js: %.js
	(cp $< $(BD) && cd $(BD) && make $@ && mv $< $@ $(PWD))

%.js: %.coffee
	coffee -c $<

css: $(CSSFILES)
	make -C css

clean:
	rm -f dom.js min.dom.js css/parser.js css/search.js
