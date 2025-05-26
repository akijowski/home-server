variable "pve_url" {
  type        = string
  description = "Proxmox connection url, without the api2/json path"
}

variable "lxc_root_password" {
  type        = string
  description = "Default root password for LXC containers"
  sensitive   = true
}
