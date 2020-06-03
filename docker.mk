# Parent makefile for Build (https://github.com/c4s4/make)

.PHONY: docker
docker: # Ensure docker is started
	@echo "$(YEL)Ensuring docker is started$(END)"
	@if [ `systemctl show --property ActiveState docker` != "ActiveState=active" ]; then \
		echo "Starting docker"; \
		sudo systemctl start docker; \
	else \
		echo "Docker already running"; \
	fi
