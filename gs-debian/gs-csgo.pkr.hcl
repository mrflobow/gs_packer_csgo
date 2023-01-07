variable "iso_file" {
  type    = string
  default = "isos:iso/debian-11.6.0-amd64-netinst.iso"
}

variable "cloudinit_storage_pool" {
  type    = string
  default = "local"
}

variable "cores" {
  type    = string
  default = "2"
}

variable "disk_format" {
  type    = string
  default = "raw"
}

variable "disk_size" {
  type    = string
  default = "40G"
}

variable "disk_storage_pool" {
  type    = string
  default = "vm-pool"
}

variable "disk_storage_pool_type" {
  type    = string
  default = "zfs"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "network_vlan" {
  type    = string
  default = ""
}

variable "proxmox_api_token_id" {
  type      = string
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "steam_token" {
  type = string
  sensitive = true
}

source "proxmox-iso" "gameserver" {

  proxmox_url = "${var.proxmox_api_url}"
  username = "${var.proxmox_api_token_id}"
  token = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true


  template_description = "CounterStrike GO Gameserver template. Built on ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}"
  node                 = var.proxmox_node
  vm_id = 4001
  network_adapters {
    bridge   = "vmbr0"
    firewall = true
    model    = "virtio"
    vlan_tag = var.network_vlan
  }
  disks {
    disk_size         = var.disk_size
    format            = var.disk_format
    io_thread         = true
    storage_pool      = var.disk_storage_pool
    storage_pool_type = var.disk_storage_pool_type
    type              = "scsi"
  }
  scsi_controller = "virtio-scsi-single"

  iso_file       = var.iso_file
  http_directory = "./"
  boot_wait      = "10s"
  boot_command   = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
  unmount_iso    = true

  cloud_init              = true
  cloud_init_storage_pool = var.cloudinit_storage_pool

  vm_name  = "gs-csgo"
  #cpu_type = "EPYC"
  os       = "l26"
  memory   = var.memory
  cores    = var.cores
  sockets  = "1"

  ssh_password = "packer"
  ssh_username = "root"
}

build {
  sources = ["source.proxmox-iso.gameserver"]

  provisioner "file" {
    destination = "/etc/cloud/cloud.cfg"
    source      = "files/cloud.cfg"
  }

  provisioner "file" {
    destination = "/etc/apt/sources.list"
    source      = "files/sources.list"
  }
    # Custom Steam Server Magic

  #Create steam user

   provisioner "shell" {
      inline = [
        "useradd -m steam",
        ]

   }
  
    # Install required packages
  provisioner "shell" {
      inline = [
        "sudo apt update",
        "sudo apt install software-properties-common -y",
        "sudo dpkg --add-architecture i386",
        "sudo apt update",
        "echo steam steam/question select \"I AGREE\" | sudo debconf-set-selections",
        "echo steam steam/license note '' | sudo debconf-set-selections",
        "sudo apt install lib32gcc-s1 steamcmd -y"
      ]
  }
  #Add Gamespecific scripts
  provisioner "file" {
    destination = "/home/steam/csgo_install.txt"
    source      = "files/csgo_install.txt"
  }

  #Download Game
  provisioner "shell" {
      inline = [
        "sudo chown steam:steam /home/steam/csgo_install.txt",
        "sudo -u steam /usr/games/steamcmd +runscript /home/steam/csgo_install.txt"
      ]
  }

  #Add Steam Token
  provisioner "shell" {
      inline = [
        "sudo -u steam echo ${var.steam_token } > /home/steam/.token"
      ]
  }

  provisioner "file" {
    destination = "/etc/systemd/system/csgo.service"
    source      = "files/csgo.service"
  }

  provisioner "file" {
    destination = "/home/steam/csgo.sh"
    source      = "files/csgo.sh"
  }

  provisioner "file" {
    destination = "/home/steam/csgo/csgo/cfg/server.cfg"
    source      = "../serverfiles/server.cfg"
  }

  provisioner "shell" {
      inline = [
        "sudo chown steam:steam /home/steam/csgo.sh",
        "sudo chown steam:steam /home/steam/csgo/csgo/cfg/server.cfg",
        "sudo chmod u+x /home/steam/csgo.sh",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable csgo"
      ]
  }



}
