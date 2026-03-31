---
description: Troubleshoot Kubernetes pod failures, networking issues, and resource problems by analyzing pod status, events, logs, and resource utilization.
---

# Kubernetes Troubleshoot

Diagnose and resolve common Kubernetes issues using a systematic approach.

## Steps

### 1. Pod Status Analysis

Identify pods in error states:

```bash
kubectl get pods -n <namespace> --field-selector=status.phase!=Running,status.phase!=Succeeded
```

For each problematic pod, diagnose by status:

**CrashLoopBackOff:**
- Check container logs: `kubectl logs <pod> -n <namespace> --previous`
- Check exit code in `kubectl describe pod <pod> -n <namespace>` (look for `Last State: Terminated`)
- Common causes: application error, missing config/secrets, permission denied, port conflict
- Check if readiness/liveness probes are misconfigured (too aggressive thresholds)

**ImagePullBackOff / ErrImagePull:**
- Verify image name and tag exist: `kubectl describe pod <pod>` (look for Events)
- Check imagePullSecrets are configured and valid
- Verify registry credentials: `kubectl get secret <pull-secret> -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d`
- Check network connectivity to registry from node

**OOMKilled:**
- Check `Last State: Terminated` with reason OOMKilled in `kubectl describe pod`
- Review memory limits vs actual usage: `kubectl top pod <pod> -n <namespace>`
- Increase `resources.limits.memory` or optimize application memory usage
- Check for memory leaks in application logs

**Pending:**
- Check events: `kubectl describe pod <pod>` — look for scheduling failures
- Insufficient resources: `kubectl describe nodes` — check Allocatable vs Allocated
- Unschedulable nodes: `kubectl get nodes` — check for taints and cordons
- PVC binding issues: `kubectl get pvc -n <namespace>` — check for Pending PVCs

**CreateContainerConfigError:**
- Missing ConfigMap or Secret referenced in env or volume mounts
- `kubectl get configmap <name>` / `kubectl get secret <name>` to verify existence
- Check key names match between manifest references and actual ConfigMap/Secret data

### 2. Event Inspection

```bash
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -30
```

Look for:
- FailedScheduling — resource constraints, affinity/anti-affinity mismatches, taints
- FailedMount — PVC issues, ConfigMap/Secret not found
- Unhealthy — Failed probes (liveness or readiness)
- BackOff — Container crash loops
- FailedCreate — ReplicaSet controller issues (quota exceeded, admission webhook rejection)

### 3. Log Tailing

```bash
# Current container logs
kubectl logs <pod> -n <namespace> -c <container> --tail=100

# Previous crash logs
kubectl logs <pod> -n <namespace> -c <container> --previous

# Follow logs in real time
kubectl logs <pod> -n <namespace> -f

# All containers in a pod
kubectl logs <pod> -n <namespace> --all-containers=true
```

For init container failures:
```bash
kubectl logs <pod> -n <namespace> -c <init-container-name>
```

### 4. Resource Utilization Analysis

```bash
# Node-level resources
kubectl top nodes

# Pod-level resources
kubectl top pods -n <namespace> --sort-by=memory

# Check resource quotas
kubectl describe resourcequota -n <namespace>

# Check limit ranges
kubectl describe limitrange -n <namespace>
```

Compare actual usage against requests/limits. Pods near their memory limit are at risk of OOMKill. Pods with CPU throttling may have slow response times.

### 5. Networking Debug

**DNS Resolution:**
```bash
kubectl run debug-dns --rm -it --image=busybox:1.36 --restart=Never -- nslookup <service>.<namespace>.svc.cluster.local
```

**Service Connectivity:**
```bash
kubectl run debug-net --rm -it --image=nicolaka/netshoot --restart=Never -- curl -v http://<service>.<namespace>.svc.cluster.local:<port>
```

**Common networking issues:**
- Service selector does not match pod labels: compare `kubectl get svc <svc> -o yaml` selectors with `kubectl get pods --show-labels`
- No endpoints: `kubectl get endpoints <service> -n <namespace>` shows empty if selectors don't match or pods aren't ready
- NetworkPolicy blocking traffic: temporarily check with `kubectl get networkpolicy -n <namespace>`
- DNS not resolving: check CoreDNS pods are running in `kube-system`

**Port-forward for local testing:**
```bash
kubectl port-forward svc/<service> <local-port>:<service-port> -n <namespace>
```

## Output

Present findings in a structured format:

```
=== Kubernetes Troubleshooting Report ===

Namespace: <namespace>
Cluster: <context>

Problem Pods:
  <pod-name> — <status> — <root cause summary>

Root Cause:
  <detailed explanation>

Recommended Fix:
  <step-by-step remediation>

Commands to Apply Fix:
  <kubectl commands or manifest changes>
```
