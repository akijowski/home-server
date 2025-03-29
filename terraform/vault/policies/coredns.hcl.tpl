# Templated CoreDNS policy
# Managed by terraform

path "aws/sts/coredns" {
    capabilities = ["read", "create", "update"]
}
