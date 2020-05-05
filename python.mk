# Parent makefile for Python

PYTHON_HOME=$(shell pwd)
PYTHON_VENV=$(PYTHON_HOME)/venv
PYTHON=$(PYTHON_VENV)/bin/python
PYTHON_REQ=$(PYTHON_HOME)/requirements.txt
PYTHON_LINT=$(PYTHON_HOME)/pylint.cfg
PYTHON_MOD=.

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
