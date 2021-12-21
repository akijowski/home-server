provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "this" {
    name = "metallb"
    repository = "https://metallb.github.io/metallb"
    chart = "metallb"

    namespace = "metallb"
    create_namespace = true

    values = ["${file("values.yml")}"]
}
