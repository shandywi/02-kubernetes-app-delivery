# Validation evidence

Validation was performed on **2026-10-22** against the `homelab` namespace. This evidence deliberately excludes kubeconfig data, credentials, and individual node or pod addresses.

## Deployment health

| Check | Result |
| --- | --- |
| Deployment | `hello-web` reached 2 desired, 2 updated, and 2 available replicas; no unavailable replicas were reported. |
| Probes | Both pods reached `Ready` with zero restarts, confirming the startup, readiness, and liveness paths completed successfully. |
| Service | A ClusterIP Service created an EndpointSlice for the application. |
| In-cluster smoke test | A hardened, non-root ephemeral client requested `http://hello-web/` and received the expected `Hello from K3s` response. The client was removed after the test. |

## Resource and availability controls

| Control | Result |
| --- | --- |
| Container resources | Each web container declares request `100m` CPU / `128Mi` memory and limit `250m` CPU / `256Mi` memory. |
| HPA | Metrics API reported CPU utilization of `1%` against the `70%` target; desired replicas remained at the configured minimum of 2, with a maximum of 5. |
| PodDisruptionBudget | `minAvailable: 1`; Kubernetes reported one allowed voluntary disruption while two replicas were healthy. |
| Rollout strategy | Deployment uses `maxUnavailable: 0` and `maxSurge: 1`. |

## Rolling update and rollback drill

1. A temporary `RELEASE_VERSION=v2` environment value triggered a new Deployment revision.
2. The update reached 2 updated and 2 available replicas with no unavailable replicas reported.
3. `kubectl rollout undo deployment/hello-web -n homelab` restored the preceding pod template and completed successfully.
4. `kubectl apply -k ./manifests/` reconciled the live resources to the repository's `v1` source after the imperative drill.

## Evidence handling

Only summarized results are committed. Local terminal output and any future diagnostics must be redacted before publication.
