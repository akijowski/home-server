job "whoami" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = "Debugging app"
    link {
      label = "Web Page"
      url = "https://whoami.kijowski.casa"
  }
  link {
      label = "Github Repo"
      url = "https://github.com/traefik/whoami"
    }
  }

  group "whoami" {
    count = 1

    network {
      port "app" {
        to = 80
      }
    }

    service {
      provider = "nomad"
      name = "whoami"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.whoami.tls=true",
        "traefik.http.routers.whoami.tls.certresolver=dns-aws"
      ]
    }

    task "whoami" {
      driver = "podman"

      config {
        image = "docker.io/traefik/whoami:latest"
        ports = ["app"]
        args = [
            "--name=nomad-whoami",
            "--verbose"
        ]
      }

      resources {
        cpu = 60
        memory = 128
      }
    }
  }
}
