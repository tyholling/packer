source "qemu" "fedora" {
  boot_command = [
    "<esc>c<wait>",
    "linux /images/pxeboot/vmlinuz",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg<enter><wait>",
    "initrd /images/pxeboot/initrd.img<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "1ms"
  boot_wait         = "-1s"
  communicator      = "none"
  cpus              = "8"
  disk_size         = "100G"
  firmware          = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/kickstart.cfg" = file("kickstart.cfg")
  }
  iso_checksum     = "file:https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-42-1.1-aarch64-CHECKSUM"
  iso_target_path  = "Fedora-Server-dvd-aarch64-42-1.1.iso"
  iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/aarch64/iso/Fedora-Server-dvd-aarch64-42-1.1.iso"
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
    ["-drive", "file=fedora.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=Fedora-Server-dvd-aarch64-42-1.1.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "fedora.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.fedora"]
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}
