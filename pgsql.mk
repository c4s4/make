# Parent makefile for PostgreSQL (https://github.com/c4s4/make)

# to initialize PostgreSQL database:
# sudo su - postgres
# psql
# CREATE DATABASE myproject;
# CREATE USER myprojectuser WITH PASSWORD 'password';
# ALTER ROLE myprojectuser SET client_encoding TO 'utf8';
# ALTER ROLE myprojectuser SET default_transaction_isolation TO 'read committed';
# ALTER ROLE myprojectuser SET timezone TO 'UTC';
# GRANT ALL PRIVILEGES ON DATABASE myproject TO myprojectuser;

# to avoid typing your password, you should write ~/.pgpass file such as:
# hostname:port:database:username:password

# following connection variables should be set in .env file imported with:
# include .env
# export
PGSQL_HOSTNAME=localhost
PGSQL_PORT=5432
PGSQL_DATABASE=database
PGSQL_USERNAME=username
PGSQL_BACKUP_DIR=.

.PHONY: pgsql-shell
pgsql-shell: # Run a PostgreSQL shell
	$(title)
	psql -h $(PGSQL_HOSTNAME) -p $(PGSQL_PORT) -d $(PGSQL_DATABASE) -U $(PGSQL_USERNAME) -w

.PHONY: pgsql-backup
pgsql-backup: # Backup PostgreSQL database
	$(title)
	pg_dump -h $(PGSQL_HOSTNAME) -p $(PGSQL_PORT) -d $(PGSQL_DATABASE) -U $(PGSQL_USERNAME) -w -F tar -f $(PGSQL_BACKUP_DIR)/$(PGSQL_DATABASE)-$(shell date +%Y-%m-%d=%H-%M-%S).tar
	gzip $(PGSQL_BACKUP_DIR)/$(PGSQL_DATABASE)-*.tar

.PHONY: pgsql-restore
pgsql-restore: # Restore PostgreSQL database
	$(title)
	echo "Available backup files:"
	@ls -1 $(PGSQL_BACKUP_DIR)/$(PGSQL_DATABASE)-*.tar.gz
	@echo "Type file name to restore:"
	@read file; \
	gunzip -c $$file | pg_restore -h $(PGSQL_HOSTNAME) -p $(PGSQL_PORT) -d $(PGSQL_DATABASE) -U $(PGSQL_USERNAME) -w -c
