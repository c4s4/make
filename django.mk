# Parent makefile for Django (https://github.com/c4s4/make)

SERVER_PORT=0:8000

.PHONY: dj-runserver
dj-runserver: # Run Django development server
	$(title)
	$(PYTHON) manage.py runserver $(SERVER_PORT)

.PHONY: dj-migrations
dj-migrations: # Generate migration scripts
	$(title)
	$(PYTHON) manage.py makemigrations

.PHONY: dj-migrate
dj-migrate: # Run migration scripts
	$(title)
	$(PYTHON) manage.py migrate

.PHONY: dj-shell
dj-shell: # Run Django shell
	$(title)
	$(PYTHON) manage.py shell

.PHONY: dj-test
dj-test: # Run Django test suite
	$(title)
	$(PYTHON) manage.py test
