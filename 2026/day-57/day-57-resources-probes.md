# Day 57 - Kubernetes Resource Requests, Limits, and Probes

## What I Learned
Kubernetes needs resource requests and limits to schedule Pods correctly, and probes to understand whether containers are healthy and ready to receive traffic.

---

## Requests vs Limits

| Setting | Purpose |
|---|---|
| Requests | Minimum amount guaranteed for scheduling |
| Limits | Maximum amount the container can use |

If requests and limits are both set and equal, the Pod gets the `Guaranteed` QoS class. If requests are lower than limits, it is `Burstable`. If nothing is set, it is `BestEffort`.

---

## Task 1: Resource Requests and Limits

### Manifest Used
File: `resource-limits-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
```

### Commands
```bash
kubectl apply -f resource-limits-pod.yml
kubectl describe pod resource-demo
```

### Observation
- `kubectl describe pod` shows the Requests, Limits, and QoS Class sections.
- With different requests and limits, the Pod is `Burstable`.

### Verify Answer
The Pod has the `Burstable` QoS class.

---

## Task 2: OOMKilled - Exceeding Memory Limits

### Manifest Used
File: `oomkilled-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: oom-demo
spec:
  containers:
  - name: stress
    image: polinux/stress
    args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
    resources:
      limits:
        memory: 100Mi
```

### Commands
```bash
kubectl apply -f oomkilled-pod.yml
kubectl describe pod oom-demo
```

### Observation
- The container exceeds its memory limit and is killed by the kernel.
- `kubectl describe pod` shows `Reason: OOMKilled`.

### Verify Answer
An OOMKilled container exits with code `137`.

---

## Task 3: Pending Pod - Requesting Too Much

### Manifest Used
File: `pending-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pending-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        cpu: "100"
        memory: 128Gi
```

### Commands
```bash
kubectl apply -f pending-pod.yml
kubectl describe pod pending-demo
```

### Observation
- The scheduler cannot place the Pod because the request is too large.
- The Pod remains in `Pending` state.

### Verify Answer
The scheduler reports an insufficient resources message in the Events section.

---

## Task 4: Liveness Probe

### Manifest Used
File: `liveness-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-demo
spec:
  containers:
  - name: busybox
    image: busybox:1.36
    command: ["sh", "-c", "touch /tmp/healthy; sleep 30; rm /tmp/healthy; sleep 3600"]
    livenessProbe:
      exec:
        command: ["cat", "/tmp/healthy"]
      periodSeconds: 5
      failureThreshold: 3
```

### Commands
```bash
kubectl apply -f liveness-pod.yml
kubectl get pod -w
kubectl describe pod liveness-demo
```

### Observation
- Once `/tmp/healthy` is removed, the liveness probe fails repeatedly.
- Kubernetes restarts the container after consecutive failures.

### Verify Answer
The container restarts after three failed liveness checks.

---

## Task 5: Readiness Probe

### Manifest Used
File: `readiness-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-demo
  labels:
    app: readiness-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
```
```

### Commands
```bash
kubectl expose pod readiness-demo --port=80 --name=readiness-svc
kubectl get endpoints readiness-svc
kubectl exec readiness-demo -- rm /usr/share/nginx/html/index.html
kubectl get endpoints readiness-svc
```

### Observation
- When the readiness probe fails, the Pod is removed from Service endpoints.
- The container keeps running; it is not restarted.

### Verify Answer
No, the container is not restarted when readiness fails.

---

## Task 6: Startup Probe

### Manifest Used
File: `startup-pod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-demo
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["sh", "-c", "sleep 20; touch /tmp/started; sleep 3600"]
    startupProbe:
      exec:
        command: ["test", "-f", "/tmp/started"]
      periodSeconds: 5
      failureThreshold: 12
    livenessProbe:
      exec:
        command: ["test", "-f", "/tmp/started"]
      periodSeconds: 5
```

### Commands
```bash
kubectl apply -f startup-pod.yml
kubectl describe pod startup-demo
```

### Observation
- The startup probe gives the container time to initialize before liveness begins.
- If the startup probe fails too early, Kubernetes kills the container before it can finish starting.

### Verify Answer
If `failureThreshold` were 2, the container would likely be killed before startup completes.

---

## Task 7: Clean Up

### Commands
```bash
kubectl delete pod resource-demo
kubectl delete pod oom-demo
kubectl delete pod pending-demo
kubectl delete pod liveness-demo
kubectl delete pod readiness-demo
kubectl delete pod startup-demo
kubectl delete svc readiness-svc
```

### Observation
- All test Pods and Services can be removed after the exercise.

---

## How It Works

### 1. Requests and Limits
Requests guide scheduling. Limits enforce resource ceilings at runtime. CPU is throttled when over limit, while memory pressure can trigger OOMKilled.

### 2. Probe Types

| Probe Type | What It Does |
|---|---|
| Liveness | Restarts stuck containers |
| Readiness | Removes Pods from Service endpoints |
| Startup | Gives slow apps time to initialize |

### 3. QoS Classes

| QoS Class | When It Applies |
|---|---|
| Guaranteed | Requests equal limits |
| Burstable | Requests set, but lower than limits |
| BestEffort | No requests or limits set |

### 4. Common Failure Signals
- `OOMKilled` means memory was exceeded.
- `Exit Code 137` usually means the process was killed with SIGKILL.
- `Pending` often means the scheduler could not find enough resources.

---

## Screenshots to Add
- `kubectl describe pod resource-demo`
- `kubectl describe pod oom-demo`
- Pending pod events
- Liveness and readiness probe events

---

## Final Learning
Today I learned that resource requests and limits affect how Kubernetes schedules and enforces usage, while probes help Kubernetes decide when a container should be restarted or removed from traffic.
