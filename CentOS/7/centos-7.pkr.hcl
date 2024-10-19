# CentOS 7
# Packer build template CentOS 7 on Proxmox


# Proxmox plugin required
packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


source "proxmox-iso" "CentOS-7" {

  proxmox_url = var.proxmox_url
  insecure_skip_tls_verify = true
  username = var.proxmox_username
  password = var.proxmox_password
#  token = 
  node = var.proxmox_node

  vm_name = var.vm_name
  vm_id = var.vm_id
  template_description = var.vm_template_description
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
     "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>",
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_port = 22
  ssh_timeout = "25m"  
}

build {
  sources = ["proxmox-iso.CentOS-7"]

  provisioner "shell" {
    pause_before = "20s"
    inline = [
      "sleep 20",
      "sudo yum clean all",
      "sudo yum update -y",
      "sudo package-cleanup --oldkernels --count=1 -y",  
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