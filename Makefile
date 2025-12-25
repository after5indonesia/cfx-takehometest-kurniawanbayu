# ==============================================================================
# VARIABLES
# ==============================================================================
# Change these if necessary or pass them in at runtime (e.g., make deploy ORG=my-org)
ORG ?= $(shell git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\/.*/\1/')
REPO_ROOT := $(shell git rev-parse --show-toplevel)
SHA := $(shell git rev-parse --short HEAD)
REGISTRY := ghcr.io

# Standardize org name to lowercase for Docker tags
ORG_LOWER := $(shell echo $(ORG) | tr '[:upper:]' '[:lower:]')

# ==============================================================================
# TARGETS
# ==============================================================================

.PHONY: help build push deploy clean

# Help acts as the default target if you just run 'make'
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------------------------
# DOCKER
# ------------------------------------------------------------------------------

build: ## Build Docker images for both services
	@echo "Building Go App..."
	docker build -t $(REGISTRY)/$(ORG_LOWER)/go-app:latest ./services/go-app
	@echo "Building Node App..."
	docker build -t $(REGISTRY)/$(ORG_LOWER)/node-app:latest ./services/node-app

push: build ## Push images to GHCR (requires 'docker login ghcr.io' first)
	@echo "Pushing Go App..."
	docker push $(REGISTRY)/$(ORG_LOWER)/go-app:latest
	@echo "Pushing Node App..."
	docker push $(REGISTRY)/$(ORG_LOWER)/node-app:latest

# ------------------------------------------------------------------------------
# KUBERNETES / HELM
# ------------------------------------------------------------------------------

deploy: ## Deploy both services to the current K8s cluster using Helm
	@echo "Deploying Go App..."
	helm upgrade --install go-app ./charts/microservice \
		--set image.repository=$(REGISTRY)/$(ORG_LOWER)/go-app \
		--set image.tag=latest \
		--set service.targetPort=8080 \
		--set ingress.enabled=true \
		--set ingress.hosts[0].host=go.127.0.0.1.xip.io \
		--set ingress.hosts[0].paths[0].path=/

	@echo "Deploying Node App..."
	helm upgrade --install node-app ./charts/microservice \
		--set image.repository=$(REGISTRY)/$(ORG_LOWER)/node-app \
		--set image.tag=latest \
		--set service.targetPort=3000 \
		--set ingress.enabled=true \
		--set ingress.hosts[0].host=node.127.0.0.1.xip.io \
		--set ingress.hosts[0].paths[0].path=/

delete: ## Uninstall the Helm releases
	helm uninstall go-app || true
	helm uninstall node-app || true

# ------------------------------------------------------------------------------
# UTILITIES
# ------------------------------------------------------------------------------

tunnel: ## Minikube tunnel (Run this in a separate terminal if using Minikube)
	@echo "Starting minikube tunnel for LoadBalancer/Ingress..."
	minikube tunnel

logs-go: ## Follow logs for the Go service
	kubectl logs -f -l app.kubernetes.io/instance=go-app

logs-node: ## Follow logs for the Node service
	kubectl logs -f -l app.kubernetes.io/instance=node-app