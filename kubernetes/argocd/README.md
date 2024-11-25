# ArgoCD

This directory installs [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) in to a Kubernetes cluster.

The idea is to install ArgoCD in to a management cluster.
Then Argo CRDs can be created to deploy apps in to both the management and main clusters.

[The K3s Playbook](../../ansible/k3s/k3s_cluster.yml) deploys a k3s cluster.
[The K3s inventory](../../ansible/inventory/k3s.yml) manages the hosts in those clusters.

After installation a repo connection will need to be manually created.
Right now, that means setting up an ssh connection to this repo.

Additional Apps are managed in the [argoapps directory](../argoapps/).
This App of Apps is deployed with this Kustomization file: [here](./base/apps.yaml).

## Test

Test the Kustomization with:

```shell
/workspaces/home-server/kubernetes/argocd $ kubectl kustomize | less
```

## Apply

Apply the Kustomization with:

```shell
/workspaces/home-server/kubernetes/argocd $ kubectl apply -k .
```

## Adding External Cluster

Use the `argocd` to quickly add external clusters
[CLI Docs](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_cluster_add/)

[Main Docs - without the CLI](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters)

## Links

- [ArgoCD Docs: Install with Kustomize](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#kustomize)

## TODO

[ArgoCD Extensions - Metrics](https://github.com/argoproj-labs/argocd-extension-metrics#install-ui-extension)
[ArgoCD Image Updater](https://github.com/argoproj-labs/argocd-image-updater)
