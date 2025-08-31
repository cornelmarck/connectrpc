# Local Go bin path
BIN_DIR := $(CURDIR)/bin

# Ensure local bin directory is on PATH
export GOBIN := $(BIN_DIR)
export PATH := $(BIN_DIR):$(PATH)

.PHONY: tools
tools:
	@echo "Installing tools..."
	@go install github.com/bufbuild/buf/cmd/buf@latest
	@go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest
	@go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

.PHONY: proto-lint
proto-lint: tools
	@echo "Linting .proto files..."
	@$(BIN_DIR)/buf lint


.PHONY: proto-compile lint
proto-compile: tools proto-lint
	@echo "Compiling .proto files..."
	@$(BIN_DIR)/buf generate

.PHONY: lint
lint:
	@go fmt ./...
	@go vet ./...