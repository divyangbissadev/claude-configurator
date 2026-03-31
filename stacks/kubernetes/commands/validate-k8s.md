---
description: Validate Kubernetes manifests using dry-run, Helm lint, kubeconform, kubesec, and kube-linter for correctness, schema compliance, and security.
---

# Validate Kubernetes Manifests

Run a comprehensive validation pipeline against Kubernetes manifests in the current project.

## Steps

### 1. Discover Manifests
Find all Kubernetes YAML files and Helm charts in the project:
- Glob for `**/*.yaml` and `**/*.yml` files containing `apiVersion:` and `kind:`
- Glob for `**/Chart.yaml` to identify Helm charts

### 2. kubectl Dry-Run Validation
For plain manifests (non-Helm):
```bash
kubectl apply --dry-run=client -f <file>
```
This catches syntax errors, unknown fields, and basic schema issues without touching the cluster.

### 3. Helm Lint and Template
For each discovered Helm chart directory:
```bash
helm lint <chart-dir> --strict
helm template <release-name> <chart-dir> --values <chart-dir>/values.yaml
```
`--strict` treats warnings as errors. Template rendering catches Go template syntax issues.

### 4. Kubeconform Schema Validation
Validate manifests against the official Kubernetes JSON schemas:
```bash
kubeconform -strict -summary -output json <file-or-directory>
```
Use `-schema-location` for CRD schemas if custom resources are present. Kubeconform is faster than kubeval and actively maintained.

### 5. Kubesec Security Scan
Scan Deployment, StatefulSet, DaemonSet, and Pod manifests for security issues:
```bash
kubesec scan <file>
```
Review the score and any critical/advisory findings. Target a score of 5 or higher.

### 6. Kube-linter Static Analysis
Run kube-linter for best practice checks:
```bash
kube-linter lint <directory>
```
This checks for missing probes, resource limits, security context, and common misconfigurations.

### 7. Network Policy Coverage Analysis
Review NetworkPolicy resources in the project:
- Verify each namespace has a default-deny policy
- Check that ingress and egress rules are defined for application pods
- Flag namespaces with no NetworkPolicy resources

## Output

Report results in a structured summary:

```
=== Kubernetes Manifest Validation Report ===

Files scanned: <count>
Helm charts found: <count>

kubectl dry-run:     PASS/FAIL (<count> errors)
Helm lint:           PASS/FAIL (<count> errors)
Kubeconform:         PASS/FAIL (<count> errors)
Kubesec:             <avg score> (min: <min>, max: <max>)
Kube-linter:         PASS/FAIL (<count> findings)
NetworkPolicy:       <count> namespaces covered / <count> total

--- Errors ---
<list of errors with file paths and descriptions>

--- Warnings ---
<list of warnings with file paths and descriptions>
```

If any tool is not installed, note it and skip that check rather than failing the entire validation.
