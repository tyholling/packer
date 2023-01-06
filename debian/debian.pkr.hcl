source "qemu" "debian" {
  boot_command = [
    "<esc>c<wait>",
    "linux /install.a64/vmlinuz auto=true priority=critical",
    " url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter><wait>",
    "initrd /install.a64/initrd.gz<enter><wait>",
    "boot<enter>"
  ]
  communicator = "none"
  cpus         = "8"
  disk_size    = "100G"
  firmware     = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/preseed.cfg" = file("preseed.cfg")
  }
  iso_checksum     = "b27ff768c10808518790d72d670c5588cdc60cf8934ef92773a89274a193a65f"
  iso_target_path  = "debian-11.6.0-arm64-DVD-1.iso"
  iso_url          = "https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/debian-11.6.0-arm64-DVD-1.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "strict=off"],
    ["-cpu", "host"],
    ["-device", "virtio-scsi-device"],
    ["-display", "none"],
    ["-drive", "file=debian.img,if=none,format=qcow2,id=disk"],
    ["-device", "scsi-hd,drive=disk"],
    ["-drive", "file=debian-11.6.0-arm64-DVD-1.iso,if=none,format=raw,id=cdrom"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "1h"
  vm_name          = "debian.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.debian"]
}
