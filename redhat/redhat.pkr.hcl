source "qemu" "redhat" {
  boot_command = [
    "<esc>c<wait>",
    "linux /images/pxeboot/vmlinuz",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg<enter><wait>",
    "initrd /images/pxeboot/initrd.img<enter><wait>",
    "boot<enter>"
  ]
  communicator = "none"
  cpus         = "8"
  disk_size    = "100G"
  firmware     = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/kickstart.cfg" = file("kickstart.cfg")
  }
  iso_checksum     = "e9079bb03f16da5421b62e912d7f12620d177bc0944f304645b2ecf722f5a146"
  iso_target_path  = "rhel-9.2-aarch64-dvd.iso"
  iso_url          = "https://developers.redhat.com/content-gateway/file/rhel/9.2/rhel-9.2-aarch64-dvd.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "strict=off"],
    ["-cpu", "host"],
    ["-device", "virtio-scsi-device"],
    ["-display", "none"],
    ["-drive", "file=redhat.img,if=none,format=qcow2,id=disk"],
    ["-device", "scsi-hd,drive=disk"],
    ["-drive", "file=rhel-9.2-aarch64-dvd.iso,if=none,format=raw,id=cdrom"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "1h"
  vm_name          = "redhat.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.redhat"]
}
