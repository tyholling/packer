source "qemu" "photon" {
  boot_command = [
    "<esc>c<wait>",
    "linux /isolinux/vmlinuz insecure_installation=1 photon.media=cdrom",
    " ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.json<enter><wait>",
    "initrd /isolinux/initrd.img<enter><wait>",
    "boot<enter>"
  ]
  boot_wait = "2s"
  cpus      = "8"
  disk_size = "100G"
  firmware  = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/kickstart.json" = file("kickstart.json")
  }
  iso_checksum     = "c2d509ba868c6257149005afccd546d697d6f984c1864696f157cee4eee6b02a"
  iso_target_path  = "photon-5.0-4d5974638.aarch64.iso"
  iso_url          = "https://packages.vmware.com/photon/5.0/RC/iso/photon-5.0-4d5974638.aarch64.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "strict=off"],
    ["-cpu", "host"],
    ["-device", "virtio-scsi-device"],
    ["-display", "none"],
    ["-drive", "file=photon.img,if=none,format=qcow2,id=disk"],
    ["-device", "scsi-hd,drive=disk"],
    ["-drive", "file=photon-5.0-4d5974638.aarch64.iso,if=none,format=raw,id=cdrom"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  ssh_password     = "photon"
  ssh_username     = "root"
  shutdown_command = "poweroff"
  shutdown_timeout = "1h"
  vm_name          = "photon.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.photon"]
}
