# Parent makefile for Git (https://github.com/c4s4/make)
# This makefile calls gothub: https://github.com/itchio/gothub

GITHUB_USER = "c4s4"
GITHUB_REPO = $(shell basename `pwd`)
GITHUB_TOKEN = "abcdefghijklmnopqrstuvwxyz0123456789"

github-title: # Prompt for release title
	$(title)

github-changes: # Prompt for changes
	$(title)

github-release: github-title github-changes # Create Github release
	$(title)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test `git rev-parse --abbrev-ref HEAD` = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@read -p "Release Title: " RELEASE_TITLE; \
	read -p "Release Changes: " RELEASE_DESC; \
	gothub release --user "$(GITHUB_USER)" \
	               --repo "$(GITHUB_REPO)" \
				   --security-token "$(GITHUB_TOKEN)" \
				   --tag "$(VERSION)" \
				   --name "$$RELEASE_TITLE" \
				   --description "$$RELEASE_DESC"

github-upload: # Upload an artifact
	$(title)
	@gothub upload --user "$(GITHUB_USER)" \
	               --repo "$(GITHUB_REPO)" \
				   --security-token "$(GITHUB_TOKEN)" \
				   --tag "$(VERSION)" \
	               --name "$(ARCHIVE)" \
				   --file "$(BUILD_DIR)/$(ARCHIVE)"
