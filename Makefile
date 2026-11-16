IMG ?= synthetic-module-operator:latest
CONTAINER_TOOL ?= podman
LOCALBIN ?= $(CURDIR)/bin
CONTROLLER_GEN ?= $(LOCALBIN)/controller-gen
CONTROLLER_GEN_VERSION ?= v0.17.3

.PHONY: build generate test fmt vet image

build:
	mkdir -p $(LOCALBIN)
	CGO_ENABLED=0 go build -trimpath -o $(LOCALBIN)/synthetic-module ./cmd

generate: $(CONTROLLER_GEN)
	$(CONTROLLER_GEN) object:headerFile=hack/boilerplate.go.txt paths=./...
	$(CONTROLLER_GEN) crd paths=./api/... output:crd:artifacts:config=config/crd

$(CONTROLLER_GEN):
	mkdir -p $(LOCALBIN)
	GOBIN=$(LOCALBIN) go install sigs.k8s.io/controller-tools/cmd/controller-gen@$(CONTROLLER_GEN_VERSION)

test:
	go test ./...

fmt:
	gofmt -w api cmd internal

vet:
	go vet ./...

image:
	$(CONTAINER_TOOL) build -f Dockerfile -t $(IMG) .
