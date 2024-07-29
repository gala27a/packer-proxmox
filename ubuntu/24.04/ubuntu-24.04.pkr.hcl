# Ubuntu Server 24.04 (Noble Numbat)
# Packer build template Ubuntu Server 24.04 (Noble Numbat) on Proxmox


# Proxmox plugin required
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
