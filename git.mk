# Parent makefile for Git (https://github.com/c4s4/make)

CURRENT := $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: tag
tag: # Tag project (you must set TAG=X.Y.Z on command line)
	@echo "$(YEL)Tagging project$(END)"
	@test '$(TAG)' != '' || (echo "$(RED)ERROR$(END) You must set TAG=name on command line"; exit 1)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(CURRENT)' = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git tag -a $(TAG) -m  "Release $(TAG)"
	@git push origin $(TAG)

.PHONY: branch
branch: # Create a branch from master (you must set BRANCH=name on command line)
	@echo "$(YEL)Creating a branch from master$(END)"
	@test '$(BRANCH)' != '' || (echo "$(RED)ERROR$(END) You must set BRANCH=name on command line" && exit 1)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(CURRENT)' = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git checkout -b $(BRANCH)
	@git push -u origin $(BRANCH)

.PHONY: squash
squash: # Squash branch and merge on master
	@echo "$(YEL)Squash branch and merge on master$(END)"
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(CURRENT)' != 'master' || (echo "$(RED)ERROR$(END) You already are on branch master" && exit 1)
	@git checkout master
	@git pull
	@git merge --squash $(CURRENT)
	@git commit
	@git push origin master
