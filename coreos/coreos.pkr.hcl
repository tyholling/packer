source "qemu" "coreos" {
  boot_command = [
    "<enter><wait20s>",
    "sudo /usr/bin/coreos-installer install",
    " --ignition-url http://{{ .HTTPIP }}:{{ .HTTPPort }}/ignition.cfg",
    " --ignition-hash sha256-c286585fd30bdfc70a275375009e640454a4c0192428061b948a5eab155315a6",
    " /dev/sda",
    "<enter><wait40s>",
    "poweroff<enter>"
  ]
  boot_key_interval = "2ms"
  boot_wait         = "-1s"
  communicator      = "none"
  cpus              = "8"
  disk_size         = "100G"
  firmware          = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/ignition.cfg" = file("ignition.cfg")
  }
  iso_checksum     = "01fe55848aff2b07793b7bb667b8bda4f9ae56bce3496eafaea7a7f9e0c3492d"
  iso_target_path  = "fedora-coreos-40.20240519.3.0-live.aarch64.iso"
  iso_url          = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/40.20240519.3.0/aarch64/fedora-coreos-40.20240519.3.0-live.aarch64.iso"
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
    ["-device", "qemu-xhci"],
    ["-device", "usb-kbd"],
    ["-device", "usb-tablet"],
    ["-device", "ramfb"],
    ["-display", "cocoa"],
    ["-drive", "file=coreos.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=fedora-coreos-40.20240519.3.0-live.aarch64.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "coreos.img"
  vnc_use_password = "true"
}

build {
  sources = ["source.qemu.coreos"]
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}
