# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso

1. Prepare firmware

		wget https://retrage.github.io/edk2-nightly/bin/RELEASEAARCH64_QEMU_EFI.fd -O uefi.fd
		dd if=/dev/zero of=uefi.img bs=1m count=64
		dd if=uefi.fd of=uefi.img conv=notrunc

1. Install Fedora

		packer build -force fedora.json

1. Start Fedora

		./startup.sh &

1. Copy SSH key into Fedora

		ssh-copy-id root@localhost # password: dev

1. Disable SSH login with password

		ssh root@localhost
		rm /etc/ssh/sshd_config.d/01-permit-root-login.conf
