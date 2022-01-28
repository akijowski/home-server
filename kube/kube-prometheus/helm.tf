provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "this" {
    name = "kube-prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    version = "30.2.0"

    namespace = "monitoring"
    create_namespace = true

    values = ["${file("values.yml")}"]
}
