# Parent makefile for Golang projects (https://github.com/c4s4/make)

include ~/.make/Basics.mk
include ~/.make/golang.mk

.DEFAULT_GOAL :=
default: check test

check: go-check
test: go-test
cover: go-cover
release: go-release

.PHONY: go-release
go-release: go-version go-clean go-test github-release go-deploy go-archive github-upload # Perform a release
	@echo "$(GRE)OK$(END) Release done!"
