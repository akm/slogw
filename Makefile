.PHONY: default
default: build lint test

.PHONY: build
build:
	go build ./...

GOLANG_TOOL_PATH_TO_BIN=$(shell go env GOPATH)
GOLANGCI_LINT_CLI_VERSION?=latest
GOLANGCI_LINT_CLI_MODULE=github.com/golangci/golangci-lint/cmd/golangci-lint
GOLANGCI_LINT_CLI=$(GOLANG_TOOL_PATH_TO_BIN)/bin/golangci-lint
$(GOLANGCI_LINT_CLI):
	go install $(GOLANGCI_LINT_CLI_MODULE)@$(GOLANGCI_LINT_CLI_VERSION)

.PHONY: lint
lint: $(GOLANGCI_LINT_CLI)
	golangci-lint run


GODOC_CLI_VERSION=latest
GODOC_CLI_MODULE=golang.org/x/tools/cmd/godoc
GODOC_CLI=$(GOLANG_TOOL_PATH_TO_BIN)/bin/godoc
$(GODOC_CLI):
	go install $(GODOC_CLI_MODULE)@$(GODOC_CLI_VERSION)

.PHONY: godoc
godoc: $(GODOC_CLI)
	@echo "Open http://localhost:6060/pkg/github.com/akm/slogctx"
	godoc -http=:6060


GO_TEST_OPTIONS?=

.PHONY: test
test:
	go test $(GO_TEST_OPTIONS) ./...

GO_COVERAGE_HTML?=coverage.html
GO_COVERAGE_PROFILE?=coverage.txt
$(GO_COVERAGE_PROFILE):
	$(MAKE) test-with-coverage

# See https://app.codecov.io/github/akm/go-requestid/new
.PHONY: test-with-coverage
test-with-coverage:
	GO_TEST_OPTIONS="-coverprofile=$(GO_COVERAGE_PROFILE)" \
	$(MAKE) test

.PHONY: test-coverage
test-coverage: $(GO_COVERAGE_PROFILE)
	go tool cover -html=$(GO_COVERAGE_PROFILE) -o $(GO_COVERAGE_HTML)
	@command -v open && open $(GO_COVERAGE_HTML) || echo "open $(GO_COVERAGE_HTML)"

METADATA_YAML=.project.yaml
$(METADATA_YAML): metadata-gen

METADATA_LINTERS=$(shell cat .golangci.yml | yq '... comments="" | .linters.enable | length')
.PHONY: metadata-gen
metadata-gen: 
	@echo "linters: $(METADATA_LINTERS)" > $(METADATA_YAML)

.PHONY: clean
clean:
	rm -f $(GO_COVERAGE_HTML) $(GO_COVERAGE_PROFILE)

.PHONY: clobber
clobber: clean
	rm -f $(METADATA_YAML)
