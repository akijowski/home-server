job "tdarr" {
  datacenters = ${datacenters}
  type = "service"
  namespace = ${namespace}

  ui {
    description = "Batch media transcoding. It's okay but can be better. Either DIY or look at FileFlows?"
    link {
      label = "Web Page"
      url = "https://tdarr.kijowski.casa"
    }
    link {
      label = "Docs"
      url = "https://docs.tdarr.io/docs/welcome/what"
    }
  }

  group "servers" {
    count = 1

    network {
      port "ui" {
        to = 8265
      }
      port "server" {
        to = 8266
      }
    }

    %{ for v in tdarr_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    service {
      provider = "nomad"
      name = "tdarr-ui"
      port = "ui"

      tags = []
    }

    service {
      provider = "nomad"
      port = "server"
    }

    task "server" {
      driver = "podman"

      config {
        image = "ghcr.io/haveagitgat/tdarr:${tdarr_image_version}"
        ports = ["ui", "server"]
      }

      %{ for v in tdarr_volumes }
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }

      template {
        data = <<EOF
serverIP=0.0.0.0
webUIPort=8265
serverPort=8266
inContainer=true
ffmpegVersion=7
TZ=America/Denver
PUID=1400
PGID=1400
nodeName=NomadTdarr_$${NOMAD_SHORT_ALLOC_ID}
      EOF
        destination = "$${NOMAD_TASK_DIR}/tdarr.env"
        env = true
      }

      resources {
        cpu = 2000
        memory = 2048
      }
    }
  }

  group "nodes" {
    count = 0

    network {
      port "server" {
        to = 8266
      }
    }

    %{ for v in tdarr_volumes }
    volume "${v.name}" {
      type = "host"
      source = "${v.src}"
    }
    %{ endfor }

    service {
      provider = "nomad"
      port = "server"
    }

    task "node" {
      driver = "podman"

      config {
        image = "ghcr.io/haveagitgat/tdarr_node:${tdarr_image_version}"
        ports = ["server"]
      }

      %{ for v in tdarr_volumes }
      volume_mount {
        volume = "${v.name}"
        destination = "${v.dest}"
      }
      %{ endfor }

      template {
        data = <<EOF
{{- with nomadServices "tdarr-servers-server" | sprig_first }}
serverIP={{ .Address }}:{{ .Port }}
{{- end }}
serverPort=8266
inContainer=true
ffmpegVersion=7
TZ=America/Denver
PUID=1400
PGID=1400
nodeName=NomadTdarrNode_$${NOMAD_SHORT_ALLOC_ID}
      EOF
        destination = "$${NOMAD_TASK_DIR}/tdarr.env"
        env = true
      }

      resources {
        cpu = 3000
        memory = 3072
      }
    }
  }
}
