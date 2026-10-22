# Environment and prerequisites

This project is deployed to the `homelab` namespace established by Project 01. Portfolio documentation represents the private node network as `172.16.0.0/24`; individual node and pod addresses are never committed.

| Component | Requirement |
| --- | --- |
| Kubernetes | K3s `v1.36.5+k3s1` |
| Nodes | `cp01`, `wk01`, `wk02`, `wk03`; 2 vCPU / 4 GB RAM each |
| Namespace | `homelab`, with baseline Pod Security enforcement |
| Capacity guardrails | 1 CPU / 1Gi request quota; 2 CPU / 2Gi limit quota; 10-pod maximum |
| Metrics | `metrics-server` and `metrics.k8s.io` API available |

The application's maximum five replicas fit inside the namespace quota: each pod requests `100m` CPU / `128Mi` memory and limits `250m` CPU / `256Mi` memory.
