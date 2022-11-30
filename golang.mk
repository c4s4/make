# Makefile for Golang

include ~/.make/color.mk
include ~/.make/help.mk

BUILD_DIR = build
GO_BUILD_OPTIONS =
GO_COVER_PKG=./...

.PHONY: clean
clean: # Clean generated files and test cache
	$(title)
	@rm -rf $(BUILD_DIR)
	@go clean -testcache
	@go clean -cache
	@echo "$(GRE)OK$(END) cache cleaned"

.PHONY: fmt
fmt: # Format Go source code
	$(title)
	@gofmt -w .
	@echo "$(GRE)OK$(END) code formatted"

.PHONY: lint
lint: # Check Go code
	$(title)
	@golangci-lint run ./...
	@echo "$(GRE)OK$(END) code checked"

.PHONY: test
test: # Run unit tests
	$(title)
	@go test $(GO_BUILD_OPTIONS) -coverpkg=$(GO_COVER_PKG) -cover ./...
	@echo "$(GRE)OK$(END) tests passed"

.PHONY: cover
cover: # Generate unit tests coverage report and show in browser
	$(title)
	@mkdir -p $(BUILD_DIR)
	@go test $(GO_BUILD_OPTIONS) -coverpkg=$(GO_COVER_PKG) -coverprofile $(BUILD_DIR)/cover.out ./...
	@go tool cover -html=$(BUILD_DIR)/cover.out -o $(BUILD_DIR)/coverage.html
	@go tool cover -html=$(BUILD_DIR)/cover.out

.PHONY: build
build: # Build binary
	$(title)
	@mkdir -p $(BUILD_DIR)
	@go build $(GO_BUILD_OPTIONS) -ldflags "-s -f" -o $(BUILD_DIR)/ ./...
	@echo "$(GRE)OK$(END) binary built"

.PHONY: run
run: build # Run project
	$(title)
	@$(BUILD_DIR)/$(PROJECT_NAME)

.PHONY: gobinsec
gobinsec: build # Check binary for vulnerabilities
	$(title)
	@gobinsec -config .gobinsec.yml -wait $(shell find $(BUILD_DIR)/* -perm -u+x)
