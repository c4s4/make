# Makefile for Oracle (https://github.com/c4s4/make)
# Procedure to build Oracle XE database from
# https://mobiliardbblog.wordpress.com/2017/10/27/oracle-xe-docker-image-including-database-in-less-than-1-4gb-yes-you-can/

include ~/.make/clean.mk

ORACLE_VER=18.4.0
ORACLE_BASE=-x
ORACLE_URL=https://www.oracle.com/database/technologies/xe-downloads.html
ORACLE_RPM=oracle-database-xe-18c-1.0-1.x86_64.rpm
ORACLE_SID=test
ORACLE_PDB=test
ORACLE_PWD=test
ORACLE_CHAR=AL32UTF8
DOCKER_USER=casa

ora-image: clean # Build image for Oracle database
	@echo "$(YEL)Building image for Oracle database$(END)"
	@test -f /tmp/$(ORACLE_RPM) || (echo "$(RED)ERROR$(END): You must have downloaded oracle database at $(ORACLE_URL)"; exit 1)
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR); \
	git clone git@github.com:oracle/docker-images.git; \
	cp /tmp/$(ORACLE_RPM) docker-images/OracleDatabase/dockerfiles/$(ORACLE_VER)/; \
	cd docker-images/OracleDatabase/SingleInstance/dockerfiles; \
	./buildDockerImage.sh -v $(ORACLE_VER) $(ORACLE_BASE); \
	docker tag oracle/database:$(ORACLE_VER)-xe $(DOCKER_USER)/oracle:$(ORACLE_VER)-xe; \
	docker push $(DOCKER_USER)/oracle

ora-client: clean # Build image for Oracle client
	@echo "$(YEL)Building image for Oracle client$(END)"
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR); \
	git clone git@github.com:oracle/docker-images.git; \
	cd docker-images/OracleInstantClient/dockerfiles/18; \
	docker build --pull -t oracle/instantclient:18 .; \
	docker tag oracle/instantclient:18 casa/oracle-client:18; \
	docker push $(DOCKER_USER)/oracle-client

ora-start: # Start Oracle database
	@echo "$(YEL)Starting Oracle database$(END)"
	@docker run --name oracle \
		-p 1521:1521 -p 5500:5500 \
		-e ORACLE_SID=$(ORACLE_SID) \
		-e ORACLE_PDB=$(ORACLE_PDB) \
		-e ORACLE_PWD=$(ORACLE_PWD) \
		-e ORACLE_CHARACTERSET=$(ORACLE_CHAR) \
		-v /opt/oracle/oradata \
		$(DOCKER_USER)/oracle:$(ORACLE_VER)-xe

ora-stop: # Stop Oracle database
	@echo "$(YEL)Stopping Oracle database$(END)"
	@docker stop oracle
