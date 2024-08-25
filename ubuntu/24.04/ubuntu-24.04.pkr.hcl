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


source "proxmox-iso" "Ubuntu-Server-24_04-Noble" {

  proxmox_url = var.proxmox_url
  insecure_skip_tls_verify = true
  username = var.proxmox_username
  password = var.proxmox_password
#  token = 
  node = var.proxmox_node

  vm_name = "Ubuntu-Server-2404-Template"
  vm_id = var.vm_id
  template_description = "Ubuntu-Server-24.04(Noble)"
  onboot = true

  iso_file = var.iso_file
  unmount_iso = true
  os = "l26"

  qemu_agent = true
  scsi_controller = "virtio-scsi-single"
  disks {
    type = "scsi"
    format = "qcow2"
    disk_size = "15G"
    storage_pool = var.vm_storage_pool
  }

  cores = 2
  sockets = 1
  cpu_type = "host"
  memory = 2048

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }  

  http_directory = "http"
  boot_wait = "5s"
  boot_command = [
    "<esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>",
    "<enter><f10><wait>"    
  ]

  ssh_username = "packer"
  ssh_password = "P@ckerADM"
  ssh_port = 22
  ssh_timeout = "35m"  
}

build {
  sources = ["proxmox-iso.Ubuntu-Server-24_04-Noble"]

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "sleep 30",
      "exit 0",
    ]
  }
}


##########################
# Definition of Variables
##########################

variable "proxmox_url" {
    type = string
}

variable "proxmox_username" {
    type = string
}

variable "proxmox_password" {
    type = string
}

variable "proxmox_node" {
    type = string
}

variable "vm_id" {
    type = number
}

variable "iso_file" {
    type = string
}

variable "vm_storage_pool" {
    type = string
}