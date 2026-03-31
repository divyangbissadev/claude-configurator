---
name: k8s-networking
description: Kubernetes networking conventions for ingress configuration, network policies, service mesh, DNS, and TLS certificate management.
---

# Kubernetes Networking Rules

## Ingress

- ALWAYS terminate TLS at the ingress layer; never serve plain HTTP in production
- Use `cert-manager.io/cluster-issuer` annotation for automated certificate provisioning
- Set rate limiting annotations to protect backend services from traffic spikes
- Configure appropriate timeouts (proxy-read-timeout, proxy-send-timeout) for long-running requests
- Set `client-max-body-size` annotation to prevent oversized request bodies
- Use path-based or host-based routing; avoid catch-all rules
- Enable HSTS headers via ingress annotations
- Prefer Gateway API over Ingress for new deployments (more expressive, role-oriented)

## Gateway API

- Use `GatewayClass` to define the infrastructure provider; reference it from `Gateway`
- Attach `HTTPRoute` to specific Gateway listeners via `parentRefs`
- Use `ReferenceGrant` to allow cross-namespace references (do not disable namespace isolation)
- Define explicit `hostnames` on routes to prevent accidental traffic capture
- Use route filters for header manipulation, URL rewrites, and request mirroring

## Network Policies

- ALWAYS deploy a default-deny-all policy (ingress and egress) in every application namespace:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: NetworkPolicy
  metadata:
    name: default-deny-all
  spec:
    podSelector: {}
    policyTypes:
      - Ingress
      - Egress
  ```
- ALWAYS allow egress to kube-dns for service discovery:
  ```yaml
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
  ```
- Use specific `podSelector` and `namespaceSelector` labels — never rely on empty selectors for allow rules
- Define both ingress and egress rules for every application pod
- Restrict egress to only the external endpoints the application needs (APIs, databases, registries)
- Document each NetworkPolicy with an annotation explaining its purpose

## Service Mesh

### Istio
- Enable STRICT mTLS at the namespace or mesh level via `PeerAuthentication`
- Use `AuthorizationPolicy` to enforce service-to-service access control
- Configure `DestinationRule` for circuit breaking and connection pool settings
- Set request timeouts and retries in `VirtualService` (not application code) for consistency
- Use `Sidecar` resource to scope egress access and reduce proxy memory footprint

### Linkerd
- Enable injection at namespace level: `linkerd.io/inject: enabled`
- Use `ServiceProfile` for per-route metrics, retries, and timeouts
- Use `TrafficSplit` for canary deployments

### General Mesh Rules
- Always enable mTLS between services; do not allow plaintext within the mesh
- Monitor mesh health dashboards (Kiali for Istio, Linkerd dashboard)
- Set sidecar resource limits to prevent proxy overhead from starving the application container

## DNS

- Use fully qualified domain names in service references for cross-namespace calls: `<service>.<namespace>.svc.cluster.local`
- Within the same namespace, short names are acceptable: `<service>`
- Configure ExternalDNS for automatic DNS record management from Ingress/Service/Gateway resources
- Set appropriate TTLs on external DNS records (lower for services that change frequently)
- Do not hardcode IP addresses; always use DNS names

## TLS / Certificate Management

- Use cert-manager for automated certificate lifecycle (issuance, renewal, revocation)
- Use a `ClusterIssuer` for organization-wide certificate issuance; `Issuer` for namespace-scoped
- Use Let's Encrypt staging for testing; production for live environments
- Set `renewBefore` to ensure certificates renew well before expiry (default 30 days; increase for slow approval workflows)
- Store CA certificates in Secrets referenced by trust anchors (not embedded in application config)
- For internal services, use a private CA via cert-manager CA issuer or Vault PKI
