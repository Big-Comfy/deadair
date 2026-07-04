BIN     := deadair
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
LDFLAGS := -s -w -X github.com/Big-Comfy/deadair/internal/cli.Version=$(VERSION)
DIST    := dist

DARWIN_ARM64 := $(DIST)/$(BIN)_$(VERSION)_darwin-arm64
LINUX_AMD64  := $(DIST)/$(BIN)_$(VERSION)_linux-amd64
LINUX_ARM64  := $(DIST)/$(BIN)_$(VERSION)_linux-arm64

COMPOSE := docker compose -f integration/docker-compose.yml
OPENSEARCH_COMPOSE := docker compose -f integration/opensearch-docker-compose.yml

.PHONY: build test vet fmt check release integration elastic-integration integration-up integration-test integration-down opensearch-integration opensearch-integration-up opensearch-integration-test opensearch-integration-down

build:
	CGO_ENABLED=0 go build -trimpath -ldflags '$(LDFLAGS)' -o bin/$(BIN) ./cmd/deadair

release:
	mkdir -p $(DIST)
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags '$(LDFLAGS)' -o $(DARWIN_ARM64) ./cmd/deadair
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags '$(LDFLAGS)' -o $(LINUX_AMD64) ./cmd/deadair
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -trimpath -ldflags '$(LDFLAGS)' -o $(LINUX_ARM64) ./cmd/deadair
	(cd $(DIST) && shasum -a 256 $(notdir $(DARWIN_ARM64)) $(notdir $(LINUX_AMD64)) $(notdir $(LINUX_ARM64)) > checksums.txt)

test:
	go test -race ./...

vet:
	go vet ./...

fmt:
	gofmt -l -w .

check: vet test
	@test -z "$$(gofmt -l .)" || (echo "gofmt needed:"; gofmt -l .; exit 1)

integration-up:
	$(COMPOSE) up -d --wait

integration-test:
	go test -tags=integration -count=1 -v ./integration -run TestElastic

integration-down:
	$(COMPOSE) down -v

elastic-integration: integration-up integration-test integration-down

opensearch-integration-up:
	$(OPENSEARCH_COMPOSE) up -d --wait

opensearch-integration-test:
	go test -tags=integration -count=1 -v ./integration -run TestOpenSearch

opensearch-integration-down:
	$(OPENSEARCH_COMPOSE) down -v

opensearch-integration: opensearch-integration-up opensearch-integration-test opensearch-integration-down

fleet-integration:
	$(COMPOSE) up -d --wait
	$(OPENSEARCH_COMPOSE) up -d --wait
	go test -tags=integration -count=1 -v ./integration -run TestFleet
	$(OPENSEARCH_COMPOSE) down -v
	$(COMPOSE) down -v

integration: elastic-integration opensearch-integration fleet-integration
