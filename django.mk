# Parent makefile for Django (https://github.com/c4s4/make)

dj-runserver: # Run Django development server
	$(title)
	$(PYTHON) manage.py runserver $(SERVER_PORT)

dj-makemigrations: # Generate migration scripts
	$(title)
	$(PYTHON) manage.py makemigrations

dj-migrate: # Run migration scripts
	$(title)
	$(PYTHON) manage.py migrate

dj-shell: # Run Django shell
	$(title)
	$(PYTHON) manage.py shell
