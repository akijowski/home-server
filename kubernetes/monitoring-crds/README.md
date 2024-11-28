# Monitoring Operators

Kubernetes Operator for Monitoring:

- Prometheus
- Grafana

## Project

- [Site](https://prometheus.io/docs/introduction/overview/)
- [Repo](https://github.com/prometheus-operator/prometheus-operator)
- [Operator Getting Started](https://prometheus-operator.dev/docs/prologue/introduction/)
- [Grafana Operator](https://grafana.github.io/grafana-operator/docs/)

## How it is used

Prometheus (and AlertManager) will be used to aggregate and optionally alert on resources both in and outside of the k3s cluster.
Custom scrape configs can be created to monitor other resources (like Proxmox LXCs or VMs for example).

### Install and Upgrade

#### Deprecated
The operator is added as a set of urls in the [ansible k3s cluster role](../../ansible/k3s/k3s_cluster.yml).
This _only_ installs the CRDs in to the cluster.
The necessary components for the Operator are [in this yaml file](./_operator.yaml).
The Github Repo contains a `bundle.yaml` that can be used to bootstrap, however it assumes a default namespace.
Downloading that bundle file includes the CRDs and the Operator.
At the end of the file is the Operator resources (ClusterRole, CRB, SA, Deploy, etc), which can be copied in to the [yaml file](./_operator.yaml).

#### Current

The CRDs are installed as ArgoCD app under the App of Apps.
I use Kustomize to reference the entire `bundle.yaml` and apply namespace overrides.
This really simplifies the process vs the previous process, which I kept for posterity.
