# Makefile for Oracle (https://github.com/c4s4/make)
# Procedure to build Oracle XE database from
# https://mobiliardbblog.wordpress.com/2017/10/27/oracle-xe-docker-image-including-database-in-less-than-1-4gb-yes-you-can/
# Database images at
# https://www.oracle.com/database/technologies/oracle-database-software-downloads.html

BUILD_DIR=build
ORACLE_VER=11.2.0.2
ORACLE_BASE=-x
ORACLE_URL=https://www.oracle.com/database/technologies/xe-downloads.html
ORACLE_RPM=oracle-xe-11.2.0-1.0.x86_64.rpm.zip
ORACLE_SID=XE
ORACLE_PDB=test
ORACLE_PWD=test
ORACLE_CHAR=AL32UTF8
DOCKER_USER=casa
DOCKER_NAME=oracle
# For Oracle XE 18
# ORACLE_VER=18.4.0
# ORACLE_RPM=oracle-database-xe-18c-1.0-1.x86_64.rpm

.PHONY: ora-image
ora-image: clean # Build image for Oracle database
	$(title)
	@test -f /tmp/$(ORACLE_RPM) || (echo "$(RED)ERROR$(END): You must have downloaded oracle database at $(ORACLE_URL)"; exit 1)
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR); \
	git clone git@github.com:oracle/docker-images.git; \
	cp /tmp/$(ORACLE_RPM) docker-images/OracleDatabase/SingleInstance/dockerfiles/$(ORACLE_VER)/; \
	cd docker-images/OracleDatabase/SingleInstance/dockerfiles; \
	./buildDockerImage.sh -v $(ORACLE_VER) $(ORACLE_BASE); \
	docker tag oracle/database:$(ORACLE_VER)-xe $(DOCKER_USER)/oracle:$(ORACLE_VER)-xe; \
	docker push $(DOCKER_USER)/oracle

.PHONY: ora-run
ora-run: # Run Oracle database
	$(title)
	@docker run --name $(DOCKER_NAME) \
		-p 1521:1521 -p 5500:5500 \
		-e ORACLE_SID=$(ORACLE_SID) \
		-e ORACLE_PDB=$(ORACLE_PDB) \
		-e ORACLE_PWD=$(ORACLE_PWD) \
		-e ORACLE_CHARACTERSET=$(ORACLE_CHAR) \
		-v /opt/oracle/oradata \
		--shm-size=1g \
		$(DOCKER_USER)/oracle:$(ORACLE_VER)-xe

.PHONY: ora-start
ora-start: # Start Oracle database
	$(title)
	@docker start $(DOCKER_NAME)

.PHONY: ora-stop
ora-stop: # Stop Oracle database
	$(title)
	@docker stop $(DOCKER_NAME)

.PHONY: ora-sqlplus
ora-sqlplus: # Generate sqlplus script
	$(title)
	@echo '#!/bin/sh\n# Default connection URL: system/$(ORACLE_PWD)@$(ORACLE_SID)\n\nset -e\n\ndocker exec -i $(DOCKER_NAME) sqlplus "$$@" < /dev/stdin' > sqlplus
	@chmod +x sqlplus
