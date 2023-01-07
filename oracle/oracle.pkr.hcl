source "qemu" "oracle" {
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
  iso_checksum     = "3dc4578f53ceb1010f8236b3356f2441ec3f9e840fa60522e470d7f3cdb86cb1"
  iso_target_path  = "OracleLinux-R9-U1-aarch64-dvd.iso"
  iso_url = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u1/aarch64/OracleLinux-R9-U1-aarch64-dvd.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "strict=off"],
    ["-cpu", "host"],
    ["-device", "virtio-scsi-device"],
    ["-display", "none"],
    ["-drive", "file=oracle.img,if=none,format=qcow2,id=disk"],
    ["-device", "scsi-hd,drive=disk"],
    ["-drive", "file=OracleLinux-R9-U1-aarch64-dvd.iso,if=none,format=raw,id=cdrom"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "1h"
  vm_name          = "oracle.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.oracle"]
}
