---
name: k8s-style
description: Kubernetes manifest conventions for labels, annotations, naming, and structure.
---

# Kubernetes Style Rules

## Naming Conventions

- Resource names: lowercase, alphanumeric, hyphens only (e.g., `my-app-web`, `payment-service-db`)
- Maximum 63 characters for most names (DNS subdomain constraint)
- Use consistent prefixes for related resources: `<app>-<component>` (e.g., `myapp-api`, `myapp-worker`, `myapp-redis`)
- Namespace names: short, lowercase, hyphenated (e.g., `production`, `staging`, `team-payments`)
- Service account names: `<app>-sa` or descriptive role-based name

## Labels

Every resource MUST include the standard Kubernetes labels:

```yaml
labels:
  app.kubernetes.io/name: <application-name>       # e.g., "nginx"
  app.kubernetes.io/instance: <release-instance>    # e.g., "nginx-production"
  app.kubernetes.io/version: <app-version>          # e.g., "1.25.3"
  app.kubernetes.io/component: <component>          # e.g., "frontend", "backend", "database"
  app.kubernetes.io/part-of: <system-name>          # e.g., "ecommerce-platform"
  app.kubernetes.io/managed-by: <tool>              # e.g., "helm", "kustomize", "argocd"
```

Additional operational labels as needed:
```yaml
labels:
  team: <owning-team>
  environment: <env>           # dev, staging, production
  cost-center: <cost-center>
```

## Annotations

Use annotations for non-identifying metadata:
- Deployment descriptions: `description: "Handles user authentication and session management"`
- Change tracking: `kubernetes.io/change-cause: "Upgrade to v2.3.1 for CVE-2024-1234 fix"`
- Tool-specific config: ingress annotations, ArgoCD sync options, Prometheus scrape config
- Do NOT use annotations for data that selectors need to match on (use labels for that)

## Manifest Structure

Order fields in this sequence within each resource:
1. `apiVersion`
2. `kind`
3. `metadata` (name, namespace, labels, annotations)
4. `spec`

Within a Deployment/StatefulSet spec:
1. `replicas`
2. `selector`
3. `strategy` / `updateStrategy`
4. `template.metadata` (labels, annotations)
5. `template.spec.serviceAccountName`
6. `template.spec.securityContext`
7. `template.spec.initContainers`
8. `template.spec.containers` (in order: main container, then sidecars)
9. `template.spec.volumes`
10. `template.spec.topologySpreadConstraints`
11. `template.spec.affinity`
12. `template.spec.tolerations`

Within each container:
1. `name`
2. `image`
3. `command` / `args`
4. `ports`
5. `env` / `envFrom`
6. `resources`
7. `securityContext`
8. `livenessProbe`
9. `readinessProbe`
10. `startupProbe`
11. `volumeMounts`

## File Organization

- One resource per file (or logical group: Deployment + Service + HPA together)
- File naming: `<kind>-<name>.yaml` (e.g., `deployment-api.yaml`, `service-api.yaml`)
- Or grouped: `<component>.yaml` containing related resources separated by `---`
- Kustomize structure:
  ```
  base/
    kustomization.yaml
    deployment.yaml
    service.yaml
  overlays/
    dev/
      kustomization.yaml
      patches/
    staging/
      kustomization.yaml
      patches/
    production/
      kustomization.yaml
      patches/
  ```

## YAML Formatting

- Use 2-space indentation consistently
- No trailing whitespace
- Use block scalars (`|` or `>`) for multi-line strings
- Quote strings that could be misinterpreted as other types (e.g., `"true"`, `"1.0"`, `"null"`)
- Use explicit `---` document separators between multiple resources in the same file
