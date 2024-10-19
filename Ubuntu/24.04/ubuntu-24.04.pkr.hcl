# Ubuntu Server 24.04 (Noble Numbat)
# Packer build template Ubuntu Server 24.04 (Noble Numbat) on Proxmox


# Proxmox plugin required
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
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

  vm_name = "${var.vm_name}-${local.build_date}"
  vm_id = var.vm_id
  template_description = "${var.vm_template_description}-Release(${local.build_iso_release})-${local.build_full_date}"
  onboot = true

  boot_iso {
    iso_file = var.iso_file
    unmount = true
  }

  os = "l26"
  qemu_agent = true
  scsi_controller = "virtio-scsi-single"
  disks {
    type = "scsi"
    format = "qcow2"
    disk_size = var.vm_disk_size
    storage_pool = var.vm_storage_pool
  }

  cores = var.vm_cores
  sockets = 1
  cpu_type = "host"
  memory = var.vm_memory

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

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = 22
  ssh_timeout = "25m"  
}

build {
  sources = ["proxmox-iso.Ubuntu-Server-24_04-Noble"]

  provisioner "shell" {
    pause_before = "20s"
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "sleep 20",
      "sudo apt update",
      "sudo apt full-upgrade -y",
      "sudo apt autoremove",
#      "sudo localectl set-locale LC_TIME=en_GB.UTF-8",   ## time en_GB.UTF-8 -> 24h , en_US.UTF-8 AM/PM 12
      "sudo truncate -s 0 /etc/machine-id",   ### Generate new machine-id on first boot
      "sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"ipv6.disable=1\"/' /etc/default/grub",   ### Disable IPv6
      "sudo update-grub",    ### Update grub for disable IPv6
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

variable "vm_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "vm_template_description" {
  type = string
}

variable "iso_file" {
  type = string
}

variable "vm_disk_size" {
  type = string
}

variable "vm_storage_pool" {
  type = string
}

variable "vm_cores" {
  type = number
}

variable "vm_memory" {
  type = number
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type = string
}

locals {
  build_date = formatdate("DDMMYY", timestamp())
  build_full_date = formatdate("DD.MM.YYYY", timestamp())
  build_iso_release = regex("ubuntu-(\\d+\\.\\d+\\.\\d+)-.*\\.iso", var.iso_file)[0]
}