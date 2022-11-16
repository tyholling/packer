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
  iso_checksum     = "1c2deba876bd2da3a429b1b0cd5e294508b8379b299913d97dd6dd6ebcd8b56f"
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
