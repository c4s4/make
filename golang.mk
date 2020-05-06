# Parent makefile for Golang (https://github.com/c4s4/make)

GONAME=$(shell basename $(pwd))
BUILD_DIR=build
GOARGS=
ifeq ($(GOTOOLS), )
	GOTOOLS=$${GOPATH}
endif
TOOLS=github.com/mitchellh/gox \
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

.PHONY: tools
tools: # Install Go tools
	@echo "$(YEL)Installing Go tools$(END)"
	@for tool in $(TOOLS); do \
		echo "Installing $$tool"; \
		GOPATH=$(GOTOOLS) GO111MODULE=off go get -u $$tool; \
	done

.PHONY: fmt
fmt: # Format Go source code
	@echo "$(YEL)Formatting Go source code$(END)"
	@go fmt ./...

.PHONY: build
build: clean # Build binary
	@echo "$(YEL)Building binary$(END)"
	@mkdir -p $(BUILD_DIR)
	@go build -ldflags "-s -f" -o $(BUILD_DIR)/$(GONAME) ./...

.PHONY: binaries
binaries: clean # Build binaries
	@echo "$(YEL)Building binaries$(END)"
	@mkdir -p $(BUILD_DIR)/bin
	@gox -ldflags "-s -f" -output=$(BUILD_DIR)/bin/$(GONAME)-{{.OS}}-{{.Arch}} ./...

.PHONY: install
install: # Install binaries in GOPATH
	@echo "$(YEL)Installing binaries in GOPATH$(END)"
	@cp $(BUILD_DIR)/$(GONAME) $${GOPATH}/bin/

.PHONY: run
run: build # Run project
	@echo "$(YEL)Running project$(END)"
	@$(BUILD_DIR)/$(GONAME) $(GOARGS)

.PHONY: clean
clean: # Clean generated files and test cache
	@echo "$(YEL)Cleaning generated files and test cache$(END)"
	@rm -rf $(BUILD_DIR)
	@go clean -testcache
