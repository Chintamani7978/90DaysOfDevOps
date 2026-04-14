# Day 58 - Kubernetes Metrics Server and Horizontal Pod Autoscaler (HPA)

## What I Learned
Kubernetes can only autoscale intelligently when it can measure real resource usage. The Metrics Server provides that data, and the Horizontal Pod Autoscaler uses it to decide when to add or remove replicas.

---

## Deployment vs Autoscaling

| Feature | Deployment | HPA |
|---|---|---|
| Purpose | Keeps a desired number of Pods running | Adjusts replica count based on metrics |
| Trigger | Manual rollout or scaling | CPU, memory, or custom metrics |
| Awareness | Does not react to load | Reacts to live usage data |
| Dependency | No Metrics Server required | Requires Metrics Server for resource metrics |

---

## Task 1: Install the Metrics Server

### Commands
```bash
kubectl get pods -n kube-system | grep metrics-server
minikube addons enable metrics-server
kubectl top nodes
kubectl top pods -A
```

### Observation
- Metrics Server runs in the cluster and collects resource usage from kubelets.
- `kubectl top` starts returning live CPU and memory data only after Metrics Server is working.
- On local clusters, `--kubelet-insecure-tls` may be needed.

### Verify Answer
The current CPU and memory usage of the node is the output shown by `kubectl top nodes`.

---

## Task 2: Explore `kubectl top`

### Commands
```bash
kubectl top nodes
kubectl top pods -A
kubectl top pods -A --sort-by=cpu
```

### Observation
- `kubectl top` shows actual usage, not the requests or limits configured on Pods.
- The metrics are refreshed regularly from the Metrics Server.
- Sorting by CPU helps identify the busiest Pod at the moment.

### Verify Answer
The Pod using the most CPU is the first one in `kubectl top pods -A --sort-by=cpu`.

---

## Task 3: Create a Deployment with CPU Requests

### Manifest Used
File: `php-apache-deployment.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        resources:
          requests:
            cpu: 200m
        ports:
        - containerPort: 80
```

### Commands
```bash
kubectl apply -f php-apache-deployment.yml
kubectl expose deployment php-apache --port=80
kubectl describe pod -l run=php-apache
kubectl top pod -l run=php-apache
```

### Observation
- HPA needs CPU requests to calculate utilization.
- Without requests, the TARGETS column usually shows `<unknown>`.

### Verify Answer
The current CPU usage of the Pod is visible with `kubectl top pod`.

---

## Task 4: Create an HPA (Imperative)

### Commands
```bash
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
kubectl get hpa
kubectl describe hpa php-apache
```

### Observation
- The HPA starts with one replica and watches average CPU usage.
- TARGETS may briefly show `<unknown>` until metrics arrive.
- Once data is available, HPA compares current usage against the 50% target.

### Verify Answer
The TARGETS column shows the current CPU utilization versus the target, for example `0%/50%` or `<unknown>` at first.

---

## Task 5: Generate Load and Watch Autoscaling

### Commands
```bash
kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
kubectl get hpa php-apache --watch
kubectl delete pod load-generator
```

### Observation
- The load generator increases CPU usage on the PHP-Apache deployment.
- HPA reacts by increasing replicas when average CPU rises above the target.
- Scale-down is slower because Kubernetes uses a stabilization window to avoid flapping.

### Verify Answer
Under load, HPA scales the deployment above 1 replica, depending on cluster speed and traffic pressure.

---

## Task 6: Create an HPA from YAML (Declarative)

### Manifest Used
File: `php-apache-hpa.yml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
```

### Commands
```bash
kubectl delete hpa php-apache
kubectl apply -f php-apache-hpa.yml
kubectl describe hpa php-apache
```

### Observation
- `autoscaling/v2` supports richer scaling policies than the imperative command.
- The `behavior` block controls how aggressively scale-up and scale-down happen.

### Verify Answer
The `behavior` section controls scaling speed, stabilization, and policy limits for scale-up and scale-down.

---

## Task 7: Clean Up

### Commands
```bash
kubectl delete hpa php-apache
kubectl delete service php-apache
kubectl delete deployment php-apache
kubectl delete pod load-generator
```

### Observation
- HPA, service, deployment, and load-generator pod can be removed after the exercise.
- Metrics Server stays installed so `kubectl top` continues working for future labs.

---

## How It Works

### 1. Metrics Server
Metrics Server collects resource usage from kubelets and makes that data available through the Kubernetes Metrics API. HPA depends on this data source to make scaling decisions.

### 2. HPA Formula
For CPU-based scaling, Kubernetes uses a utilization ratio:

`desiredReplicas = ceil(currentReplicas * currentUsage / targetUsage)`

If usage is above the target, replicas increase. If usage drops below the target, replicas decrease.

### 3. `autoscaling/v1` vs `autoscaling/v2`

| API Version | Capabilities |
|---|---|
| `autoscaling/v1` | CPU-based scaling only |
| `autoscaling/v2` | CPU, memory, custom metrics, and behavior policies |

`autoscaling/v2` is preferred when you need more control over scaling behavior.

### 4. Requests Matter
HPA measures usage relative to `resources.requests`. Without CPU requests, Kubernetes cannot compute a meaningful utilization percentage.

---

## Screenshots to Add
- `kubectl top nodes`
- `kubectl top pods -A --sort-by=cpu`
- `kubectl describe hpa php-apache`
- Pod replica changes while load is running

---

## Final Learning
Today I learned that Metrics Server and HPA work together to make Kubernetes reactive instead of static. Metrics Server gives live resource data, and HPA uses that data plus CPU requests to scale workloads automatically under load.
