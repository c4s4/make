# Makefile for Make (https://github.com/c4s4/make)

MAKE_ID=PUT_HERE_COMMIT_ID_OF_MAKE_REPO
MAKE_DIR=.make
MAKE_REPO=~/.make
MAKE_URL=git@github.com:c4s4/make.git

make: # Build makefile dependencies for given commit ID
	@echo "$(YEL)Building makefile dependencies for given commit ID$(END)"
	@rm -rf $(MAKE_DIR)
	@git clone $(MAKE_URL) $(MAKE_DIR)
	@cd $(MAKE_DIR) && git checkout $(MAKE_ID)

makeid: # Print current make repository commit ID
	@echo "$(YEL)Printing current commit ID$(END)"
	@cd $(MAKE_REPO); \
	ID=`git rev-parse HEAD`; \
	echo "Commit ID: $${ID}"

makeup: # Update make repository
	@echo "$(YEL)Updating make repository$(END)"
	@cd $(MAKE_REPO); \
	git pull --rebase
