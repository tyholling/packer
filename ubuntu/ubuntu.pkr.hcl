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
  iso_checksum     = "a19d956e993a16fc6496c371e36dcc0eb85d2bdf6a8e86028b92ce62e9f585cd"
  iso_target_path  = "ubuntu-22.10-live-server-arm64.iso"
  iso_url          = "https://cdimage.ubuntu.com/releases/22.10/release/ubuntu-22.10-live-server-arm64.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "d"],
    ["-cpu", "host"],
    ["-display", "none"],
    ["-drive", "file=ubuntu.img"],
    ["-drive", "file=ubuntu-22.10-live-server-arm64.iso"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "1h"
  vm_name          = "ubuntu.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.ubuntu"]
}
