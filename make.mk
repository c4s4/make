# Makefile for Make (https://github.com/c4s4/make)

MAKE_ID=78076a93b1c9051fa64657cc48836c682ea9e3f4
MAKE_DIR=.make

make: # Build makefile dependencies
	@echo "$(YEL)Building makefile dependencies$(END)"
	@rm -rf $(MAKE_DIR)
	@git clone git@github.com:c4s4/make.git $(MAKE_DIR)
	@cd $(MAKE_DIR) && git checkout $(MAKE_ID)

id: # Print commit id
	@echo "$(YEL)Printing commit id$(END)"
	@ID=`git rev-parse HEAD`; \
	echo "Commit ID: $${ID}"
