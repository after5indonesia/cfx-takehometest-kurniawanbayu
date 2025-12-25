# Monorepo Microservices Deployment

This repository contains a solution for managing a Go service and a Node.js service within a monorepo, utilizing Kubernetes for orchestration and GitHub Actions for CI/CD.

## 🏗 Architecture
* **Monorepo Strategy:** Codebases are separated by folder (`services/go-app`, `services/node-app`).
* **Containerization:** Docker multi-stage builds are used for the Go app to ensure a minimal footprint (Alpine).
* **Orchestration:** Kubernetes Deployments ensure high availability (2 replicas) and Services expose the apps internally.
* **Ingress:** An Ingress controller routes external traffic to the correct service based on the hostname.

## 🚀 CI/CD Pipeline (GitHub Actions)
The pipeline is defined in `.github/workflows/ci-cd.yaml`.

1.  **Change Detection:** The pipeline uses a matrix strategy but includes a `git diff` check. It only builds and pushes a Docker image if code *within that specific service's folder* has changed.
2.  **Build & Push:** Images are built and pushed to GitHub Container Registry (ghcr.io).
3.  **Deploy:** Applies the Kubernetes manifests (Deployment, Service, Ingress) to the cluster.

## 🛠 How to Run

### Prerequisites
* Docker Desktop (with Kubernetes enabled) or Minikube.
* Nginx Ingress Controller enabled (`minikube addons enable ingress`).

### Steps
1.  **Build Images:**
    ```bash
    docker build -t go-app services/go-app
    docker build -t node-app services/node-app
    ```
2.  **Deploy to K8s:**
    ```bash
    kubectl apply -f k8s/
    ```
3.  **Access Services (Publicly via xip.io):**
    * **Go Service:** `http://go.127.0.0.1.xip.io`
    * **Node Service:** `http://node.127.0.0.1.xip.io`