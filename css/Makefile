
BD=/opt/compilejs
PWD=/opt/domjs/css
# LEVEL=ADVANCED_OPTIMIZATIONS
LEVEL=SIMPLE_OPTIMIZATIONS

all:

%.js: %.coffee
	coffee -c $<

min.%.js: %.js
	(cp $< $(BD) && cd $(BD) && make $@ LEVEL=$(LEVEL) && cp $@ $(PWD) && rm $<)

clean:
	rm -f min.nwmatcher.js
