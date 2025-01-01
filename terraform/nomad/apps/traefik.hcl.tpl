job "traefik" {
  datacenters = ${datacenters}
  type        = "service"
  namespace   = ${namespace}

  # Traefik needs a static IP, so only run where the DNS records points
  constraint {
    attribute = "$${attr.unique.network.ip-address}"
    value = "192.168.50.32"
  }

  group "traefik" {
    count = 1

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
      access_mode = "single-node-writer"
      attachment_mode = "file-system"
    }

    service {
      provider = "nomad"
      port     = "https"

      tags = [
        # https://doc.traefik.io/traefik/reference/dynamic-configuration/nomad/
        "traefik.enable=true",

        # dashboard
        "traefik.http.routers.dashboard.rule=Host(`traefik.${domain}`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))",
        "traefik.http.routers.dashboard.server=api@internal"

        # http to https redirect
        # "traefik.http.routers.http-catch.entrypoints=http",
        # "traefik.http.routers.http-catch.rule=HostRegexp(`{host:.+}`)",
        # "traefik.http.routers.http-catch.middlewares=redirect-to-https",
        # "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https",

        # https router
        # "traefik.http.routers.traefik-router.entrypoints=https",
        # "traefik.http.routers.traefik-router.rule=Host(`${domain}`)",
        # "traefik.http.routers.traefik-router.service=api@internal",

        # "traefik.http.routers.traefik-router.tls=true",
        # Comment out the below line after first run of traefik to force the use of wildcard certs
        # "traefik.http.routers.traefik-router.tls.certResolver=dns-dgo",
        # "traefik.http.routers.traefik-router.tls.domains[0].main=${domain}",
        # "traefik.http.routers.traefik-router.tls.domains[0].sans=*.${domain}"
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
          "local/rules:/rules"
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

      template {
        data        = <<EOF
global:
  checkNewVersion: true
  sendAnonymousUsage: false

api:
  insecure: false
  dashboard: true

ping: {}

log:
  level: "INFO"

accessLog:
  filePath: "/logs/access.log"
  filters:
    statusCodes: "400-499"

entrypoints:
  http:
    address: ":{{ env "NOMAD_PORT_http" }}"
  https:
    address: ":{{ env "NOMAD_PORT_https" }}"

providers:
  file:
    directory: "/rules"
  nomad:
    endpoint:
      address: 'https://${nomad_address}:4646'
      tls:
        insecureSkipVerify: true #TODO: load a cert from Vault
EOF
        destination = "$${NOMAD_TASK_DIR}/traefik.yml"
      }

      template {
        data        = <<EOF
http:
  routers:
    nomad:
      entryPoints:
        - http # comment out after setting up tls
        - https
      rule: "Host(`nomad.${domain}`)"
      tls: {}
      middlewares:
        - default-headers
      service: nomad

  services:
    nomad:
      loadBalancer:
        servers:
          - url: "https://${nomad_address}:4646"
        serversTransport: insecureTransport

  serversTransports:
    insecureTransport:
      insecureSkipVerify: true

  middlewares:
    default-headers:
      headers:
        frameDeny: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
EOF
        destination = "$${NOMAD_TASK_DIR}/rules/rules.yml"
      }

      resources {
        cpu    = 60
        memory = 128
      }
    }
  }
}
