# Debian 11 (Bullseye)
# Packer build template Debian 11 (Bullseye) on Proxmox


# Proxmox plugin required
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


source "proxmox-iso" "Debian-11-Bullseye" {

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
     "<esc><wait>",
     "auto ",
#     "debconf/priority=critical ",
     "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
     "<enter><wait>"
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = 22
  ssh_timeout = "25m"  
}

build {
  sources = ["proxmox-iso.Debian-11-Bullseye"]

  provisioner "file" {
    pause_before = "15s"
    source = "file/regenerate_ssh_host_keys.service"
    destination = "/tmp/"
  }

  provisioner "shell" {
    pause_before = "20s"
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline = [
      "sleep 20",
      "sudo apt update",
      "sudo apt full-upgrade -y",
      "sudo apt autoremove",
      "sudo hostnamectl set-hostname debian-11-template",
      "sudo sed -i 's/^127\\.0\\.1\\.1\\s\\+debian\\b/127.0.1.1 debian-11-template/g' /etc/hosts",
      "sudo chmod 646 /etc/bash.bashrc",
      "sudo echo \"alias ll='ls -alF'\" >> /etc/bash.bashrc",
      "sudo chmod 644 /etc/bash.bashrc",
      // "sudo swapoff -a",
      // "sudo lvremove -f debian-vg/swap_1",
      // "sudo sed -i '/^\\/dev\\/mapper\\/debian--vg-swap_1/d' /etc/fstab",
      "sudo sed -i 's/^%sudo.*/%sudo   ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers",
      "sudo sed -i 's/quiet//g' /etc/default/grub",
      "sudo update-grub",
      "sudo rm -rfv /etc/ssh/ssh_host*",      
      "sudo mv /tmp/regenerate_ssh_host_keys.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable regenerate_ssh_host_keys.service",     
      "exit 0",
    ]
  }
}


##########################
# Definition of Variables
##########################

locals {
  build_date = formatdate("DDMMYY", timestamp())
  build_full_date = formatdate("DD.MM.YYYY", timestamp())
  build_iso_release = regex("debian-(\\d+\\.\\d+\\.\\d+)-.*\\.iso", var.iso_file)[0]
}

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