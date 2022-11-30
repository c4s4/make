# Makefile for cleaning

BUILD_DIR = build

.PHONY: clean
clean: # Clean generated files
	$(title)
	@rm -rf $(BUILD_DIR)
