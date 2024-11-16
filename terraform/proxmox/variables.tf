variable "pve_api_url" {
  type        = string
  description = "Proxmox connection url, including the api2/json path"
  validation {
    condition     = can(regex("(?i)^http[s]?://.*/api2/json$", var.pve_api_url))
    error_message = "Proxmox API Endpoint Invalid. Check URL - Scheme and Path required."
  }
}
