# Local Go bin path
BIN_DIR := $(CURDIR)/bin

# Ensure local bin directory is on PATH
export GOBIN := $(BIN_DIR)
export PATH := $(BIN_DIR):$(PATH)

TOOLS = \
	github.com/bufbuild/buf/cmd/buf@v1.57.0 \
	google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.8 \
	google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1 \
	connectrpc.com/connect/cmd/protoc-gen-connect-go@v1.18.1

.PHONY: tools
tools:
	@for pkg in $(TOOLS); do \
		name=$$(basename $${pkg%@*}); \
		if [ ! -x "$(BIN_DIR)/$$name" ]; then \
			echo "Installing $$name"; \
			go install $$pkg >/dev/null; \
		fi; \
	done

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