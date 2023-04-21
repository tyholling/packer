source "qemu" "ubuntu" {
  boot_command = [
    "<esc>c<wait>",
    "linux /casper/vmlinuz",
    " autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  communicator = "none"
  cpus         = "8"
  disk_size    = "100G"
  firmware     = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/user-data" = file("user-data")
    "/meta-data" = ""
  }
  iso_checksum     = "ad306616e37132ee00cc651ac0233b0e24b0b6e5e93b4a8ad36aa30c95b74e8c"
  iso_target_path  = "ubuntu-23.04-live-server-arm64.iso"
  iso_url          = "https://cdimage.ubuntu.com/releases/23.04/release/ubuntu-23.04-live-server-arm64.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "strict=off"],
    ["-cpu", "host"],
    ["-device", "virtio-scsi-device"],
    ["-display", "none"],
    ["-drive", "file=ubuntu.img,if=none,format=qcow2,id=disk"],
    ["-device", "scsi-hd,drive=disk"],
    ["-drive", "file=ubuntu-23.04-live-server-arm64.iso,if=none,format=raw,id=cdrom"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "1h"
  vm_name          = "ubuntu.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.ubuntu"]
}
