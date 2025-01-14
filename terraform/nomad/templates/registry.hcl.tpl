job "registry" {
  datacenters = ${datacenters}
  type        = "service"
  namespace   = ${namespace}

  ui {
    description = "Simple self-hosted container registry"
    link {
      label = "Dashboard"
      url = "https://registry.kijowski.casa"
    }
  }

  group "ui" {
    count = 1

    meta {
      title = "Self-Hosted Docker Registry"
    }

    network {
      port "ui" {
        to = 80
      }
    }

    service {
      provider = "nomad"
      port = "ui"
      name = "$${TASKGROUP}-$${JOB}"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.ui-registry.rule=Host(`registry.kijowski.casa`)",
        "traefik.http.routers.ui-registry.tls=true",
        "traefik.http.routers.ui-registry.tls.certresolver=dns-aws"
      ]

      check {
        type = "tcp"
        port = "ui"
        interval = "30s"
        timeout = "5s"
      }
    }

    task "ui" {
      driver = "podman"

      config {
        image = "docker.io/joxit/docker-registry-ui:${registry_ui_image_tag}"
        ports = ["ui"]
      }

      template {
        data = <<EOF
REGISTRY_TITLE={{ env "NOMAD_META_title" }}
SINGLE_REGISTRY=true
DELETE_IMAGES=true
{{- range nomadService "registry" }}
NGINX_PROXY_PASS_URL=http://{{ .Address }}:{{ .Port }}
{{- end }}
      EOF
        destination = "$${NOMAD_TASK_DIR}/ui.env"
        env = true
      }
    }
  }

  group "registry" {
    count = 1

    network {
      port "app" {
        to = 5000
      }
    }

    volume "registry" {
      type = "csi"
      source = "container-registry"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      port = "app"
      name = "$${TASKGROUP}"
    }

    task "registry" {
      driver = "podman"

      config {
        image = "docker.io/registry:${registry_image_tag}"
        ports = ["app"]
      }

      volume_mount {
        volume = "registry"
        destination = "/var/lib/registry"
      }

      template {
        data = <<EOF
REGISTRY_STORAGE_DELETE_ENABLED=true
      EOF
        destination = "$${NOMAD_TASK_DIR}/registry.env"
        env = true
      }
    }
  }
}
