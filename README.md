
```markdown
# 🚀 Monorepo Microservices: Go & Node.js on Kubernetes

This repository is a solution for a DevOps technical test. It demonstrates a **Monorepo** architecture containing two backend services (Go and Node.js), orchestrated by **Kubernetes (Helm)**, and automated via **GitHub Actions**.

## 🏗 Architecture & Features

* **Monorepo Structure:** distinct microservices (`go-app`, `node-app`) managed in a single repo.
* **Containerization:** Optimized Dockerfiles (Multi-stage builds for Go, Alpine for Node).
* **Infrastructure as Code:**
    * **Helm:** A single generic `microservice` chart is used to deploy *both* applications (DRY principle).
    * **Monitoring:** A dedicated `lgtm` chart deploys the full Grafana/Loki/Tempo/Prometheus stack.
* **CI/CD:** GitHub Actions pipeline that:
    * Detects changes per service.
    * Builds and pushes images to **GitHub Container Registry (GHCR)**.
    * Performs Helm Dry-Runs for validation.

---

## 📂 Project Structure

```text
root-folder/
├── services/                 # Source code for microservices
│   ├── go-app/               # Golang Backend
│   └── node-app/             # Node.js Backend
├── charts/                   # Helm Charts
│   ├── microservice/         # Generic application chart
│   └── lgtm/                 # Monitoring stack (Loki, Grafana, Tempo, Prom)
├── .github/workflows/        # CI/CD Pipelines
├── Makefile                  # Automation shortcuts
└── README.md                 # Project Documentation

```

---

## 🛠 Quick Start

This project uses a **Makefile** to abstract complex commands.

### Prerequisites

* **Docker Desktop** (with Kubernetes enabled) or **Minikube**.
* **Helm** v3+ installed.
* **Make** (usually pre-installed on Linux/Mac; use chocolatey/winget on Windows).
* *Optional:* `minikube tunnel` (if using Minikube) to expose LoadBalancers.

### 1. Build Images

Automatically builds Docker images for both services using your local git config to tag them for GHCR.

```bash
make build

```

### 2. Deploy Microservices

Deploys both the Go and Node.js applications to your current Kubernetes cluster using Helm.

```bash
make deploy

```

### 3. Access the Services

The services are exposed via Ingress. Ensure your Ingress controller is running (or `minikube tunnel`).

* **Go Service:** [http://go.127.0.0.1.xip.io](https://www.google.com/search?q=http://go.127.0.0.1.xip.io)
* **Node Service:** [http://node.127.0.0.1.xip.io](https://www.google.com/search?q=http://node.127.0.0.1.xip.io)

*(Note: `xip.io` is a magic domain that resolves to the IP address in the subdomain. If you are on Minikube, you may need to replace `127.0.0.1` with `$(minikube ip)`).*

---

## 📊 Monitoring (Bonus: LGTM Stack)

We use a custom Helm chart wrapper (`charts/lgtm`) to deploy **Loki** (Logs), **Grafana** (Visuals), **Tempo** (Traces), and **Prometheus** (Metrics).

### Deploy the Stack

```bash
make deploy-lgtm

```

*Wait a few minutes for the `monitoring` namespace pods to initialize.*

### Access Grafana

1. Forward the port:
```bash
make port-forward-grafana

```


2. Open **[http://localhost:3000](https://www.google.com/search?q=http://localhost:3000)**
3. **Login:** `admin`
4. **Password:** Run the following command to retrieve it:
```bash
kubectl get secret --namespace monitoring lgtm-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

```



**What to check in Grafana:**

* Go to **Explore** (Compass Icon).
* Select **Loki** datasource -> Query `{namespace="default"}` to see app logs.
* Select **Prometheus** datasource -> Query `up` to see pod health.

---

## 🤖 CI/CD Pipeline (`.github/workflows/ci-cd.yaml`)

The pipeline is designed to be efficient and secure.

1. **Smart Change Detection:**
* Uses `git diff` to check if a commit actually modified a specific service folder.
* **Optimization:** If only `go-app` changes, `node-app` is NOT rebuilt.


2. **Manual Overrides:**
* Supports `workflow_dispatch` to force a full build/deploy cycle manually from the GitHub UI.


3. **GHCR Integration:**
* Automatically authenticates using the ephemeral `GITHUB_TOKEN`.
* Normalizes Organization names (capitalization handling) to comply with Docker tag standards.


4. **Deployment Safety:**
* Runs `helm upgrade --dry-run` to ensure manifests are valid before applying.



---

## 🧹 Cleanup

To remove the applications:

```bash
make delete

```

To remove the monitoring stack:

```bash
helm uninstall lgtm-stack -n monitoring

```

## 📊 Future Enahcnement

Update CI/CD on the Github to be able to deploy directly to minikube / local Kubernetes