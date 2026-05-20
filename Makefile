.PHONY: build test lint install clean

build:
	go build -o bin/espn-sports-pp-cli ./cmd/espn-sports-pp-cli

test:
	go test ./...

lint:
	golangci-lint run

install:
	go install ./cmd/espn-sports-pp-cli

clean:
	rm -rf bin/

build-mcp:
	go build -o bin/espn-sports-pp-mcp ./cmd/espn-sports-pp-mcp

install-mcp:
	go install ./cmd/espn-sports-pp-mcp

build-all: build build-mcp
