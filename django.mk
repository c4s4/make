# Parent makefile for Django (https://github.com/c4s4/make)

include ~/.make/python.mk

SERVER_PORT=0:8000

.PHONY: runserver
runserver: # Run Django development server
	$(title)
	$(PYTHON) manage.py runserver $(SERVER_PORT)

.PHONY: migrations
migrations: # Generate migration scripts
	$(title)
	$(PYTHON) manage.py makemigrations

.PHONY: migrate
migrate: # Run migration scripts
	$(title)
	$(PYTHON) manage.py migrate

.PHONY: shell
shell: # Run Django shell
	$(title)
	$(PYTHON) manage.py shell

.PHONY: test
test: # Run Django test suite
	$(title)
	$(PYTHON) manage.py test
