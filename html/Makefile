
BD=/opt/compilejs
PWD=/opt/domjs/html
# LEVEL=ADVANCED_OPTIMIZATIONS
LEVEL=SIMPLE_OPTIMIZATIONS

%.js: %.coffee
	coffee -c $<

min.%.js: %.js
	(cp $< $(BD) && cd $(BD) && make $@ LEVEL=$(LEVEL) && cp $@ $(PWD) && rm $<)
