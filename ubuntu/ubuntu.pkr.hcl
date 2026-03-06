source "qemu" "ubuntu" {
  accelerator = "hvf"
  boot_command = [
    "<esc>c<wait>",
    "linux /casper/vmlinuz",
    " autoinstall ds=nocloud\\;s=http://1.0.0.1/<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "1ms"
  boot_wait         = "-1s"
  communicator      = "none"
  cpus              = 4
  disk_size         = "100G"
  firmware          = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  format            = "raw"
  http_content = {
    "/user-data" = file("user-data")
    "/meta-data" = ""
  }
  iso_checksum     = "file:ubuntu.iso.sha256"
  iso_target_path  = "ubuntu.iso"
  iso_url          = "ubuntu.iso"
  memory           = 4096
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
    ["-drive", "file=ubuntu.img,if=none,format=raw,id=disk"],
    ["-drive", "file=ubuntu.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"],
    ["-netdev", "user,id=user.0,net=1.0.0.0/8,restrict=on,guestfwd=tcp:1.0.0.1:80-tcp::{{ .HTTPPort }}"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "ubuntu.img"
  vnc_use_password = true
}

build {
  sources = [
    "source.qemu.ubuntu"
  ]
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.0"
    }
  }
}
