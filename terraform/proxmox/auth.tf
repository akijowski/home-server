locals {
  users = {
    "ansible" = {
      id      = "ansible@pam"
      groups  = ["AnsibleInventory"]
      enabled = true
      comment = "Ansible - Managed by Terraform"
    }
    "packer" = {
      id      = "packer@pam"
      groups  = ["Packer"]
      enabled = true
      comment = "Packer - Managed by Terraform"
    }
  }
  groups = {
    "AnsibleInventory" = {
      comment = "Ansible Inventory (RO) - Managed by Terraform"
      acls = [{
        path      = "/"
        propagate = true
        role      = "AnsibleInventory"
      }]
    }
    "Packer" = {
      comment = "Packer Users - Managed by Terraform"
      acls = [{
        path      = "/"
        propagate = true
        role      = "PackerUser"
      }]
    }
  }

  roles = {
    "AnsibleInventory" = {
      privileges = [
        "Datastore.Audit",
        "Mapping.Audit",
        "Pool.Audit",
        "SDN.Audit",
        "Sys.Audit",
        "VM.Audit",
        "VM.Monitor"
      ]
    }
    "PackerUser" = {
      privileges = [
        "Datastore.Allocate",
        "Datastore.AllocateSpace",
        "Datastore.AllocateTemplate",
        "Datastore.Audit",
        "SDN.Use",
        "Sys.Audit",
        "Sys.Modify",
        "VM.Allocate",
        "VM.Audit",
        "VM.Clone",
        "VM.Config.CDROM",
        "VM.Config.CPU",
        "VM.Config.Cloudinit",
        "VM.Config.Disk",
        "VM.Config.HWType",
        "VM.Config.Memory",
        "VM.Config.Network",
        "VM.Config.Options",
        "VM.Console",
        "VM.Monitor",
        "VM.PowerMgmt"
      ]
    }
  }
}

resource "proxmox_virtual_environment_user" "this" {
  for_each = local.users

  user_id = each.value.id
  groups  = each.value.groups
  comment = each.value.comment
  enabled = each.value.enabled
}

resource "proxmox_virtual_environment_group" "this" {
  for_each = local.groups

  group_id = each.key
  comment  = each.value.comment

  dynamic "acl" {
    for_each = each.value.acls

    content {
      path      = acl.value["path"]
      propagate = acl.value["propagate"]
      role_id   = acl.value["role"]
    }
  }
}

resource "proxmox_virtual_environment_role" "this" {
  for_each = local.roles

  role_id    = each.key
  privileges = sort(each.value.privileges)
}
