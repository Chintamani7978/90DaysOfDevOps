# Day 60 Capstone – Quick Reference

## Deployment

```bash
# Make scripts executable (first time only)
chmod +x deploy.sh cleanup.sh

# Deploy the entire stack
./deploy.sh

# Or deploy manually step-by-step
kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-mysql-secret.yaml
kubectl apply -f 03-mysql-headless-service.yaml
kubectl apply -f 04-mysql-statefulset.yaml
kubectl apply -f 05-wordpress-configmap.yaml
kubectl apply -f 06-wordpress-deployment.yaml
kubectl apply -f 07-wordpress-service.yaml
kubectl apply -f 08-wordpress-hpa.yaml
```

## Verification Commands

```bash
# Set namespace
kubectl config set-context --current --namespace=capstone

# Check all resources
kubectl get all

# Check specific resource types
kubectl get pods
kubectl get services
kubectl get statefulsets
kubectl get deployments
kubectl get hpa

# Check MySQL
kubectl exec -it mysql-0 -- mysql -u wordpress_user -pwordpress_pass -e "SHOW DATABASES;"

# Check WordPress logs
kubectl logs deployment/wordpress
kubectl logs pod/<wordpress-pod-name>

# Port-forward to WordPress (Kind)
kubectl port-forward svc/wordpress 8080:80

# Check HPA status
kubectl describe hpa wordpress-hpa
```

## Access WordPress

- **Minikube:** `minikube service wordpress -n capstone`
- **Kind:** `kubectl port-forward svc/wordpress 8080:80` → http://localhost:8080
- **Direct NodePort:** http://<node-ip>:30080

## Test Self-Healing

```bash
# Delete a WordPress pod
kubectl delete pod wordpress-<hash> -n capstone

# Deployment recreates it immediately (watch)
kubectl get pods -w

# Delete MySQL pod
kubectl delete pod mysql-0 -n capstone

# StatefulSet recreates it with same PVC
kubectl get pods -w
```

## Cleanup

```bash
# Delete entire namespace (and all resources)
./cleanup.sh

# Or manually
kubectl delete namespace capstone
kubectl config set-context --current --namespace=default
```

## Files

- `01-namespace.yaml` – Capstone namespace
- `02-mysql-secret.yaml` – MySQL credentials
- `03-mysql-headless-service.yaml` – Headless Service for MySQL DNS
- `04-mysql-statefulset.yaml` – MySQL StatefulSet with PVC
- `05-wordpress-configmap.yaml` – WordPress configuration
- `06-wordpress-deployment.yaml` – WordPress Deployment (2 replicas)
- `07-wordpress-service.yaml` – WordPress NodePort Service (port 30080)
- `08-wordpress-hpa.yaml` – Horizontal Pod Autoscaler
- `deploy.sh` – Automated deployment script
- `cleanup.sh` – Cleanup script
- `day-60-capstone.md` – Full documentation
