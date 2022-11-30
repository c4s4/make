# Parent makefile for Build (https://github.com/c4s4/make)

.PHONY: doc-build
doc-build: # Build and start docker platform
	$(title)
	@docker-compose up --build --force-recreate --remove-orphans --detach

.PHONY: doc-start
doc-start: # Start docker platform
	$(title)
	@docker-compose up -d

.PHONY: doc-stop
doc-stop: # Stop docker platform
	$(title)
	@docker-compose down

.PHONY: doc-logs
doc-logs: # Print logs of containers
	$(title)
	@docker-compose logs -f
