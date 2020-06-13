# Parent makefile for Python (https://github.com/c4s4/make)

BUILD_DIR=build
PYTHON_HOME=$(shell pwd)
PYTHON_VENV=$(PYTHON_HOME)/venv
PYTHON=$(PYTHON_VENV)/bin/python
PYTHON_RUN=$(PYTHON_HOME)/requirements.run
PYTHON_DEV=$(PYTHON_HOME)/requirements.dev
PYTHON_REQ=$(PYTHON_HOME)/requirements.txt
PYTHON_LINT=$(PYTHON_HOME)/pylint.cfg
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
	@echo "$(YEL)Creating virtual environment$(END)"
	rm -rf $(PYTHON_VENV)
	python -m venv $(PYTHON_VENV)
	$(PYTHON_VENV)/bin/pip install --upgrade pip

.PHONY: py-libs
py-libs: py-venv # Install libraries
	@echo "$(YEL)Installing libraries$(END)"
	$(PYTHON_VENV)/bin/pip install -r $(PYTHON_REQ)
	@test -f $(PYTHON_DEV) && $(PYTHON_VENV)/bin/pip install -r $(PYTHON_DEV)

.PHONY: py-reqs
py-reqs: py-venv # Generate requirements file
	@echo "$(YEL)Generating requirements file$(END)"
	$(PYTHON_VENV)/bin/pip install -r $(PYTHON_RUN)
	$(PYTHON_VENV)/bin/pip freeze > $(PYTHON_REQ)

.PHONY: py-lint
py-lint: # Validate source code
	@echo "$(YEL)Validating source code$(END)"
	$(PYTHON_VENV)/bin/pylint --rcfile=$(PYTHON_LINT) $(PYTHON_MOD)

.PHONY: py-watch
py-watch: # Validate source code in watch
	@echo "$(YEL)Validating source code in watch$(END)"
	watch $(PYTHON_VENV)/bin/pylint --rcfile=$(PYTHON_LINT) $(PYTHON_MOD)

.PHONY: py-test
py-test: # Run unit tests
	@echo "$(YEL)Running unit tests$(END)"
	@test -f $(PYTHON_ENV) && . $(PYTHON_ENV); \
	$(PYTHON) -m unittest $(PYTHON_TEST)

.PHONY: py-run
py-run: # Run application
	@echo "$(YEL)Running application$(END)"
	@test -f $(PYTHON_ENV) && . $(PYTHON_ENV); \
	$(PYTHON) -m $(PYTHON_MOD) $(PYTHON_ARGS)

.PHONY: py-dist
py-dist: clean # Generate distribution archive
	@echo "$(YEL)Generating distribution archive$(END)"
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
	@echo "$(YEL)Deploying package locally$(END)"
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install ./$(PYTHON_PKG)-*.tar.gz

.PHONY: py-integ
py-integ: py-deploy # Run integration test
	@echo "$(YEL)Running integration test$(END)"
	cd $(BUILD_DIR) && $(PYTHON_ITG)

.PHONY: py-pi
py-pi: clean # Test installation from Pypi
	@echo "$(YEL)Testing installation from Pypi$(END)"
	@mkdir -p $(BUILD_DIR); \
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install $(PYTHON_PKG); \
	$(PYTHON_ITG)

.PHONY: py-upload
py-upload: py-dist # Upload distribution archive
	@echo "$(YEL)Uploading distribution archive$(END)"
	cd $(BUILD_DIR) && $(PYTHON) setup.py sdist -d . register upload

.PHONY: py-release
py-release: clean py-lint py-test py-integ git-tag py-upload # Release project on Pypi
	@echo "$(YEL)Released project on Pypi$(END)"
