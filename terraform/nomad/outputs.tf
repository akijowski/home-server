output "namespaces" {
  value = { for k, v in nomad_namespace.this : v.name => v.description }
}
