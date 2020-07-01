# Parent makefile for Help (https://github.com/c4s4/make)

define title =
	@echo "$(YEL)$(shell make-desc $@)$(END)"
endef

.PHONY: help
help: # Print help on Makefile
	@make-help
