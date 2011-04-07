
PWD=/opt/domjs
BD=/opt/compilejs

all: dom.js
	make -C html
	make -C css

min.%.js: %.js
	(cp $< $(BD) && cd $(BD) && make $@ && mv $< $@ $(PWD))

%.js: %.coffee
	coffee -c $<

clean:
	make -C css clean
	make -C html clean
	rm -f dom.js
