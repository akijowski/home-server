job "arm" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = "Automatic Ripping Machine (ARM). Automatically load MakeMKV when a disc is inserted."
  }

  group "app" {
    count = 1

    network {
      port "app" {
        to = 8080
      }
    }

    %{ for v in arm_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }
    volume "arm-config" {
      type = "csi"
      source = "arm-config"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      name = "arm"
      port = "app"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.arm.tls=true",
        "traefik.http.routers.arm.tls.certresolver=dns-aws"
      ]
    }

    task "arm" {
      driver = "podman"

      config {
        image = "docker.io/automaticrippingmachine/automatic-ripping-machine:${arm_image_tag}"
        ports = ["app"]
        privileged = true
      }

      %{ for v in arm_volumes }
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }
      volume_mount {
        volume = "arm-config"
        destination = "/etc/arm/config"
      }

      template {
        data = <<EOF
TZ=UTC
ARM_UID=1400
ARM_GID=1400
      EOF
        destination = "$${NOMAD_TASK_DIR}/arm.env"
        env = true
      }

      resources {
        cpu = 750
        memory = 512

        device "174c/usb" {}
      }
    }
  }
}
