# Makefile for Help

define title =
	@echo "$(bYEL)$(bla) $@ $(END) $(YEL)$(shell make-desc $@ 2> /dev/null)$(END)"
endef

.PHONY: help
help: # Print help on Makefile
	@make-help -mute
