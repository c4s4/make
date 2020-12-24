# Parent makefile for Golang projects (https://github.com/c4s4/make)

include ~/.make/Basics.mk
include ~/.make/golang.mk
include ~/.make/github.mk

.PHONY: go-release
go-release: go-version go-test github-release go-deploy go-archive github-upload # Perform a release
	@echo "$(GRE)OK$(END) Release done!"
