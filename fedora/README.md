# macOS QEMU Fedora Server (aarch64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

1. Download Fedora Server

		https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/aarch64/iso/Fedora-Server-dvd-aarch64-37-1.7.iso

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install Fedora

		packer build -force fedora.pkr.hcl

1. Create a snapshot

		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c fedora
		qemu-img snapshot fedora.img -l

1. Start Fedora

		./start.sh &

1. Connect to the VM

		ssh -l root localhost:60622

1. Update and snapshot

		dnf update
		poweroff
		while pgrep qemu; do sleep 1; done

		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c update
		qemu-img snapshot fedora.img -l
