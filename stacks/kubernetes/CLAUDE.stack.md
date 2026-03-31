# Kubernetes Stack

This stack provides comprehensive Kubernetes development, deployment, and operations support including manifest authoring, Helm chart development, GitOps workflows, networking, and security hardening.

## Anti-Patterns (NEVER do these)

- **No `latest` image tag** — Always pin image references to a specific semver tag or digest (e.g., `image: nginx:1.25.3` or `image: nginx@sha256:...`). The `latest` tag is mutable and leads to unpredictable deployments.
- **No containers running as root** — Always set `runAsNonRoot: true` in the pod or container securityContext. Running as root inside a container expands the blast radius of any compromise.
- **No missing resource requests/limits** — Every container MUST specify `resources.requests` and `resources.limits` for both CPU and memory. Without these, the scheduler cannot make informed decisions and pods risk OOMKill or noisy-neighbor issues.
- **No hostNetwork/hostPID** — Never set `hostNetwork: true` or `hostPID: true` unless there is an explicit, documented infrastructure requirement (e.g., CNI plugin daemonset). These settings break network isolation and expose host processes.
- **No secrets in plain ConfigMaps** — Sensitive data (passwords, tokens, API keys, certificates) MUST use Kubernetes Secrets, external-secrets-operator, or sealed-secrets. Never embed secrets in ConfigMaps, environment variable literals, or checked-in manifests.
- **No missing liveness/readiness probes** — Every long-running container MUST define both `livenessProbe` and `readinessProbe`. Without them, Kubernetes cannot detect hung processes or route traffic correctly.
- **No PodDisruptionBudget missing for production workloads** — Any Deployment or StatefulSet running in production with more than one replica MUST have an accompanying PodDisruptionBudget to ensure availability during voluntary disruptions (node drains, upgrades).
- **Always set securityContext** — Every container should set `readOnlyRootFilesystem: true` and `capabilities: { drop: ["ALL"] }`. Add back only the specific capabilities that are required.
- **No wildcard RBAC rules** — Never use `resources: ["*"]` or `verbs: ["*"]` in Role or ClusterRole rules. Always enumerate the specific resources and verbs needed following the principle of least privilege.

## Stack Components

| Component | Purpose |
|-----------|---------|
| `k8s-manifest-developer` | Core Kubernetes resource authoring (Deployments, Services, ConfigMaps, etc.) |
| `helm-chart-builder` | Helm chart creation, templating, testing, and packaging |
| `k8s-gitops-engineer` | ArgoCD/Flux GitOps workflows and progressive delivery |
| `k8s-networking-engineer` | Ingress, Gateway API, NetworkPolicies, service mesh, DNS, TLS |
| `k8s-security-engineer` | Pod Security Standards, RBAC, OPA/Gatekeeper, Kyverno, secrets management |
| `k8s-reviewer` | Reviews manifests for security, best practices, and correctness |
| `validate-k8s` | Validates manifests via dry-run, linting, and schema checks |
| `k8s-troubleshoot` | Diagnoses pod failures, networking issues, and resource problems |

## Conventions

- Use `app.kubernetes.io/` label taxonomy (name, instance, version, component, part-of, managed-by)
- Namespace isolation per environment (dev, staging, production)
- Kustomize for environment-specific overlays; Helm for reusable, parameterized charts
- All manifests pass `kubeconform` schema validation before merge
- RBAC follows least-privilege; no cluster-admin bindings outside infrastructure controllers
