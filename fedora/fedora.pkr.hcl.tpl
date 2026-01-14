{{ range $dir := (datasource "dirs") -}}
source "qemu" "fedora_{{ $dir }}" {
  accelerator = "hvf"
  boot_command = [
    "<esc>c<wait>",
    "linux /images/pxeboot/vmlinuz",
    " inst.ks=http://{{`{{ .HTTPIP }}`}}:{{`{{ .HTTPPort }}`}}/kickstart.cfg<enter><wait>",
    "initrd /images/pxeboot/initrd.img<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "1ms"
  boot_wait         = "-1s"
  communicator      = "none"
  cpus              = "8"
  disk_size         = "100G"
  firmware          = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/kickstart.cfg" = file("kickstart.cfg")
  }
  iso_checksum     = "file:Fedora-Server-dvd-aarch64-43-1.6.iso.sha256"
  iso_target_path  = "Fedora-Server-dvd-aarch64-43-1.6.iso"
  iso_url          = "Fedora-Server-dvd-aarch64-43-1.6.iso"
  memory           = "4096"
  output_directory = {{ $dir | quote }}
  qemu_binary      = "qemu-system-aarch64"
  qemuargs = [
    ["-boot", "menu=on,splash-time=0"],
    ["-cpu", "host"],
    ["-device", "virtio-rng-device"],
    ["-device", "virtio-scsi-device"],
    ["-device", "scsi-hd,drive=disk"],
    ["-device", "scsi-cd,drive=cdrom"],
    ["-display", "none"],
    ["-drive", "file={{ $dir }}/fedora.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=Fedora-Server-dvd-aarch64-43-1.6.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "fedora.img"
  vnc_use_password = "true"
}

{{ end -}}
build {
  sources = [
    {{- $dirs := (datasource "dirs") -}}
    {{- range $dir := (datasource "dirs") }}
    "source.qemu.fedora_{{ $dir }}",
    {{- end }}
  ]
}

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}
