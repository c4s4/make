BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

release: # Perform a release
	@echo "$(YEL)Performing release$(END)"
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test $(BRANCH) = "master" || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 2)
	@read -p "Version: " VERSION; \
	git tag -a $${VERSION} -m  "Release $${VERSION}"; \
	git push origin $${VERSION}

branch: # Create a branch from master
	@echo "$(YEL)Creating a branch from master$(END)"
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test $(BRANCH) = "master" || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 2)
	@read -p "Branch: " BRANCH; \
	git checkout -b $${BRANCH}; \
	git push -u origin $${BRANCH}

squash: # Squash branch and merge on master
	@echo "$(YEL)Squash branch and merge on master$(END)"
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test $(BRANCH) = "master" && (echo "$(RED)ERROR$(END) You already are on branch master" && exit 2)
	@git checkout master
	@git pull
	@git merge --squash $(BRANCH)
	@git commit
	@git push origin master
