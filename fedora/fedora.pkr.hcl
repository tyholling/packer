source "qemu" "fedora" {
  boot_command = [
    "<esc><up>e<wait><down><down>",
    "<right><right><right><right><right><right><right><right><right><right><right><right><right><right><right>",
    "<right><right><right><right><right><right><right><right><right><right><right><right><right><right><right>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg<wait>",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  communicator     = "none"
  cpus             = "8"
  disk_size        = "100G"
  firmware         = "uefi.img"
  http_directory   = "http"
  iso_checksum     = "0ab4000575ff8b258576750ecf4ca39b266f0c88cab5fe3d8d2f88c9bea4830d"
  iso_target_path  = "Fedora-Server-dvd-aarch64-36-1.5.iso"
  iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "d"],
    ["-cpu", "host"],
    ["-display", "none"],
    ["-drive", "file=fedora.img"],
    ["-drive", "file=Fedora-Server-dvd-aarch64-36-1.5.iso"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  vm_name          = "fedora.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.fedora"]
}
