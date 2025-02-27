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

- [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_disks"></a> [disks](#input\_disks)

Description: Map of disks to provide to the VM. Must include the interface (virtio0) and disk size in GB. The first disk is assumed as the boot disk

Type:

```hcl
map(object({
    datastore_id = optional(string, "local-lvm")
    interface    = string
    size         = number
  }))
```

### <a name="input_hostname"></a> [hostname](#input\_hostname)

Description: The VM name and hostname

Type: `string`

### <a name="input_ipv4_addr"></a> [ipv4\_addr](#input\_ipv4\_addr)

Description: IPv4 address in CIDR (e.g. 1.2.3.4/24)

Type: `string`

### <a name="input_ipv4_gw"></a> [ipv4\_gw](#input\_ipv4\_gw)

Description: The IPv4 Gateway (e.g. 1.2.3.4)

Type: `string`

### <a name="input_target_node"></a> [target\_node](#input\_target\_node)

Description: Proxmox Node for this VM

Type: `string`

### <a name="input_vm_template_id"></a> [vm\_template\_id](#input\_vm\_template\_id)

Description: The VM Template ID on the Node

Type: `number`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_cores"></a> [cores](#input\_cores)

Description: The number of CPU cores for this VM

Type: `number`

Default: `1`

### <a name="input_description"></a> [description](#input\_description)

Description: VM description. Markdown supported

Type: `string`

Default: `"MY TF VM"`

### <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags)

Description: Set of additional tags to apply to the VM. Defaults are added by this module

Type: `list(string)`

Default: `[]`

### <a name="input_memory"></a> [memory](#input\_memory)

Description: The number in MiB of memory for this VM

Type: `number`

Default: `1024`

### <a name="input_on_boot"></a> [on\_boot](#input\_on\_boot)

Description: Start this VM on host boot

Type: `bool`

Default: `false`

### <a name="input_started"></a> [started](#input\_started)

Description: If this VM should be started after creation

Type: `bool`

Default: `true`

### <a name="input_usb_devices"></a> [usb\_devices](#input\_usb\_devices)

Description: Map of USB devices to provide to the VM. Must use either host or mapping (cluster mapping name)

Type:

```hcl
map(object({
    host    = optional(string)
    mapping = optional(string)
    usb3    = optional(bool, false)
  }))
```

Default: `{}`

### <a name="input_vlan_id"></a> [vlan\_id](#input\_vlan\_id)

Description: VLAN tag to add to the primary network device

Type: `number`

Default: `0`

### <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id)

Description: The VM ID to use

Type: `number`

Default: `0`

## Outputs

No outputs.
<!-- END_TF_DOCS -->