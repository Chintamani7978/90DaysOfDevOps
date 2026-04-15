# Day 59 – Helm: Kubernetes Package Manager

## What is Helm?

Helm is the **package manager for Kubernetes**, similar to `apt` for Ubuntu or `npm` for Node.js. It simplifies deploying complex applications by bundling Kubernetes manifests into reusable packages called **Charts**.

### Three Core Concepts

1. **Chart** – A package of Kubernetes manifest templates with variables. Contains:
   - `Chart.yaml` – metadata (name, version, description)
   - `values.yaml` – default configuration values
   - `templates/` – Go template YAML files (e.g., deployment.yaml, service.yaml)

2. **Release** – A specific instance of a Chart installed in your cluster. You can have multiple releases of the same chart with different configurations (e.g., `my-nginx`, `prod-nginx`).

3. **Repository** – A collection of Charts hosted online (like Bitnami, stable, or custom repos). You add repos with `helm repo add` and search them with `helm search repo`.

---

## Installation & Verification

### Install Helm

**On macOS (Homebrew):**
```bash
brew install helm
```

**On Ubuntu/Linux (using curl):**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**On Windows (Chocolatey):**
```powershell
choco install kubernetes-helm
```

### Verify Installation

```bash
helm version
# Output: version.BuildInfo{Version:"v3.x.x", ...}

helm env
# Shows Helm configuration directories and environment
```

---

## Working with Repositories

### Add Bitnami Repository

Bitnami provides production-ready Helm charts for common applications (nginx, MySQL, WordPress, etc.).

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Search for Charts

```bash
# Search Bitnami for nginx
helm search repo nginx

# List all Bitnami charts
helm search repo bitnami | wc -l
# Output: ~100+ charts available
```

---

## Installing & Managing Releases

### Install a Chart

```bash
# Simple installation with defaults
helm install my-nginx bitnami/nginx

# Check what was created
kubectl get all
# Shows: Deployment, Service, ConfigMap, StatefulSet (depending on chart)

# List all releases
helm list

# Get release status
helm status my-nginx

# View the generated manifests
helm get manifest my-nginx
```

### Customize with Values

View default values:
```bash
helm show values bitnami/nginx | head -50
```

Install with custom values using `--set`:
```bash
helm install my-nginx-custom bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=NodePort
```

### Custom Values File

Create `custom-values.yaml`:

```yaml
# Replica count for the application
replicaCount: 3

# Service configuration
service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

# Resource limits
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"

# Image configuration
image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent
```

Install using the file:
```bash
helm install my-nginx-prod bitnami/nginx -f custom-values.yaml

# Check applied values
helm get values my-nginx-prod
# Output: Shows only the overridden values

helm get values my-nginx-prod --all
# Output: Shows all values (defaults + overrides)
```

---

## Upgrade & Rollback

### Upgrade a Release

```bash
# Upgrade to new configuration
helm upgrade my-nginx bitnami/nginx --set replicaCount=5

# View history of all revisions
helm history my-nginx
# Output:
# REVISION  UPDATED                 STATUS     CHART       APP VERSION  DESCRIPTION
# 1         Mon Apr 16 10:00:00...  superseded nginx-15.3  1.25.0       Install complete
# 2         Mon Apr 16 10:05:00...  deployed   nginx-15.3  1.25.0       Upgrade complete
```

### Rollback to Previous Revision

```bash
# Rollback to revision 1
helm rollback my-nginx 1

# Check history again
helm history my-nginx
# Output: Rollback creates a NEW revision (3), doesn't overwrite revision 2
# REVISION  UPDATED                 STATUS     CHART       APP VERSION  DESCRIPTION
# 1         Mon Apr 16 10:00:00...  superseded nginx-15.3  1.25.0       Install complete
# 2         Mon Apr 16 10:05:00...  superseded nginx-15.3  1.25.0       Upgrade complete
# 3         Mon Apr 16 10:10:00...  deployed   nginx-15.3  1.25.0       Rollback to 1
```

---

## Creating Your Own Chart

### Scaffold a New Chart

```bash
helm create my-app

# Explore the structure
ls -la my-app/
# Chart.yaml          – metadata
# values.yaml         – default configuration
# templates/          – Go template YAML files
#   ├── deployment.yaml
#   ├── service.yaml
#   ├── configmap.yaml
#   └── _helpers.tpl  – template helpers
```

### Understanding Chart Structure

**`Chart.yaml`** – Metadata:
```yaml
apiVersion: v2
name: my-app
description: A Helm chart for my application
type: application
version: 0.1.0
appVersion: "1.0"
```

**`values.yaml`** – Default configuration:
```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**`templates/deployment.yaml`** – Go template syntax:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
    version: {{ .Chart.AppVersion }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

**Template Variables:**
- `{{ .Chart.Name }}` – chart name from Chart.yaml
- `{{ .Chart.AppVersion }}` – app version
- `{{ .Release.Name }}` – release name (e.g., "my-release")
- `{{ .Values.replicaCount }}` – value from values.yaml
- `{{ toYaml .Values.resources | nindent 10 }}` – structured indentation

### Validate & Preview

```bash
# Validate chart structure
helm lint my-app
# Output: ==> Linting my-app
#         ✓ No issues found

# Render templates without installing (for debugging)
helm template my-release ./my-app

# Preview with custom values
helm template my-release ./my-app --values custom-values.yaml
```

### Install Your Chart

```bash
# Install from local directory
helm install my-release ./my-app

# Verify pods
kubectl get pods
# Output: 2 pods running (from replicaCount: 2)

# Upgrade to 5 replicas
helm upgrade my-release ./my-app --set replicaCount=5

# Check new pod count
kubectl get pods
# Output: 5 pods now running
```

---

## Cleanup

```bash
# Uninstall a release
helm uninstall my-nginx

# Uninstall but keep release history (for auditing)
helm uninstall my-nginx --keep-history

# List releases
helm list --all
# Output: Empty if all releases removed

# Remove chart directories
rm -rf my-app my-nginx-custom
rm custom-values.yaml
```

---

## Key Commands Summary

| Command | Purpose |
|---------|---------|
| `helm repo add <name> <url>` | Add a repository |
| `helm repo update` | Fetch latest charts from repos |
| `helm search repo <keyword>` | Search for charts |
| `helm install <release> <chart>` | Install a chart |
| `helm upgrade <release> <chart>` | Update a release |
| `helm rollback <release> <revision>` | Rollback to previous version |
| `helm history <release>` | View release history |
| `helm uninstall <release>` | Remove a release |
| `helm list` | List all releases |
| `helm status <release>` | Check release status |
| `helm get values <release>` | View overridden values |
| `helm show values <chart>` | View default values |
| `helm create <chart>` | Scaffold a new chart |
| `helm lint <chart>` | Validate chart structure |
| `helm template <release> <chart>` | Render manifests (no install) |

---

## Why Helm?

### Before Helm (Manual YAML)
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml
# ... many more files
```
**Problem:** Complex, error-prone, hard to update.

### With Helm
```bash
helm install my-app bitnami/app
# One command creates everything.

# Customize
helm upgrade my-app bitnami/app --set replicaCount=5
# Update all related resources at once.
```

---

## Conclusion

Helm abstracts away Kubernetes complexity by:
1. **Templating** – Use Go templates to DRY up YAML files
2. **Reusability** – Package applications once, deploy many times
3. **Release Management** – Version, upgrade, and rollback entire stacks
4. **Community** – Thousands of production-ready charts from Bitnami, etc.

One command replaces dozens of individual YAML files and manual management.
