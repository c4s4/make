include *.mk

release: # Perform a release
	@echo "$(YEL)Performing a release$(END)"
	@read -p "Version: " VERSION; \
	git tag -a $${VERSION} -m  "Release $${VERSION}"; \
	git push origin $${VERSION}
