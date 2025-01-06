job "traefik" {
  datacenters = ${datacenters}
  type        = "service"
  namespace   = ${namespace}

  # Traefik needs a static IP, so only run where the DNS records points
  constraint {
    attribute = "$${attr.unique.network.ip-address}"
    value = "${nomad_ipv4}"
  }

  ui {
    description = "Nomad cluster and on-prem reverse proxy"
    link {
      label = "Dashboard"
      url = "https://traefik.kijowski.casa/dashboard/"
    }
    link {
      label = "Documentation"
      url = "https://doc.traefik.io/traefik/"
    }
  }

  group "traefik" {
    count = 1

    meta {
      domain = "${domain}"
      nomad_address = "${nomad_address}"
      acme_email = "${acme_email}"
    }

    network {
      port "http" {
        static = "80"
      }
      port "https" {
        static = "443"
      }
    }

    volume "acme" {
      type = "csi"
      source = "traefik-acme"
      attachment_mode = "file-system"
      access_mode = "single-node-writer"
    }

    service {
      provider = "nomad"
      port     = "https"

      tags = [
        # https://doc.traefik.io/traefik/reference/dynamic-configuration/nomad/
        "traefik.enable=true",

        # dashboard
        "traefik.http.routers.dashboard.rule=Host(`traefik.${domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.tls=true",
        "traefik.http.routers.dashboard.tls.certresolver=dns-aws"
      ]

      check {
        type     = "tcp"
        port     = "http"
        interval = "30s"
        timeout  = "5s"
      }

      check {
        type     = "tcp"
        port     = "https"
        interval = "30s"
        timeout  = "5s"
      }
    }

    task "traefik" {
      driver = "podman"

      config {
        image        = "docker.io/traefik:${traefik_image_version}"
        ports        = ["http", "https"]
        network_mode = "host"

        volumes = [
          "local/traefik.yml:/traefik.yml",
          "local/rules:/rules",
          "secrets/intermediate.crt:/data/ca/intermediate.crt"
        ]

        labels = {
          "diun.enable"     = "true"
          "diun.watch_repo" = "true"
          "diun.max_tags"   = 3
        }
      }

      volume_mount {
        volume = "acme"
        destination = "/data/acme"
      }

      vault {
        role = "nomad-traefik"
      }

      identity {
        name = "vault_default"
        aud = ["vault.kijowski.casa"]
        change_mode = "signal"
        change_signal = "SIGHUP"
        ttl = "30m"
      }

      template {
        data        = <<EOF
${tpl_traefik}
EOF
        destination = "$${NOMAD_TASK_DIR}/traefik.yml"
      }

      template {
        data        = <<EOF
${tpl_traefik_rules}
EOF
        destination = "$${NOMAD_TASK_DIR}/rules/rules.yml"
      }

      template {
        data = <<EOF
      {{- with secret "pki_int/issuer/default/json" -}}
      {{- with .Data -}}
      {{- .certificate -}}
      {{- end -}}
      {{- end -}}
      EOF
        destination = "$${NOMAD_SECRETS_DIR}/intermediate.crt"
        change_mode = "restart"
      }

      template {
        data = <<EOF
      {{- with secret "aws/sts/traefik" "ttl=1h" -}}
      {{- with .Data -}}
      AWS_ACCESS_KEY_ID={{ .access_key }}
AWS_SECRET_ACCESS_KEY={{ .secret_key }}
AWS_SESSION_TOKEN={{ .session_token }}
AWS_REGION=us-east-1
      {{- end -}}
      {{- end -}}
      EOF
        destination = "$${NOMAD_SECRETS_DIR}/aws.env"
        env = true
      }

      resources {
        cpu    = 60
        memory = 128
      }
    }
  }
}
