provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "this" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"

  namespace        = "ingress"
  create_namespace = true

  values = ["${file("values.yml")}"]
}
