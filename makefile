# Local Go bin path
BIN_DIR := $(CURDIR)/bin

# Ensure local bin directory is on PATH
export GOBIN := $(BIN_DIR)
export PATH := $(BIN_DIR):$(PATH)

TOOLS = \
	github.com/bufbuild/buf/cmd/buf@v1.57.0 \
	google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.8 \
	google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.5.1 \
	connectrpc.com/connect/cmd/protoc-gen-connect-go@v1.18.1 \
	github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.27.2

# Docker / GAR variables
PROJECT_ID := homelab-464022
REGION := us-east1
REPO := homelab-repo
IMAGE_NAME := connectserver
TAG := latest
FULL_IMAGE := $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO)/$(IMAGE_NAME):$(TAG)

# -------------------------------
# Go / Proto targets
# -------------------------------

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

.PHONY: build
build:
	@go build -o bin/connectserver ./cmd/connectserver

.PHONY: run
run: build
	@./bin/connectserver

# -------------------------------
# Docker / GAR targets
# -------------------------------

.PHONY: docker-build
docker-build: build
	@docker build -t $(IMAGE_NAME) .

.PHONY: docker-tag
docker-tag: docker-build
	@docker tag $(IMAGE_NAME) $(FULL_IMAGE)

.PHONY: docker-push
docker-push: docker-tag
	@echo "Pushing $(FULL_IMAGE) to Artifact Registry..."
	@docker push $(FULL_IMAGE)

# Shortcut: build, tag, push in one step
.PHONY: deploy
deploy: docker-push
	@echo "Deployment complete: $(FULL_IMAGE)"
