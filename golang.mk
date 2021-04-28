# Parent makefile for Golang (https://github.com/c4s4/make)

BUILD_DIR = "build"
VERSION = "UNKNOWN"
GONAME = $(shell basename `pwd`)
GOPACKAGE = "./..."
GOARGS =
ARCHIVE = "$(GONAME)-$(VERSION).tar.gz"
GODEST = "casa@sweetohm.net:/home/web/dist"
GOCYCLO = 15
GOOSARCH = $(shell go tool dist list | grep -v android)
GOTOOLBOX = \
	github.com/mitchellh/gox \
    github.com/itchio/gothub \
    golang.org/x/tools/gopls \
    golang.org/x/lint/golint \
    github.com/fzipp/gocyclo/cmd/gocyclo \
    github.com/gordonklaus/ineffassign \
    github.com/client9/misspell/cmd/misspell
ifeq ($(GOTOOLS), )
	GOTOOLS = $${GOPATH}
endif

.PHONY: go-tools
go-tools: # Install Go tools
	$(title)
	@for tool in $(GOTOOLBOX); do \
		echo "Installing $$tool"; \
		GOPATH=$(GOTOOLS) go get -u $$tool; \
	done

.PHONY: go-clean
go-clean: # Clean generated files and test cache
	$(title)
	@rm -rf $(BUILD_DIR)
	@go clean -testcache
	@go clean -cache

.PHONY: go-fmt
go-fmt: # Format Go source code
	$(title)
	@go fmt $(GOPACKAGE)

.PHONY: go-check
go-check: # Check Go code
	$(title)
	@mkdir -p $(BUILD_DIR)
	@echo "Checking code with fmt"
	@gofmt -l $(shell find . -name "*.go") > /tmp/gofmt.log
	@if [ -s /tmp/gofmt.log ]; then \
		echo "$(RED)ERROR$(END) in file(s) $(shell cat /tmp/gofmt.log)"; \
		exit 1; \
	fi
	@echo "Checking code with golint"
	@golint $(GOPACKAGE)
	@echo "Checking code with vet"
	@go vet $(GOPACKAGE)
	@echo "Checking code with gocyclo"
	@gocyclo -over $(GOCYCLO) $(shell find . -name "*.go")
	@echo "Checking code with ineffassign"
	@ineffassign $(shell find . -name "*.go")
	@echo "Checking code with misspell"
	@misspell $(shell find . -name "*.go")
	@echo "$(GRE)OK$(END) Go code checked"

.PHONY: go-test
go-test: # Run tests
	$(title)
	@go test -cover $(GOPACKAGE)
	@echo "$(GRE)OK$(END) tests passed"

go-version: # Check that version was passed on command line
	$(title)
	@if [ "$(VERSION)" = "UNKNOWN" ]; then \
		echo "$(RED)ERROR$(END) you must pass VERSION=X.Y.Z on command line to release"; \
		exit 1; \
	fi

.PHONY: go-build
go-build: go-clean # Build binary
	$(title)
	@mkdir -p $(BUILD_DIR)
	@go build -ldflags "-X main.Version=$(VERSION) -s -f" -o $(BUILD_DIR)/$(GONAME) $(GOPACKAGE)

.PHONY: go-binaries
go-binaries: go-clean # Build binaries
	$(title)
	@mkdir -p $(BUILD_DIR)/bin
	@gox -ldflags "-X main.Version=$(VERSION) -s -f" -osarch '$(GOOSARCH)' -output=$(BUILD_DIR)/bin/{{.Dir}}-{{.OS}}-{{.Arch}} $(GOPACKAGE)

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
	@mkdir -p $(BUILD_DIR)/$(GONAME)-$(VERSION)
	@mv $(BUILD_DIR)/bin $(BUILD_DIR)/$(GONAME)-$(VERSION)
	@mv $(BUILD_DIR)/README.pdf $(BUILD_DIR)/LICENSE.txt $(BUILD_DIR)/$(GONAME)-$(VERSION)
	@cd $(BUILD_DIR) && tar cvf $(GONAME)-$(VERSION).tar $(GONAME)-$(VERSION)/ && gzip $(GONAME)-$(VERSION).tar

.PHONY: go-tag
go-tag: go-version # Tag project
	$(title)
	@git diff-index --quiet HEAD -- || (echo "$(RED)ERROR$(END) There are uncommitted changes" && exit 1)
	@test `git rev-parse --abbrev-ref HEAD` = 'master' || (echo "$(RED)ERROR$(END) You are not on branch master" && exit 1)
	@git tag -a $(VERSION) -m  "Release $(TAG)"
	@git push origin $(TAG)

.PHONY: go-docker
go-docker: go-clean # Build docker image
	$(title)
	@mkdir -p $(BUILD_DIR)
	@CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-X main.Version=$(VERSION) -s -f" -o $(BUILD_DIR)/$(GONAME) .
	@if [ "$(VERSION)" = "UNKNOWN" ]; then \
		docker build -t casa/$(GONAME) .; \
	else \
		docker build -t casa/$(GONAME):$(VERSION) .; \
		docker tag casa/$(GONAME):$(VERSION) casa/$(GONAME):latest; \
	fi

.PHONY: go-publish
go-publish: go-docker # Publish docker image
	$(title)
	@if [ "$(VERSION)" = "UNKNOWN" ]; then \
		docker push casa/$(GONAME); \
	else \
		docker push casa/$(GONAME):$(VERSION); \
		docker push casa/$(GONAME):latest; \
	fi
