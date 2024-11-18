<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

## Providers

The following providers are used by this module:

- <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [proxmox_vm_qemu.this](https://registry.terraform.io/providers/telmate/proxmox/latest/docs/resources/vm_qemu) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_name"></a> [name](#input\_name)

Description: The VM name

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_clone"></a> [clone](#input\_clone)

Description: VM template base

Type: `string`

Default: `"ubuntu24-noble"`

### <a name="input_cores"></a> [cores](#input\_cores)

Description: Number of CPU cores

Type: `number`

Default: `1`

### <a name="input_description"></a> [description](#input\_description)

Description: The VM Description

Type: `string`

Default: `"Managed by Terraform"`

### <a name="input_disk1_storage"></a> [disk1\_storage](#input\_disk1\_storage)

Description: target storage for virtio storage

Type: `string`

Default: `"local-lvm"`

### <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags)

Description: List of tags, default includes 'terraform'

Type: `list(string)`

Default: `[]`

### <a name="input_ip0_ipv4"></a> [ip0\_ipv4](#input\_ip0\_ipv4)

Description: IPv4 config for ipconfig0

Type: `string`

Default: `"dhcp"`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: VM memory in GiB

Type: `number`

Default: `1024`

### <a name="input_target_node"></a> [target\_node](#input\_target\_node)

Description: Target node for vm

Type: `string`

Default: `"hyperion"`

### <a name="input_vmid"></a> [vmid](#input\_vmid)

Description: The VM ID, default to next available

Type: `string`

Default: `"0"`

## Outputs

No outputs.
<!-- END_TF_DOCS -->