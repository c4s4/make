# Parent makefile for Help (https://github.com/c4s4/make)

include ~/.make/color.mk

.PHONY: help
help: # Print help on Makefile
	@make-help
