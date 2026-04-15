# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## Overview

This capstone project combines **12 Kubernetes concepts** learned over 10 days into a single, production-like deployment:

1. **Namespaces** – Isolation and organization
2. **Secrets** – Secure credential management
3. **ConfigMaps** – Application configuration
4. **PersistentVolumeClaims (PVCs)** – Data persistence
5. **StatefulSets** – Stateful applications (MySQL)
6. **Headless Services** – DNS for StatefulSets
7. **Deployments** – Stateless applications (WordPress)
8. **NodePort/LoadBalancer Services** – External access
9. **Resource Requests & Limits** – Fair cluster usage
10. **Liveness & Readiness Probes** – Self-healing
11. **Horizontal Pod Autoscaling (HPA)** – Dynamic scaling
12. **Helm** – Package management (bonus comparison)

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Capstone Namespace                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         WordPress Deployment (2 replicas)               │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Pod 1: wordpress-xxxx-yyyy                         │ │  │
│  │  │  - Env: MySQL host, DB name, user, password        │ │  │
│  │  │  - Probes: Liveness & Readiness on /wp-login.php   │ │  │
│  │  │  - Resources: req/limit defined                     │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Pod 2: wordpress-xxxx-zzzz                         │ │  │
│  │  │  - (same config as Pod 1)                           │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────┐                       │
│  │  WordPress NodePort Service          │                       │
│  │  Port 30080 → :80 (WordPress)        │                       │
│  └──────────────────────────────────────┘                       │
│                            ↓                                     │
│                    External Access                              │
│                  (Browser, minikube, port-fwd)                  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MySQL StatefulSet (1 replica)               │  │
│  │  ┌─────────────────────────────────────────────────────┐ │  │
│  │  │  Pod: mysql-0                                       │ │  │
│  │  │  - Image: mysql:8.0                                 │ │  │
│  │  │  - Env: ROOT_PASSWORD, USER, PASSWORD, DB (Secret)  │ │  │
│  │  │  - PVC: 1Gi mounted at /var/lib/mysql               │ │  │
│  │  │  - DNS: mysql-0.mysql.capstone.svc.cluster.local    │ │  │
│  │  └─────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                     │
│  ┌──────────────────────────────────────┐                       │
│  │  MySQL Headless Service              │                       │
│  │  (No ClusterIP, DNS-based discovery) │                       │
│  │  Port: 3306                          │                       │
│  └──────────────────────────────────────┘                       │
│                            ↓                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           PersistentVolumeClaim (1Gi)                    │  │
│  │  - Data persists even if mysql-0 pod is deleted         │  │
│  │  - StatefulSet recreates pod with same PVC              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │    HPA (Horizontal Pod Autoscaler) for WordPress         │  │
│  │  - Min: 2 replicas  Max: 10 replicas                     │  │
│  │  - Target CPU: 50%                                       │  │
│  │  - Automatically scales Deployment based on load         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Deployment

### Step 1: Create Namespace

```bash
kubectl create namespace capstone
kubectl config set-context --current --namespace=capstone
```

### Step 2: Create Secrets (MySQL Credentials)

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: capstone
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: "rootpass123"
  MYSQL_USER: "wordpress_user"
  MYSQL_PASSWORD: "wordpress_pass"
  MYSQL_DATABASE: "wordpress_db"
EOF
```

**Verify:**
```bash
kubectl get secret mysql-secret -n capstone -o jsonpath='{.data.MYSQL_ROOT_PASSWORD}' | base64 -d
```

### Step 3: Deploy MySQL (StatefulSet)

MySQL requires:
- **Headless Service** – For stable DNS names (`mysql-0.mysql.capstone.svc.cluster.local`)
- **StatefulSet** – For ordered, stable Pod identities and storage
- **PersistentVolumeClaim** – For data persistence

#### Headless Service:
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: capstone
spec:
  clusterIP: None  # Headless: no ClusterIP, only DNS
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
EOF
```

#### StatefulSet:
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: capstone
spec:
  serviceName: mysql  # Must match Headless Service name
  replicas: 1        # Single MySQL instance
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        envFrom:
        - secretRef:
            name: mysql-secret
        resources:
          requests:
            cpu: 250m
            memory: 512Mi
          limits:
            cpu: 500m
            memory: 1Gi
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF
```

**Verify MySQL:**
```bash
# Wait for mysql-0 to be Running (may take 30-60 seconds)
kubectl get pod mysql-0 -n capstone --watch

# Once Running, test connectivity
kubectl exec -it mysql-0 -n capstone -- \
  mysql -u wordpress_user -pwordpress_pass -e "SHOW DATABASES;"

# Output should include:
# | wordpress_db |
```

---

### Step 4: Deploy WordPress (Deployment)

WordPress needs:
- **ConfigMap** – Database host and name (external config)
- **Deployment** – 2 replicas for high availability
- **Environment variables** – From ConfigMap and Secret
- **Probes** – For self-healing

#### ConfigMap:
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config
  namespace: capstone
data:
  WORDPRESS_DB_HOST: "mysql-0.mysql.capstone.svc.cluster.local:3306"
  WORDPRESS_DB_NAME: "wordpress_db"
EOF
```

#### Deployment:
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: capstone
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: wordpress:latest
        ports:
        - containerPort: 80
        envFrom:
        - configMapRef:
            name: wordpress-config
        env:
        - name: WORDPRESS_DB_USER
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_USER
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: MYSQL_PASSWORD
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /wp-login.php
            port: 80
          initialDelaySeconds: 60
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /wp-login.php
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
EOF
```

**Verify WordPress:**
```bash
# Check pods are running
kubectl get pods -n capstone
# Output: Both wordpress-xxxx pods should show 1/1 Running

# Check pod logs if they're not Ready
kubectl logs deployment/wordpress -n capstone --tail 50
```

---

### Step 5: Expose WordPress with NodePort Service

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: capstone
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
EOF
```

**Access WordPress:**

**On Minikube:**
```bash
minikube service wordpress -n capstone
# Opens browser automatically with WordPress setup page
```

**On Kind with port-forward:**
```bash
kubectl port-forward svc/wordpress 8080:80 -n capstone
# Open http://localhost:8080 in browser
```

**Direct NodePort access:**
```bash
kubectl get nodes -o wide
# Get a node's external IP (or use node name + port)

# Access: http://<node-ip>:30080
```

---

### Step 6: Complete WordPress Setup

1. **Language Selection** – Choose English (or preferred language)
2. **Welcome Screen** – Click "Let's go"
3. **Database Configuration** – Already filled by environment variables
4. **Database Ready** – Click "Run the installation"
5. **Site Information:**
   - Site Title: "My Production Blog"
   - Username: "admin"
   - Password: Generate a strong password
   - Email: your-email@example.com
   - Search Engine Visibility: Enable (optional)
6. **Click "Install WordPress"**
7. **Log in** with admin credentials
8. **Create a Post:**
   - Go to Posts → Add New
   - Title: "Kubernetes is Awesome"
   - Content: "Today I deployed a real WordPress + MySQL stack on Kubernetes using 12 different concepts."
   - Publish

**Verify from WordPress Dashboard:**
- Check "Dashboard" – site is running
- Check "Posts" – your blog post is visible
- Check "Settings" – database credentials are correct

---

### Step 7: Test Self-Healing & Persistence

#### Test 1: WordPress Pod Deletion
```bash
# Get current WordPress pods
kubectl get pods -n capstone -l app=wordpress

# Delete one pod
kubectl delete pod <wordpress-pod-name> -n capstone

# Watch new pod get created
kubectl get pods -n capstone --watch

# Refresh WordPress in browser
# Result: Blog post still there, site still accessible
```

#### Test 2: MySQL Pod Deletion
```bash
# Delete MySQL pod
kubectl delete pod mysql-0 -n capstone

# Watch StatefulSet recreate it with same PVC
kubectl get pods -n capstone --watch

# Once mysql-0 is Running again, verify data
kubectl exec -it mysql-0 -n capstone -- \
  mysql -u wordpress_user -pwordpress_pass wordpress_db -e "SELECT post_title FROM wp_posts;"

# Output: Your blog post title should appear

# Refresh WordPress
# Result: Blog post still there, MySQL recovered with data intact
```

#### Test 3: Full Stack Recovery
```bash
# Delete all WordPress pods
kubectl delete pods -l app=wordpress -n capstone

# Deployment recreates them immediately
# MySQL is untouched (different resource)

# Refresh browser
# Result: WordPress is back online
```

---

### Step 8: Setup Horizontal Pod Autoscaler (HPA)

```bash
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: wordpress-hpa
  namespace: capstone
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wordpress
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF
```

**Verify HPA:**
```bash
kubectl get hpa -n capstone
# Output:
# NAME             REFERENCE               TARGETS           MINPODS  MAXPODS
# wordpress-hpa    Deployment/wordpress    15%/50%, 20%/80%  2        10

kubectl describe hpa wordpress-hpa -n capstone
```

---

### Step 9: View Complete deployment

```bash
# List all resources in capstone namespace
kubectl get all -n capstone

# Output example:
# NAME                             READY   STATUS    RESTARTS   AGE
# pod/wordpress-7d4cc6f55-4f2k9   1/1     Running   0          5m
# pod/wordpress-7d4cc6f55-8k9xl   1/1     Running   0          5m
# pod/mysql-0                      1/1     Running   0          10m
#
# NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)
# service/wordpress    NodePort    10.96.1.50   <none>        80:30080/TCP
# service/mysql        ClusterIP   None         <none>        3306/TCP
#
# NAME                        READY   UP-TO-DATE   AVAILABLE
# deployment.apps/wordpress   2/2     2            2
#
# NAME                                 DESIRED   CURRENT   READY
# statefulset.apps/mysql               1         1         1
#
# NAME                             REFERENCE               TARGETS           MINPODS
# horizontalpodautoscaler/wordpress-hpa   Deployment/wordpress   12%/50%, 18%/80%   2

# Get more detailed view
kubectl describe all -n capstone | less
```

---

### Step 10: Bonus – Compare with Helm

Deploy WordPress using Bitnami Helm chart in a separate namespace:

```bash
# Create separate namespace for Helm deployment
kubectl create namespace wordpress-helm

# Install Helm chart (uses MariaDB, not MySQL)
helm install wp-helm bitnami/wordpress \
  --namespace wordpress-helm \
  --set wordpressUsername=admin \
  --set wordpressPassword=password123

# Compare resources
kubectl get all -n wordpress-helm | wc -l
kubectl get all -n capstone | wc -l

# Results:
# - Helm chart: Creates more resources (StatefulSet for MariaDB, Deployment, Service, ConfigMap, Secret, PVC)
# - Manual manifests: More control but more YAML to write
# - Both approaches work; Helm saves time for common patterns

# Clean up Helm deployment
helm uninstall wp-helm -n wordpress-helm
kubectl delete namespace wordpress-helm
```

---

### Step 11: Cleanup

```bash
# View final state
kubectl get all -n capstone

# Delete the entire capstone namespace (removes everything inside)
kubectl delete namespace capstone

# Verify
kubectl get namespaces
# capstone should no longer appear

# Reset default namespace
kubectl config set-context --current --namespace=default
```

---

## Concept Mapping: 10 Days to 12 Concepts

| Concept | Day Learned | Used In This Deployment |
|---------|-------------|--------------------------|
| Namespaces | Day 52 | `capstone` namespace |
| Pods & Containers | Day 50 | WordPress & MySQL pods |
| Deployments | Day 52 | WordPress (2 replicas) |
| StatefulSets | Day 54 | MySQL (stable identity) |
| Services | Day 53 | Headless (MySQL), NodePort (WordPress) |
| ConfigMaps | Day 54 | WordPress configuration |
| Secrets | Day 55 | MySQL credentials |
| PersistentVolumes/PVCs | Day 56 | MySQL data storage |
| Resource Requests/Limits | Day 57 | CPU and memory bounds |
| Liveness/Readiness Probes | Day 57 | WordPress health checks |
| Autoscaling (HPA) | Day 58 | WordPress HPA |
| Helm | Day 59 | Bonus: compared manual vs Helm |

---

## Lessons Learned

### What Clicked
- **Headless Services** – Enables StatefulSets with stable DNS
- **Secrets + ConfigMaps** – Cleanly separates sensitive and non-sensitive data
- **Probes** – Self-healing without manual intervention
- **PVCs** – Data survives pod deletion, enabling true persistence

### What Was Challenging
- **MySQL startup time** – Can take 30-60 seconds; patience is necessary
- **Pod-to-Pod networking** – DNS hostname format: `pod.service.namespace.svc.cluster.local`
- **Probe timing** – `initialDelaySeconds` must be long enough for WordPress to boot
- **Resource limits** – Too low → crashes; too high → wastes cluster resources

### Production Improvements
1. **Database Backups** – Use persistent backup solutions (mysqldump, or cloud-native backups)
2. **Multiple MySQL Replicas** – Use Percona XtraDB Cluster or InnoDB Cluster
3. **Health Monitoring** – Add Prometheus metrics and Grafana dashboards
4. **Ingress Controller** – Replace NodePort with Ingress for easier domain management
5. **TLS/SSL** – Enable HTTPS with cert-manager and Let's Encrypt
6. **Security Policies** – NetworkPolicies to restrict pod communication
7. **Resource Quotas** – Namespace-level limits to prevent runaway consumption
8. **Logging & Auditing** – Centralized logs (ELK, Loki) for troubleshooting

---

## Reflection: The Full Picture

In **10 days** of Kubernetes learning, you've gone from:
- **Day 50:** Understanding Pods
- **Day 51:** Basic Deployments
- **Day 52:** Services and networking
- ...to...
- **Day 60:** A **production-like, self-healing, scalable, persistent application** backed by a database

You've used:
- **Infrastructure abstractions** – Namespaces, quotas
- **Configuration management** – ConfigMaps, Secrets
- **Stateful & Stateless patterns** – StatefulSets vs Deployments
- **Networking** – Services and DNS discovery
- **Reliability** – Probes and autoscaling
- **Package management** – Helm for reusability

This is what **production Kubernetes** looks like. The remaining journey involves:
- **GitOps** – Automated deployments via Flux or ArgoCD
- **Observability** – Monitoring, logging, and tracing
- **Service Mesh** – Advanced traffic management (Istio, Linkerd)
- **Security hardening** – RBAC, NetworkPolicies, Pod Security Policies
- **Multi-cluster** – High availability across regions/clouds

You've built the **foundation**. Everything else is refinement.

---

## Files in This Deployment

If using manifest files instead of inline YAML:
- `01-namespace.yaml` – Capstone namespace
- `02-mysql-secret.yaml` – MySQL credentials
- `03-mysql-headless-service.yaml` – Headless Service for MySQL
- `04-mysql-statefulset.yaml` – MySQL StatefulSet with PVC
- `05-wordpress-configmap.yaml` – WordPress configuration
- `06-wordpress-deployment.yaml` – WordPress Deployment
- `07-wordpress-service.yaml` – WordPress NodePort Service
- `08-wordpress-hpa.yaml` – Horizontal Pod Autoscaler

Apply all at once:
```bash
kubectl apply -f *.yaml
```

---

## Summary

**WordPress + MySQL on Kubernetes in one deployment.**

✅ Namespaces – Organized isolation
✅ Secrets – Secure credentials  
✅ ConfigMaps – Application config  
✅ PVCs – Persistent data  
✅ StatefulSets – Stateful MySQL  
✅ Headless Services – DNS discovery  
✅ Deployments – Stateless WordPress  
✅ NodePort Services – External access  
✅ Resource Limits – Fair cluster use  
✅ Probes – Self-healing  
✅ HPA – Automatic scaling  
✅ Helm – Package management  

**12 concepts. One real application. 10 days of learning. Welcome to Kubernetes.**
