# Parent makefile for Python (https://github.com/c4s4/make)

include ~/.make/clean.mk

PYTHON_HOME=$(shell pwd)
PYTHON_VENV=$(PYTHON_HOME)/venv
PYTHON=$(PYTHON_VENV)/bin/python
PYTHON_REQ=$(PYTHON_HOME)/requirements.txt
PYTHON_LINT=$(PYTHON_HOME)/pylint.cfg
PYTHON_MOD=$(shell basename $(shell pwd))
PYTHON_PKG=$(PYTHON_MOD)
PYTHON_ITG=echo "Running integration test"

.PHONY: venv
venv: # Create virtual environment
	@echo "$(YEL)Creating virtual environment$(END)"
	rm -rf $(PYTHON_VENV)
	python -m venv $(PYTHON_VENV)
	$(PYTHON_VENV)/bin/pip install --upgrade pip

.PHONY: libs
libs: venv # Install libraries
	@echo "$(YEL)Installing libraries$(END)"
	$(PYTHON_VENV)/bin/pip install -r $(PYTHON_REQ)

.PHONY: lint
lint: # Validate source code
	@echo "$(YEL)Validating source code$(END)"
	$(PYTHON_VENV)/bin/pylint --rcfile=$(PYTHON_LINT) $(PYTHON_MOD)

.PHONY: test
test: # Run unit tests
	@echo "$(YEL)Running unit tests$(END)"
	$(PYTHON) -m unittest

.PHONY: dist
dist: clean # Generate distribution archive
	@echo "$(YEL)Generating distribution archive$(END)"
	mkdir -p $(BUILD_DIR)
	cp -r $(PYTHON_MOD) LICENSE* MANIFEST.in setup.py $(BUILD_DIR)/
	if [ -f README.rst ]; then \
		cp README.rst $(BUILD_DIR)/; \
	else \
		pandoc -f markdown -t rst README.md > $(BUILD_DIR)/README.rst; \
	fi
	sed -i 's/0.0.0/$(TAG)/g' $(BUILD_DIR)/setup.py
	cd $(BUILD_DIR) && $(PYTHON) setup.py sdist -d .

.PHONY: integ
integ: dist # Run integration test
	@echo "$(YEL)Running integration test$(END)"
	@mkdir -p $(BUILD_DIR); \
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install ./$(PYTHON_PKG)-*.tar.gz; \
	$(PYTHON_ITG)

.PHONY: pypi
pypi: clean # Test installation from Pypi
	@echo "$(YEL)Testing installation from Pypi$(END)"
	@mkdir -p $(BUILD_DIR); \
	cd $(BUILD_DIR); \
	$(PYTHON) -m venv venv; \
	venv/bin/pip install --upgrade pip; \
	venv/bin/pip install $(PYTHON_PKG); \
	$(PYTHON_ITG)

.PHONY: upload
upload: dist # Upload distribution archive
	@echo "$(YEL)Uploading distribution archive$(END)"
	cd $(BUILD_DIR) && $(PYTHON) setup.py sdist -d . register upload
