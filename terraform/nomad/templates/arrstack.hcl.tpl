job "arr-stack" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = <<EOF
      The *arr stack of applications for media management.
      These apps work together to manage and enhance the Plex media library.
      Based on this Reddit post: https://www.reddit.com/r/PleX/comments/15sv4lo/do_i_need_sonarrradarr_to_use_bazarr/
  EOF
    link {
      label = "Radarr - Videos"
      url = "https://radarr.kijowski.casa"
    }
    link {
      label = "Sonarr - TV Shows"
      url = "https://sonarr.kijowski.casa"
    }
    link {
      label = "Bazarr - Subtitles"
      url = "https://bazarr.kijowski.casa"
    }
  }

  group "radarr" {
    count = 1

    network {
      port "app" {
        to = 7878
      }
    }

    %{for v in arr_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    volume "radarr-config" {
      type = "csi"
      source = "radarr-config"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      name = "radarr"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.radarr.tls=true",
        "traefik.http.routers.radarr.tls.certresolver=dns-aws"
      ]
    }

    task "radarr" {
      driver = "podman"

      config {
        image = "ghcr.io/hotio/radarr:${radarr_image_tag}"
        ports = ["app"]
      }

      %{for v in arr_volumes}
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }
      volume_mount {
        volume = "radarr-config"
        destination = "/config"
      }

      template {
        data = <<EOF
TZ=UTC
PUID=1000
PGID=1000
      EOF
        destination = "$${NOMAD_TASK_DIR}/radarr.env"
        env = true
      }

      resources {
        cpu = 250
        memory = 256
      }
    }
  }

  group "sonarr" {
    count = 1

    network {
      port "app" {
        to = 8989
      }
    }

    %{for v in arr_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    volume "sonarr-config" {
      type = "csi"
      source = "sonarr-config"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      name = "sonarr"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.sonarr.tls=true",
        "traefik.http.routers.sonarr.tls.certresolver=dns-aws"
      ]
    }

    task "sonarr" {
      driver = "podman"

      config {
        image = "ghcr.io/hotio/sonarr:${sonarr_image_tag}"
        ports = ["app"]
      }

      %{for v in arr_volumes}
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }
      volume_mount {
        volume = "sonarr-config"
        destination = "/config"
      }

      template {
        data = <<EOF
TZ=UTC
PUID=1100
PGID=1100
      EOF
        destination = "$${NOMAD_TASK_DIR}/sonarr.env"
        env = true
      }

      resources {
        cpu = 250
        memory = 256
      }
    }
  }

  group "bazarr" {
    count = 1

    network {
      port "app" {
        to = 6767
      }
    }

    %{for v in arr_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    volume "bazarr-config" {
      type = "csi"
      source = "bazarr-config"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      name = "bazarr"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.bazarr.tls=true",
        "traefik.http.routers.bazarr.tls.certresolver=dns-aws"
      ]
    }

    task "bazarr" {
      driver = "podman"

      config {
        image = "ghcr.io/hotio/bazarr:${bazarr_image_tag}"
        ports = ["app"]
      }

      %{for v in arr_volumes}
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }
      volume_mount {
        volume = "bazarr-config"
        destination = "/config"
      }

      template {
        data = <<EOF
TZ=UTC
PUID=1300
PGID=1300
WEBUI_PORTS="6767/tcp,6767/udp"
      EOF
        destination = "$${NOMAD_TASK_DIR}/bazarr.env"
        env = true
      }

      resources {
        cpu = 250
        memory = 256
      }
    }
  }
}
