# Parent makefile for Help (https://github.com/c4s4/make)

define title =
	@echo "$(bYEL)$(bla) $@ $(END) $(YEL)$(shell make-desc $@)$(END)"
endef

.PHONY: help
help: # Print help on Makefile
	@make-help -root -mute
