job "fileflows" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = "Process any file"
    link {
      label = "Dashboard"
      url = "https://fileflows-server.kijowski.casa"
    }
  }

  group "server" {
    count = 1

    network {
      port "app" {
        to = 5000
      }
    }

    %{ for v in ff_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    service {
      provider = "nomad"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.fileflows.tls=true",
        "traefik.http.routers.fileflows.tls.certresolver=dns-aws"
      ]
    }

    task "server" {
      driver = "podman"

      config {
        image = "docker.io/revenz/fileflows:${ff_image_version}"
        force_pull = true # always pull latest
        ports = ["app"]
      }

      %{ for v in ff_volumes }
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }

      template {
        data = <<EOF
TZ=UTC
PUID=1400
PGID=1400
FFNODE=0
      EOF
        destination = "$${NOMAD_TASK_DIR}/fileflows.env"
        env = true
      }

      resources {
        cpu = 500
        memory = 512
      }
    }
  }
}
