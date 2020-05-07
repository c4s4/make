# Parent makefile for Build (https://github.com/c4s4/make)

BUILD_DIR=build

.PHONY: clean
clean: # Clean generated files
	@echo "$(YEL)Deleting generated files$(END)"
	@rm -rf $(BUILD_DIR)
