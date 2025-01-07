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
  web:
    address: ":{{ env "NOMAD_PORT_http" }}"
    #http:
    #  redirections:
    #    entryPoint:
    #      to: websecure
    #      scheme: https
    #      permanent: true
  websecure:
    address: ":{{ env "NOMAD_PORT_https" }}"
    asDefault: true

providers:
  file:
    directory: "/rules"
  nomad:
    defaultRule: "Host(`{{`{{ .Name }}`}}.{{ env "NOMAD_META_domain" }}`)"
    # Force opt-in to traefik
    exposedByDefault: false
    namespaces:
      - "default"
      - "core"
    endpoint:
      address: '{{ env "NOMAD_META_nomad_address" }}'
      tls:
        ca: "/data/ca/intermediate.crt"

certificatesResolvers:
  dns-aws:
    acme:
      email: "{{ env "NOMAD_META_acme_email" }}"
      storage: data/acme/acme.json
      dnsChallenge:
        provider: route53
