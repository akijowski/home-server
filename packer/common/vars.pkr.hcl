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
// These are used by Packer to provision the template
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

// This is used in the cloud-init
variable "ansible_ssh_public_key_file" {
  description = "Public SSH Key for Ansible user"
  default     = "~/.ssh/github_akijowski.pub"
  type        = string
  sensitive   = true
  validation {
    condition     = can(regex("(?i)PRIVATE", var.ansible_ssh_public_key_file)) == false
    error_message = "ERROR Private SSH Key."
  }
}

// ISO vars
variable "iso_url" {
  type = map(string)
  default = {
    "debian12" = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
    "ubuntu24" = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
    "rocky8"   = ""
    "rocky9"   = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  }
}

variable "iso_file" {
  type = map(string)
  default = {
    "debian12" = ""
    "ubuntu24" = "nfs-isos:iso/ubuntu-24.04.1-live-server-amd64.iso"
    "rocky9"   = "nfs-isos:iso/Rocky-9.5-x86_64-minimal.iso"
  }
}

variable "iso_checksum" {
  type = map(string)
  default = {
    "debian12" = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
    "ubuntu24" = "file:https://releases.ubuntu.com/24.04/SHA256SUMS"
    "rocky9"   = "file:https://download.rockylinux.org/pub/rocky/9/isos/x86_64/CHECKSUM"
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

variable "boot_cmd_rocky9" {
  description = "Boot command for Rockylinux"
  type        = list(string)
  default = [
    // This sends the "up arrow" key, typically used to navigate through boot menu options.
    "<up>",
    // This sends the "e" key. In the GRUB boot loader, this is used to edit the selected boot menu option.
    "e",
    // This sends two "down arrow" keys, followed by the "end" key, and then waits. This is used to navigate to a specific line in the boot menu option's configuration.
    "<down><down><end><wait>",
    // This is used to modify the boot menu option's configuration to boot in text mode and specify the kickstart data source configured in the common variables.
    "text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    // This sends the "enter" key, waits, turns on the left control key, sends the "x" key, and then turns off the left control key. This is used to save the changes and exit the boot menu option's configuration, and then continue the boot process.
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
  ]
}

// Image vars
variable "target_node" {
  description = "Target node to create the template"
  type        = string
  default     = "hyperion"
  validation {
    condition     = contains(["hyperion", "pve01", "pve02"], var.target_node)
    error_message = "Must be one of [hyperion, pve01, pve02]."
  }
}

variable "template_description_extra" {
  description = "Additional template description"
  type        = string
  default     = ""
}

variable "vm_id" {
  description = "The template VM ID. Setting to 0 will use the next available. Setting to -1 will use defaults defined by the source. Only use this with the -only flag to create a single image on a single node"
  type        = number
  default     = -1
}

variable "vm_bios" {
  description = "BIOS configuration for VM. Default to seabios. Allowed [seabios, ovmf]"
  type        = string
  default     = "seabios"
}
