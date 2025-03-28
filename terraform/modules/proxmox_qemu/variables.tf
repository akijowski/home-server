variable "hostname" {
  type        = string
  description = "The VM name and hostname"
}

variable "target_node" {
  type        = string
  description = "Proxmox Node for this VM"
}

variable "vm_template_id" {
  type        = number
  description = "The VM Template ID on the Node"
}

variable "ipv4_addr" {
  type        = string
  description = "IPv4 address in CIDR (e.g. 1.2.3.4/24)"
  validation {
    condition     = var.ipv4_addr == "dhcp" || can(cidrnetmask(var.ipv4_addr))
    error_message = "Must be literal 'dhcp' or a valid IPv4 address with subnet mask"
  }
}

variable "extra_network_devices" {
  type = map(object({
    bridge  = string
    vlan_id = number
  }))
  description = "Map of extra network devices that will be added to the VM. A bridge 'vmbr0' is added by default"
  default     = {}
}

variable "disks" {
  type = map(object({
    datastore_id = optional(string, "local-lvm")
    interface    = string
    size         = number
  }))
  description = "Map of disks to provide to the VM. Must include the interface (virtio0) and disk size in GB. The first disk is assumed as the boot disk"
  validation {
    condition     = length(var.disks) > 0
    error_message = "Must provide at least one disk"
  }
}

variable "usb_devices" {
  type = map(object({
    host    = optional(string)
    mapping = optional(string)
    usb3    = optional(bool, false)
  }))
  description = "Map of USB devices to provide to the VM. Must use either host or mapping (cluster mapping name)"
  default     = {}
}

variable "vm_id" {
  type        = number
  default     = 0
  description = "The VM ID to use"
}

variable "description" {
  type        = string
  default     = "MY TF VM"
  description = "VM description. Markdown supported"
}

variable "extra_tags" {
  type        = list(string)
  default     = []
  description = "Set of additional tags to apply to the VM. Defaults are added by this module"
}

variable "on_boot" {
  type        = bool
  default     = false
  description = "Start this VM on host boot"
}

variable "started" {
  type        = bool
  default     = true
  description = "If this VM should be started after creation"
}

variable "cores" {
  type        = number
  default     = 1
  description = "The number of CPU cores for this VM"
}

variable "memory" {
  type        = number
  default     = 1024
  description = "The number in MiB of memory for this VM"
}

variable "ipv4_gw" {
  type        = string
  description = "The IPv4 Gateway (e.g. 1.2.3.4)"
  validation {
    condition     = var.ipv4_gw == null || can(cidrnetmask("${var.ipv4_gw}/24"))
    error_message = "Must be a valid IPv4 address"
  }
}

variable "vlan_id" {
  type        = number
  default     = 0
  description = "VLAN tag to add to the primary network device"
}

variable "network_bridge" {
  type        = string
  default     = "vmbr0"
  description = "The default bridge to attach to the vm"
}
