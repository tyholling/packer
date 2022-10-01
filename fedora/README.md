# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso

1. Firmware: Option 1: Build locally

- Requires Docker

		docker build -t uefi .
		docker create --name extract uefi
		docker cp extract:/root/uefi.img .
		docker rm extract

1. Firmware: Option 2: Download nightly build

		wget https://retrage.github.io/edk2-nightly/bin/RELEASEAARCH64_QEMU_EFI.fd -O uefi.fd
		dd if=/dev/zero of=uefi.img bs=1m count=64
		dd if=uefi.fd of=uefi.img conv=notrunc

1. Set SSH key in `http/kickstart.cfg`

		sshkey --username=root "..."

1. Install Fedora

		packer build -force fedora.pkr.hcl

1. Start Fedora

		./startup.sh &
		ssh root@localhost
