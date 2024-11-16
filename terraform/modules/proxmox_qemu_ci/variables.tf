variable "target_node" {
  type        = string
  description = "Target node for vm"
  default     = "hyperion"
}

variable "vmid" {
  type        = string
  description = "The VM ID, default to next available"
  default     = "0"
}

variable "name" {
  type        = string
  description = "The VM name"
}

variable "description" {
  type        = string
  description = "The VM Description"
  default     = "Managed by Terraform"
}

variable "extra_tags" {
  type        = list(string)
  description = "List of tags, default includes 'terraform'"
  default     = []
}

variable "clone" {
  type        = string
  description = "VM template base"
  default     = "ubuntu24-noble"
}

variable "cores" {
  type        = number
  description = "Number of CPU cores"
  default     = 1
}

variable "memory" {
  type        = number
  description = "VM memory in GiB"
  default     = 1024
}

variable "disk1_storage" {
  type        = string
  description = "target storage for virtio storage"
  default     = "local-lvm"
}

#
# Cloud Init
#
variable "ip0_ipv4" {
  type        = string
  description = "IPv4 config for ipconfig0"
  default     = "dhcp"
}

# variable "ci_user" {
#   type        = string
#   description = "Cloud-Init username"
# }

# variable "ci_password" {
#   type        = string
#   description = "Cloud-Init password"
#   sensitive   = true
# }

# variable "ci_ssh_keys" {
#   type        = string
#   description = "Cloud-Init SSH Keys, newline separated"
#   sensitive   = true
# }
