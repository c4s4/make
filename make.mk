# Makefile for Make (https://github.com/c4s4/make)

MAKE_ID=HEAD
MAKE_DIR=.make
MAKE_URL=git@github.com:c4s4/make.git

make: # Build makefile dependencies for given commit ID
	@echo "$(YEL)Building makefile dependencies for given commit ID$(END)"
	@rm -rf $(MAKE_DIR)
	@git clone $(MAKE_URL) $(MAKE_DIR)
	@cd $(MAKE_DIR); \
	git checkout $(MAKE_ID)

makeid: # Print current make repository commit ID
	@echo "$(YEL)Printing current commit ID$(END)"
	@ID=`git ls-remote $(MAKE_URL) refs/heads/master`; \
	echo "Commit ID: $${ID}"

makeup: # Update make repository to commit ID
	@echo "$(YEL)Updating make repository to commit ID$(END)"
	@cd $(MAKE_DIR); \
	git checkout $(MAKE_ID)
