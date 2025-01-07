job "homebridge" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = "HomeKit support for the impatient"
    link {
      label = "Web Page"
      url = "https://homebridge.kijowski.casa"
    }
    link {
      label = "Project Page"
      url = "https://homebridge.io"
    }
    link {
      label = "Github Repo"
      url = "https://github.com/homebridge/docker-homebridge?tab=readme-ov-file"
    }
  }

  group "homebridge" {
    count = 1

    network {
      port "app" {
        static = 8581
      }
    }

    service {
      provider = "nomad"
      name = "homebridge"
      port = "app"

      check {
        name = "http_probe"
        type = "http"
        port = "app"
        path = "/"
        timeout = "5s"
        interval = "60s"

        check_restart {
          limit = 5
          grace = "10m"
        }
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.homebridge.tls=true",
        "traefik.http.routers.homebridge.tls.certresolver=dns-aws"
      ]
    }

    task "homebridge" {
      driver = "podman"

      config {
        image = "docker.io/homebridge/homebridge:${homebridge_image_version}"
        ports = ["app"]
        network_mode = "host"

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      template {
        data = <<EOF
TZ=UTC
      EOF
        destination = "$${NOMAD_TASK_DIR}/homebridge.env"
        env = true
      }

      resources {
        cpu = 500
        memory = 1024
      }
    }
  }
}
