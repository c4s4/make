# Parent makefile for Build (https://github.com/c4s4/make)

.PHONY: doc-running
doc-running: # Ensure docker is running
	$(title)
	@if [ `systemctl show --property ActiveState docker` != "ActiveState=active" ]; then \
		echo "Starting docker"; \
		sudo systemctl start docker; \
	else \
		echo "Docker already running"; \
	fi

.PHONY: doc-build
doc-build: # Build and start docker platform
	$(title)
	@docker-compose up --build --force-recreate --remove-orphans --detach

.PHONY: doc-start
doc-start: # Start docker platform
	$(title)
	@docker-compose start

.PHONY: doc-stop
doc-stop: # Stop docker platform
	$(title)
	@docker-compose stop

.PHONY: doc-logs
doc-logs: # Print logs of containers
	$(title)
	@docker-compose logs -f
