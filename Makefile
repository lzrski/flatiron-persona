PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean-docs clean build test dist publish

install:
	rm npm-shrinkwrap.json
	npm install

docs:
	docco src/*.coffee


clean: clean-docs
	rm -rf lib/ test/*.js

clean-docs:
	rm -rf docs/

build: clean install
	coffee -cm -o lib/ src/

watch: end-watch
	coffee -cmw -o lib src & echo $$! > .watch_pid

end-watch:
	if [ -e .watch_pid ]; then kill `cat .watch_pid`; rm .watch_pid; else echo no .watch_pid file; fi

shrinkwrap:
	npm shrinkwrap

test:
	mocha

dist: clean docs build shrinkwrap test

publish: dist
	npm publish