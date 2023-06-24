# macOS QEMU Ubuntu Server (aarch64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

1. Download Ubuntu Server

		https://cdimage.ubuntu.com/releases/22.10/release/ubuntu-22.10-live-server-arm64.iso

1. Set SSH key in `user-data`

		authorized-keys: [ "..." ]

1. Install Ubuntu

		packer build -force ubuntu.pkr.hcl

1. Create a snapshot

		qemu-img snapshot ubuntu.img -l
		qemu-img snapshot ubuntu.img -c ubuntu
		qemu-img snapshot ubuntu.img -l

1. Start Ubuntu

		./start.sh &

1. Connect to the VM

		ssh -l root localhost:62122

1. Update and snapshot

		apt update
		apt upgrade
		poweroff
		while pgrep qemu; do sleep 1; done

		qemu-img snapshot ubuntu.img -l
		qemu-img snapshot ubuntu.img -c update
		qemu-img snapshot ubuntu.img -l
