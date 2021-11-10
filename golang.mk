# Parent makefile for Golang projects (https://github.com/c4s4/make)

include ~/.make/basics.mk
include ~/.make/_golang.mk

.DEFAULT_GOAL :=
default: lint test

lint: go-lint
test: go-test
cover: go-cover
release: go-release

.PHONY: go-release
go-release: go-version go-clean go-test github-release go-deploy go-archive github-upload # Perform a release
	@echo "$(GRE)OK$(END) Release done!"
