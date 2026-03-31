---
name: k8s-security
description: Kubernetes security rules covering Pod Security Standards, RBAC, secrets management, image policies, and container hardening.
---

# Kubernetes Security Rules

## Pod Security

- ALWAYS set `runAsNonRoot: true` in pod securityContext
- ALWAYS set `allowPrivilegeEscalation: false` on every container
- ALWAYS set `readOnlyRootFilesystem: true` on every container (use emptyDir for writable paths)
- ALWAYS drop ALL capabilities: `capabilities: { drop: ["ALL"] }`; add back only what is specifically needed
- NEVER set `privileged: true` on application containers
- NEVER use `hostNetwork: true`, `hostPID: true`, or `hostIPC: true` unless the workload is a system-level daemonset with documented justification
- ALWAYS set a seccomp profile: `seccompProfile: { type: RuntimeDefault }` at minimum
- Set `runAsUser` and `runAsGroup` to a non-zero UID/GID (e.g., 1000)
- Set `fsGroup` for volume ownership when needed

## RBAC

- NEVER use wildcard verbs: `verbs: ["*"]` — enumerate specific verbs (get, list, watch, create, update, patch, delete)
- NEVER use wildcard resources: `resources: ["*"]` — enumerate specific resources
- NEVER bind `cluster-admin` to application service accounts
- Prefer namespaced `Role` over `ClusterRole` whenever possible
- Every workload should have a dedicated ServiceAccount (not the namespace `default`)
- Set `automountServiceAccountToken: false` on pods that do not need API access
- Use `resourceNames` to restrict access to specific named resources when applicable
- Review RBAC bindings regularly; remove unused bindings

## Secrets Management

- NEVER store secrets in plaintext in ConfigMaps, environment variable literals, or version-controlled files
- Use Kubernetes Secrets as a minimum (base64 is encoding, not encryption — enable encryption at rest)
- Prefer external-secrets-operator, sealed-secrets, or CSI Secrets Store Driver for production
- NEVER log secret values; mask them in application output
- Rotate secrets on a defined schedule; use short-lived credentials (e.g., IRSA, Workload Identity) where possible
- Set `immutable: true` on Secrets that should not change after creation

## Image Policies

- NEVER use the `latest` tag — pin to a specific semver tag or image digest
- Prefer digest-pinned images for production: `image: registry.example.com/app@sha256:abc123...`
- Restrict allowed registries via admission policy (Kyverno, Gatekeeper, or ValidatingAdmissionPolicy)
- Require image signature verification (cosign) for production deployments
- Use minimal base images (distroless, scratch, alpine) to reduce attack surface
- Scan images for CVEs in CI/CD and block critical/high vulnerabilities from deploying

## Network Security

- Apply default-deny NetworkPolicies (both ingress and egress) in every namespace
- Explicitly allow only required traffic flows
- Always allow egress to kube-dns (UDP/TCP port 53) for service discovery
- Use mTLS (via service mesh or application-level TLS) for service-to-service communication
- Do not expose internal services via NodePort or LoadBalancer without explicit need

## Namespace Isolation

- Apply Pod Security Standards at the namespace level (`pod-security.kubernetes.io/enforce: restricted`)
- Use ResourceQuotas to prevent resource exhaustion
- Use LimitRanges to set default resource requests/limits
- Separate tenants, environments, and sensitivity levels into distinct namespaces
