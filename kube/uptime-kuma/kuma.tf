provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels = {
      app = local.app_name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = local.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.app_name
        }
      }
      spec {
        container {
          image = "louislam/uptime-kuma:1"
          name  = local.app_name
          port {
            container_port = 3001
            name           = "http"
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            failure_threshold     = 3
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 15
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            failure_threshold     = 3
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 15
          }
          volume_mount {
            mount_path = "/app/data"
            name       = "app-data"
          }
        }
        volume {
          name = "app-data"
          persistent_volume_claim {
            claim_name = local.app_name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels = {
      app = local.app_name
    }
  }
  spec {
    selector = {
      app = local.app_name
    }
    port {
      name        = "http"
      port        = 3001
      target_port = "http"
      # node_port = 63001
    }
  }
}

resource "kubernetes_persistent_volume" "this" {
  metadata {
    name = local.pv_name
  }
  spec {
    capacity = {
      storage = "512Mi"
    }
    access_modes       = local.pv_access_modes
    storage_class_name = local.pv_storage_class_name
    persistent_volume_source {
      host_path {
        path = "${local.host_path_root}/${local.pv_name}"
      }
    }
    persistent_volume_reclaim_policy = "Delete"
  }
}

resource "kubernetes_persistent_volume_claim" "this" {
  metadata {
    name      = local.app_name
    namespace = local.namespace
  }
  spec {
    access_modes = local.pv_access_modes
    resources {
      requests = {
        storage = "512Mi"
      }
    }
    volume_name        = kubernetes_persistent_volume.this.metadata.0.name
    storage_class_name = local.pv_storage_class_name
  }
}

resource "random_uuid" "pv_name" {
}

locals {
  app_name              = "uptime-kuma"
  host_path_root        = "/var/snap/microk8s/common/default-storage"
  namespace             = "monitoring"
  pv_access_modes       = ["ReadWriteOnce"]
  pv_name               = "pv-${random_uuid.pv_name.id}"
  pv_storage_class_name = "microk8s-hostpath"
}
