// PVE Variables //
// Sensitive Variables to Pass as CLI Args or Env Vars
variable "pve_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "pve_username" {
  description = "Username when authenticating to Proxmox, including the realm."
  type        = string
  sensitive   = true
}

variable "pve_api_url" {
  description = "Proxmox API Endpoint, e.g. 'https://pve.example.com/api2/json'"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
    error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  }
}

// SSH Variables //
variable "ssh_username" {
  description = "SSH Username During Packer Build"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH Password During Packer Build"
  type        = string
  default     = "password"
  sensitive   = true
}

variable "ssh_timeout" {
  type    = string
  default = "20m"
}

variable "ssh_keypair_name" {
  default = "packer_id_ed25519"
  type    = string
}

variable "ssh_private_key_file" {
  description = "Private SSH Key for VM"
  default     = "~/.ssh/packer_id_ed25519"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_file" {
  description = "Public SSH Key for VM"
  default     = "~/.ssh/packer_id_ed25519.pub"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.ssh_public_key_file)) == false
    error_message = "ERROR Private SSH Key."
  }
}

// ISO vars
variable "iso_url" {
  type = map(string)
  default = {
    "debian12" = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
    "ubuntu24" = "https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso"
  }
}

variable "iso_checksum" {
  type = map(string)
  default = {
    "debian12" = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
    "ubuntu24" = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
  }
}

variable "boot_cmd_ubuntu22" {
  description = "Boot command for Ubuntu 22 & 24"
  type        = list(string)
  default = [
    "c",
    "linux /casper/vmlinuz --- autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot<enter>"
  ]
}

variable "boot_cmd_debian" {
  description = "Boot command for Debian"
  type        = list(string)
  default = [
    "<tab>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "auto=true ",
    "priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<wait><enter>"
  ]
}

// Image vars

variable vm_id {
  description = "Static VM IDs for each template"
  type        = map(number)
  default = {
    "debian12"        = 8100
    "ubuntu24"        = 8000
    "ubuntu24-podman" = 8010
  }
}
