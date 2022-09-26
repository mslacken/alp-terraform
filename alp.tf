terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
variable "nr_machines" {
  default = "1"
}

variable "alp_image" {
  default = "ALP-VM.x86_64-0.0.1-kvm-Build13.5.qcow2"
  #default = "ALP-VM.x86_64-0.0.1-kvm_encrypted-Build14.1.qcow2"
}


provider "libvirt" {
  uri = "qemu:///system"
}

resource "random_id" "server" {
  count       = var.nr_machines
  byte_length = 4
}

resource "random_id" "net" {
  byte_length = 2
}

resource "random_integer" "ip_prefix" {
  min = 0
  max = 254
}

resource "libvirt_volume" "rootdisk" {
  name   = "terraform-vdisk-${element(random_id.server.*.hex, count.index)}.qcow2"
  count  = var.nr_machines
  pool   = "tmp"
  source = var.alp_image
  format = "qcow2"
}

resource "libvirt_volume" "combustion" {
  name = "ignition.raw"
  pool = "tmp"
  source = "ignition.raw"
}

resource "libvirt_network" "my_net" {
  name      = "tf-net-alp-${random_id.net.hex}"
  addresses = ["10.10.${random_integer.ip_prefix.result}.1/24", "fdaa:10:10:${random_integer.ip_prefix.result}::1/64"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "domain-alp" {
  name = "terraform-vm-alp-${element(random_id.server.*.hex, count.index)}"

  memory = "12288"
  vcpu   = 12
  count  = var.nr_machines
  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = libvirt_network.my_net.id
    wait_for_lease = true
    hostname       = "alp-${element(random_id.server.*.hex, count.index)}"
  }

  disk {
    volume_id = libvirt_volume.rootdisk[count.index].id
  }

  disk {
    volume_id = libvirt_volume.combustion.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = "true"
  }
}

output "vm_ips" {
  value = libvirt_domain.domain-alp.*.network_interface.0.addresses
}

output "vm_names" {
  value = libvirt_domain.domain-alp.*.name
}

