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
  firmware         = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_directory   = "."
  iso_checksum     = "7bfdc79d09bd5e7c381935458991059df559a92a4b93adf6d07f0f445afbb4303b06e5a9156c43fdc3d7b756dd1718118cea69207e8a1529d416d172567a0de9"
  iso_target_path  = "Fedora-Server-dvd-aarch64-37-1.7.iso"
  iso_url          = "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/aarch64/iso/Fedora-Server-dvd-aarch64-37-1.7.iso"
  memory           = "8192"
  output_directory = "."
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "d"],
    ["-cpu", "host"],
    ["-display", "none"],
    ["-drive", "file=fedora.img"],
    ["-drive", "file=Fedora-Server-dvd-aarch64-37-1.7.iso"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  vm_name          = "fedora.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.fedora"]
}
