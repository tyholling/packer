# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew install qemu wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso

1. Prepare firmware

		wget https://retrage.github.io/edk2-nightly/bin/RELEASEAARCH64_QEMU_EFI.fd -O uefi.fd
		dd if=/dev/zero of=uefi.img bs=1m count=64
		dd if=uefi.fd of=uefi.img conv=notrunc

1. Create empty disk for Fedora

		qemu-img create -f raw fedora.img 100G

1. Install Fedora

		./install.sh

	- Partitioning: select custom, btrfs, create automatically
	- Root user: set password, enable SSH
	- Click install
	- When finished, click reboot
	- Login and `poweroff`

1. Start Fedora

		./startup.sh &

- wait for the login prompt, press enter

		ssh -l root 127.0.0.1
