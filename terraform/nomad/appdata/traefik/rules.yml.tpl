http:
  routers:
    nomad:
      rule: "Host(`nomad.{{ env "NOMAD_META_domain" }}`)"
      tls:
        certResolver: dns-aws
      middlewares:
        - default-headers
      service: nomad
    arm:
      rule: "Host(`arm.{{ env "NOMAD_META_domain" }}`)"
      tls:
        certResolver: dns-aws
      service: arm

  services:
    nomad:
      loadBalancer:
        servers:
          - url: "{{ env "NOMAD_META_nomad_address" }}"
        serversTransport: insecureTransport
    arm:
      loadBalancer:
        servers:
          - url: "http://192.168.50.13:8080"

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
