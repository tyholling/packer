source "qemu" "ubuntu" {
  boot_command = [
    "<esc>c<wait>",
    "linux /casper/vmlinuz",
    " autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "1ms"
  boot_wait         = "-1s"
  communicator = "none"
  cpus         = "8"
  disk_size    = "100G"
  firmware     = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/user-data" = file("user-data")
    "/meta-data" = ""
  }
  iso_checksum     = "file:https://cdimage.ubuntu.com/releases/24.10/release/SHA256SUMS"
  iso_target_path  = "ubuntu-24.10-live-server-arm64.iso"
  iso_url          = "https://cdimage.ubuntu.com/releases/24.10/release/ubuntu-24.10-live-server-arm64.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "menu=on,splash-time=0"],
    ["-cpu", "host"],
    ["-device", "virtio-rng-device"],
    ["-device", "virtio-scsi-device"],
    ["-device", "scsi-hd,drive=disk"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-display", "none"],
    ["-drive", "file=ubuntu.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=ubuntu-24.10-live-server-arm64.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "ubuntu.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.ubuntu"]
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}
