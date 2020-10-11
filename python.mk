# Parent makefile for Python (https://github.com/c4s4/make)

BUILD_DIR=build
PYTHON_HOME=$(shell pwd)
PYTHON_VENV=$(PYTHON_HOME)/venv
PYTHON=$(PYTHON_VENV)/bin/python
PYTHON_CFG=$(PYTHON_HOME)
PYTHON_RUN=$(PYTHON_CFG)/requirements.run
PYTHON_DEV=$(PYTHON_CFG)/requirements.dev
PYTHON_REQ=$(PYTHON_HOME)/requirements.txt
PYTHON_LINT=$(PYTHON_CFG)/pylint.cfg
# if set will run specific test else will run all tests
PYTHON_TEST=
PYTHON_MOD=$(shell basename $(shell pwd))
PYTHON_ARGS=
PYTHON_PKG=$(PYTHON_MOD)
PYTHON_PKF=LICENSE* MANIFEST.in
PYTHON_ITG=echo "Running integration test"
# environment file for test (must start with ./ if in same directory)
PYTHON_ENV=./.env

.PHONY: py-venv
py-venv: # Create virtual environment
	$(title)
	rm -rf $(PYTHON_VENV)
	python -m venv $(PYTHON_VENV)
	$(PYTHON_VENV)/bin/pip install --upgrade pip

.PHONY: py-libs
py-libs: py-venv # Install libraries
	$(title)
	@if [ -f $(PYTHON_REQ) ]; then \
		 $(PYTHON_VENV)/bin/pip install -r $(PYTHON_REQ); \
	fi
	@if [ -f $(PYTHON_DEV) ]; then \
		 $(PYTHON_VENV)/bin/pip install -r $(PYTHON_DEV); \
	fi

.PHONY: py-reqs
py-reqs: py-venv # Generate requirements file
	$(title)
	$(PYTHON_VENV)/bin/pip install -r $(PYTHON_RUN)
	$(PYTHON_VENV)/bin/pip freeze > $(PYTHON_REQ)

.PHONY: py-lint
py-lint: # Validate source code
	$(title)
	$(PYTHON_VENV)/bin/pylint --rcfile=$(PYTHON_LINT) $(PYTHON_MOD)

.PHONY: py-watch
py-watch: # Validate source code in watch
	$(title)
	watch $(PYTHON_VENV)/bin/pylint --rcfile=$(PYTHON_LINT) $(PYTHON_MOD)

.PHONY: py-test
py-test: # Run unit tests
	$(title)
	@test -f $(PYTHON_ENV) && . $(PYTHON_ENV); \
	$(PYTHON) -m unittest $(PYTHON_TEST)

.PHONY: py-run
py-run: # Run application
	$(title)
	@test -f $(PYTHON_ENV) && . $(PYTHON_ENV); \
	$(PYTHON) -m $(PYTHON_MOD) $(PYTHON_ARGS)

.PHONY: py-dist
py-dist: clean # Generate distribution archive
	$(title)
	mkdir -p $(BUILD_DIR)
	cp -r $(PYTHON_MOD) setup.py $(BUILD_DIR)/
	for file in $(PYTHON_PKF); do \
		cp $$file $(BUILD_DIR); \
	done
	if [ -f README.rst ]; then \
		cp README.rst $(BUILD_DIR)/; \
	else \
		pandoc -f markdown -t rst README.md > $(BUILD_DIR)/README.rst; \
	fi
	sed -i 's/0.0.0/$(TAG)/g' $(BUILD_DIR)/setup.py
	cd $(BUILD_DIR) && $(PYTHON) setup.py sdist -d .

.PHONY: py-deploy
py-deploy: py-dist # Deploy package locally
	$(title)
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install ./$(PYTHON_PKG)-*.tar.gz

.PHONY: py-integ
py-integ: py-deploy # Run integration test
	$(title)
	cd $(BUILD_DIR) && $(PYTHON_ITG)

.PHONY: py-pi
py-pi: clean # Test installation from Pypi
	$(title)
	@mkdir -p $(BUILD_DIR); \
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install $(PYTHON_PKG); \
	$(PYTHON_ITG)

.PHONY: py-upload
py-upload: py-dist # Upload distribution archive
	$(title)
	cd $(BUILD_DIR) && $(PYTHON) setup.py sdist -d . register upload

.PHONY: py-release
py-release: clean py-lint py-test py-integ git-tag py-upload # Release project on Pypi
	$(title)
