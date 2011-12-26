VERSION=$(shell cat VERSION)
PACKAGE_NAME=jdom
BASE=npm/$(PACKAGE_NAME)
TEST_FILES=$(BASE)/tests/document.js $(BASE)/tests/html.js $(BASE)/tests/innerHTML.js $(BASE)/tests/nwmatcher.js

all: dom.js
	make -C html

test: dom.coffee
	for i in $(shell ls tests/*.coffee); do coffee $$i; done

%.js: %.coffee
	coffee -c $<

$(BASE)/%.js: %.coffee
	@mkdir -p $(BASE)/$(shell python -c 'print("/".join("$<".split("/")[:-1]))')
	coffee -o $(BASE)/$(shell python -c 'print("/".join("$<".split("/")[:-1]))') -c $<

npm: npm/$(PACKAGE_NAME)-$(VERSION).tgz

publish: npm
	scp npm/$(PACKAGE_NAME)-$(VERSION).tgz blingjs.com:/var/www/blingjs.com/downloads/$(PACKAGE_NAME)-$(VERSION).tgz

npm/$(PACKAGE_NAME)-$(VERSION).tgz: $(BASE)/package.json $(BASE)/dom.js $(BASE)/html/parser.js $(TEST_FILES)
	@cp css/nwmatcher.js $(BASE)/css
	(cd npm && tar czvf $(PACKAGE_NAME)-$(VERSION).tgz $(PACKAGE_NAME))

$(BASE)/package.json: package.json
	@mkdir -p $(BASE) $(BASE)/html $(BASE)/css $(BASE)/tests
	(VERSION=`cat VERSION`; eval echo \"`sed s/\\"/\\\\\\\\\\"/g package.json`\") > $(BASE)/package.json

clean:
	rm -rf dom.js npm
	make -C html clean

.PHONY: npm clean all test
