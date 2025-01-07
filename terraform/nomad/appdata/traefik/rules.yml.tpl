http:
  routers:
    nomad:
      rule: "Host(`nomad.{{ env "NOMAD_META_domain" }}`)"
      tls:
        certResolver: dns-aws
      middlewares:
        - default-headers
      service: nomad

  services:
    nomad:
      loadBalancer:
        servers:
          - url: "{{ env "NOMAD_META_nomad_address" }}"
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
