# Makefile for Make (https://github.com/c4s4/make)

MAKE_ID=HEAD
MAKE_DIR=.make
MAKE_URL=git@github.com:c4s4/make.git

.PHONY: make
make: # Build makefile dependencies for given commit ID
	$(title)
	@rm -rf $(MAKE_DIR)
	@git clone $(MAKE_URL) $(MAKE_DIR)
	@cd $(MAKE_DIR); \
	git checkout $(MAKE_ID)

.PHONY: make-id
make-id: # Print current make repository commit ID
	$(title)
	@ID=`git ls-remote $(MAKE_URL) refs/heads/master`; \
	echo "Commit ID: $${ID}"

.PHONY: make-up
make-up: # Update make repository to commit ID
	$(title)
	@cd $(MAKE_DIR); \
	git checkout $(MAKE_ID)
