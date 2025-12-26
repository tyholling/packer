{{ range $dir := (datasource "dirs") -}}
source "qemu" "debian_{{ $dir }}" {
  accelerator = "hvf"
  boot_command = [
    "<esc>c<wait>",
    "linux /install.a64/vmlinuz auto=true priority=critical",
    " url=http://{{`{{ .HTTPIP }}`}}:{{`{{ .HTTPPort }}`}}/preseed.cfg<enter><wait>",
    "initrd /install.a64/initrd.gz<enter><wait>",
    "boot<enter>"
  ]
  boot_key_interval = "1ms"
  boot_wait         = "-1s"
  communicator      = "none"
  cpus              = "8"
  disk_size         = "100G"
  firmware          = "/opt/homebrew/share/qemu/edk2-aarch64-code.fd"
  http_content = {
    "/preseed.cfg" = file("preseed.cfg")
  }
  iso_checksum     = "file:debian-13.2.0-arm64-DVD-1.iso.sha256"
  iso_target_path  = "debian-13.2.0-arm64-DVD-1.iso"
  iso_url          = "debian-13.2.0-arm64-DVD-1.iso"
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
    ["-drive", "file={{ $dir }}/debian.img,if=none,format=qcow2,id=disk"],
    ["-drive", "file=debian-13.2.0-arm64-DVD-1.iso,if=none,format=raw,id=cdrom"],
    ["-machine", "accel=hvf,highmem=on,type=virt"]
  ]
  shutdown_timeout = "10m"
  vm_name          = "debian.img"
  vnc_use_password = "true"
}

{{ end -}}
build {
  sources = [
    {{- $dirs := (datasource "dirs") -}}
    {{- range $dir := (datasource "dirs") }}
    "source.qemu.debian_{{ $dir }}",
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
