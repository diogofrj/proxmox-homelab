locals {
  # global configurations
  agent         = 1
  proxmox_node  = "bee"
  onboot        = true
  template_id   = 9002
  template_name = "ubuntu-2404-cloud-init"
  # Base network configuration
  network = {
    base_ip = "192.168.31.0/24"
    gateway = "192.168.31.1"
    bridge  = "vmbr0"
    netmask = "24"
  }
  # VM base configurations
  vm_defaults = {
    cores     = 2
    memory    = 4096
    disk_size = 105
    tags      = ["node"]
    clone = {
      full = true
    }
    disk = {
      datastore_id = "local-lvm"
      file_format  = "qcow2"
      interface    = "scsi0"
      ssd         = true
      backup      = false 
      iothread    = true
      discard     = "on"
      size        = "105"
    }
  }
  # Configurações específicas para Master nodes
  nodes = {
    "MASTER" = {
      vmid          = 901
      ip_last_octet = 20
      cores         = 2
      memory        = 4096
      tags          = ["master"]
    }
    /*
    "WORKER1" = {
      vmid          = 902
      ip_last_octet = 21
      cores         = 2
      memory        = 2048
      tags          = ["worker1"]
    }
    "WORKER2" = {
      vmid          = 903
      ip_last_octet = 22
      cores         = 2
      memory        = 2048
      tags          = ["worker2"]
    }
    "WORKER3" = {
      vmid          = 904
      ip_last_octet = 23
      cores         = 2
      memory        = 2048
      tags          = ["worker3"]
    }
    */
  }
  # Combina nodes em um único mapa para uso geral
  vms = merge(local.nodes)
  # Cloud-init configurations
  cloud_init = {
    users           = ["ubuntu"]
    password        = "ubuntu"
    ssh_public_key  = file("~/.ssh/id_rsa.pub")
    authorized_keys = file("~/.ssh/authorized_keys")
    copy_authorized_keys = true
    authorized_keys_source = "~/.ssh/authorized_keys"

  }
}
#-----------------------------------------------------------------------------------------
resource "proxmox_virtual_environment_vm" "master_nodes" {
  for_each = local.nodes

  name      = each.key
  node_name = local.proxmox_node
  vm_id     = each.value.vmid
  tags      = local.vm_defaults.tags

  # Clone from template
  clone {
    vm_id = local.template_id
    full  = local.vm_defaults.clone.full
  }

  # CPU & Memory
  cpu {
    cores = each.value.cores
    numa  = true
    type  = "host"
    flags = [
      "+pcid",
      "+spec-ctrl",
      "+aes"
    ]
  }

  machine = "q35"

  memory {
    dedicated = each.value.memory
    
  }


  # Disk
  disk {
    datastore_id = local.vm_defaults.disk.datastore_id
    file_format  = local.vm_defaults.disk.file_format
    interface    = local.vm_defaults.disk.interface
    size         = local.vm_defaults.disk_size
    ssd         = local.vm_defaults.disk.ssd
    backup      = local.vm_defaults.disk.backup
    iothread    = local.vm_defaults.disk.iothread
    discard     = local.vm_defaults.disk.discard
  }

  # Network
  network_device {
    bridge = local.network.bridge
  }

  # Cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "192.168.31.${each.value.ip_last_octet}/${local.network.netmask}"
        gateway = local.network.gateway
      }
    }

    user_account {
      username = local.cloud_init.users[0]
      password = local.cloud_init.password
      keys     = [local.cloud_init.ssh_public_key]
    }
  }

  # Start on boot
  on_boot = local.onboot

  lifecycle {
    ignore_changes = [
      initialization,
      disk,
      vga,
      cpu,
      memory,
      machine
    ]
  }

}

output "MASTER" {
  value = "ssh ubuntu@192.168.31.${local.nodes.MASTER.ip_last_octet}"
}
# output "WORKER1" {
#   value = "ssh ubuntu@192.168.31.${local.nodes.WORKER1.ip_last_octet}"
# }
# output "WORKER2" {
#   value = "ssh ubuntu@192.168.31.${local.nodes.WORKER2.ip_last_octet}"
# }
# output "WORKER3" {
#   value = "ssh ubuntu@192.168.31.${local.nodes.WORKER3.ip_last_octet}"
# }
#-----------------------------------------------------------------------------------------
terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.31.180:8006/"
  api_token = "6215c36b-3cac-4335-b6d4-914420003088"
  insecure  = true
  ssh {
    agent    = true
    username = "terraform"
  }
}
