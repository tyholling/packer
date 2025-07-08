{{ range $dir := (datasource "dirs") -}}
source "qemu" "centos_{{ $dir }}" {
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
  iso_checksum     = "file:https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM"
  iso_target_path  = "CentOS-Stream-10-latest-aarch64-dvd1.iso"
  iso_url          = "https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso"
  memory           = "8192"
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
    ["-drive", "file={{ $dir }}/centos.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=CentOS-Stream-10-latest-aarch64-dvd1.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "centos.img"
  vnc_use_password = "true"
}

{{ end -}}
build {
  sources = [
    {{- $dirs := (datasource "dirs") -}}
    {{- range $dir := (datasource "dirs") }}
    "source.qemu.centos_{{ $dir }}",
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
