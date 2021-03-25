# Parent makefile for Git (https://github.com/c4s4/make)

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null || echo "")

.PHONY: git-tag
git-tag: # Tag project (you must set TAG=X.Y.Z on command line)
	$(title)
	@test '$(TAG)' != '' || (echo "$(RED)ERROR$(END) You must set TAG=name on command line"; exit 1)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(GIT_BRANCH)' = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git tag -a $(TAG) -m  "Release $(TAG)"
	@git push origin $(TAG)

.PHONY: git-branch
git-branch: # Create a branch from master (you must set BRANCH=name on command line)
	$(title)
	@test '$(BRANCH)' != '' || (echo "$(RED)ERROR$(END) You must set BRANCH=name on command line" && exit 1)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(GIT_BRANCH)' = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git checkout -b $(BRANCH)
	@git push -u origin $(BRANCH)

.PHONY: git-merge-squash
git-merge-squash: # Squash branch and merge on master
	$(title)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test '$(GIT_BRANCH)' != 'master' || (echo "$(RED)ERROR$(END) You already are on branch master" && exit 1)
	@git checkout master
	@git pull
	@git merge --squash $(GIT_BRANCH)
	@git commit
	@git push origin master

.PHONY: git-tags
git-tags: # List tags sorted by version
	$(title)
	@git tag | sort -V

.PHONY: git-id
git-id: # Print commit ID
	$(title)
	@echo "Commit ID: $(shell git rev-parse HEAD)"

.PHONY: git-squash
git-squash: # Squash commits (ACHTUNG! modifies Git history, handle with care)
	$(title)
	@echo -n "Commit ID: "; read commit; git rebase -i $$commit
	@git push --force
