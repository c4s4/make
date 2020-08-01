# Parent makefile for Golang (https://github.com/c4s4/make)

BUILD_DIR=build
VERSION=
GONAME=$(shell basename `pwd`)
GOARGS=
GODEST="casa@sweetohm.net:/home/web/dist"
ifeq ($(GOTOOLS), )
	GOTOOLS=$${GOPATH}
endif
GOTOOLBOX=github.com/mitchellh/gox \
          github.com/itchio/gothub \
          github.com/fzipp/gocyclo \
          golang.org/x/lint/golint \
          github.com/gordonklaus/ineffassign \
          github.com/client9/misspell/cmd/misspell \
          github.com/acroca/go-symbols \
          github.com/cweill/gotests/... \
          github.com/davidrjenni/reftools/cmd/fillstruct \
          github.com/fatih/gomodifytags \
          github.com/go-delve/delve/cmd/dlv \
          github.com/godoctor/godoctor \
          github.com/haya14busa/goplay/cmd/goplay \
          github.com/josharian/impl \
          github.com/mdempsky/gocode \
          github.com/ramya-rao-a/go-outline \
          github.com/rogpeppe/godef \
          github.com/sqs/goreturns \
          github.com/stamblerre/gocode \
          github.com/uudashr/gopkgs/cmd/gopkgs \
          golang.org/x/tools/cmd/gorename \
          golang.org/x/tools/cmd/guru \
          golang.org/x/tools/gopls \

.PHONY: go-tools
go-tools: # Install Go tools
	$(title)
	@for tool in $(GOTOOLBOX); do \
		echo "Installing $$tool"; \
		GOPATH=$(GOTOOLS) GO111MODULE=off go get -u $$tool; \
	done

.PHONY: go-clean
go-clean: # Clean generated files and test cache
	$(title)
	@rm -rf $(BUILD_DIR)
	@go clean -testcache

.PHONY: go-fmt
go-fmt: # Format Go source code
	$(title)
	@go fmt ./...

.PHONY: go-test
go-test: # Run tests
	$(title)
	@go test -cover ./...

.PHONY: go-build
go-build: go-clean # Build binary
	$(title)
	@mkdir -p $(BUILD_DIR)
	@go build -ldflags "-X main.Version=$(VERSION) -s -f" -o $(BUILD_DIR)/$(GONAME) ./...

.PHONY: go-binaries
go-binaries: go-clean # Build binaries
	$(title)
	@mkdir -p $(BUILD_DIR)/bin
	@gox -ldflags "-X main.Version=$(VERSION) -s -f" -output=$(BUILD_DIR)/bin/$(GONAME)-{{.OS}}-{{.Arch}} ./...

.PHONY: go-run
go-run: go-build # Run project
	$(title)
	@$(BUILD_DIR)/$(GONAME) $(GOARGS)

.PHONY: go-install
go-install: go-build # Install binaries in GOPATH
	$(title)
	@cp $(BUILD_DIR)/$(GONAME) $${GOPATH}/bin/

.PHONY: go-deploy
go-deploy: go-binaries # Deploy binaries on server
	$(title)
	@scp install $(BUILD_DIR)/bin/* $(GODEST)/$(GONAME)/

.PHONY: go-doc
go-doc: # Generate documentation
	$(title)
	@mkdir -p $(BUILD_DIR)
	@cp LICENSE.txt $(BUILD_DIR)
	@md2pdf -o $(BUILD_DIR)/README.pdf README.md

.PHONY: go-archive
go-archive: go-binaries go-doc # Build distribution archive
	$(title)
	@mkdir -p $(BUILD_DIR)/$(GONAME)
	@mv $(BUILD_DIR)/bin $(BUILD_DIR)/$(GONAME)-$(VERSION)
	@mv $(BUILD_DIR)/README.pdf $(BUILD_DIR)/LICENSE.txt $(BUILD_DIR)/$(GONAME)-$(VERSION)
	@cd $(BUILD_DIR) && tar cvf $(GONAME)-$(VERSION).tar $(GONAME)-$(VERSION)/ && gzip $(GONAME)-$(VERSION).tar

.PHONY: go-tag
go-tag: # Tag project
	$(title)
	@test '$(VERSION)' != '' || (echo "$(RED)ERROR$(END) You must set TAG=name on command line"; exit 1)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test `git rev-parse --abbrev-ref HEAD)` = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git tag -a $(VERSION) -m  "Release $(TAG)"
	@git push origin $(TAG)

.PHONY: go-release
go-release: go-tag go-deploy go-archive # Perform a release
	@echo "$(GRE)OK$(EBD) Release done!"
