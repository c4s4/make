# Parent makefile for Build (https://github.com/c4s4/make)

.PHONY: doc-running
doc-running: # Ensure docker is running
	@echo "$(YEL)Ensuring docker is running$(END)"
	@if [ `systemctl show --property ActiveState docker` != "ActiveState=active" ]; then \
		echo "Starting docker"; \
		sudo systemctl start docker; \
	else \
		echo "Docker already running"; \
	fi

.PHONY: doc-build
doc-build: docker-running # Build and start docker platform
	@echo "$(YEL)Building and starting docker platform$(END)"
	@docker-compose up --build --force-recreate --remove-orphans --detach

.PHONY: doc-start
doc-start: # Start docker platform
	@echo "$(YEL)Starting docker platform$(END)"
	@docker-compose start

.PHONY: doc-stop
doc-stop: # Stop docker platform
	@echo "$(YEL)Stopping docker platform$(END)"
	@docker-compose stop
