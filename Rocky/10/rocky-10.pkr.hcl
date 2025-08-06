# Rocky Linux 10
# Packer build template Rocky Linux 10 on Proxmox


# Proxmox plugin required
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


source "proxmox-iso" "Rocky-10" {

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
    format = "raw"
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
     "<up><up>",
     "e",
     "<down><down>",
     "<leftCtrlOn>e<leftCtrlOff>",
     "<spacebar>",
     "inst.text",
     "<spacebar>",
     "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
     "<leftCtrlOn>x<leftCtrlOff>", 
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = 22
  ssh_timeout = "25m"  
}

build {
  sources = ["proxmox-iso.Rocky-10"]

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "sleep 20",
      "sudo dnf clean all",
      "sudo dnf update -y",
      "sudo dnf remove --oldinstallonly --setopt installonly_limit=2 kernel -y",
      "sudo dnf distro-sync -y",
      "sudo sed -i 's/rhgb quiet//g' /etc/default/grub",
      "sudo grub2-mkconfig -o /boot/grub2/grub.cfg",
      "sudo grubby --update-kernel=ALL --remove-args=\"rhgb quiet\"",
      "sudo rm -rf /etc/ssh/ssh_host_*",  
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
  build_iso_release = regex("Rocky-(\\d+\\.\\d+)-.*\\.iso", var.iso_file)[0]
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
