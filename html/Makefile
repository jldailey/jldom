
BD=/opt/compilejs
PWD=/opt/domjs/html

%.js: %.coffee
	coffee -c $<

min.%.js: %.js
	(cp $< $(BD) && cd $(BD) && make $@ && cp $@ $(PWD) && rm $<)
