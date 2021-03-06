# simple makefile to simplify repetetive build env management tasks under posix

# caution: testing won't work on windows, see README

PYTHON ?= python
CYTHON ?= cython
NOSETESTS ?= nosetests
CTAGS ?= ctags

all: clean inplace test

clean-ctags:
	rm -f tags

clean: clean-ctags
	$(PYTHON) setup.py clean
	rm -rf dist

in: inplace # just a shortcut
inplace:
	$(PYTHON) setup.py build_ext -i

test-code: in
	$(NOSETESTS) -s -v sklearn
test-doc:
	$(NOSETESTS) -s -v doc/ doc/modules/ doc/datasets/ \
	doc/developers doc/tutorial/basic doc/tutorial/statistical_inference \
	doc/tutorial/text_analytics

test-coverage:
	rm -rf coverage .coverage
	$(NOSETESTS) -s -v --with-coverage sklearn

test: test-code test-doc

trailing-spaces:
	find sklearn -name "*.py" -exec sed -i'' 's/[ \t]*$$//' {} \;

cython:
	find sklearn -name "*.pyx" -exec $(CYTHON) {} \;

ctags:
	# make tags for symbol based navigation in emacs and vim
	# Install with: sudo apt-get install exuberant-ctags
	$(CTAGS) -R *

doc: inplace
	$(MAKE) -C doc html

doc-noplot: inplace
	$(MAKE) -C doc html-noplot

code-analysis:
	flake8 sklearn | grep -v __init__ | grep -v external
	pylint -E -i y sklearn/ -d E1103,E0611,E1101
