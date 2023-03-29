# macOS QEMU Debian Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Debian Server

		wget https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/debian-11.6.0-arm64-DVD-1.iso

1. Set SSH key in `preseed.cfg`

		echo "..." > /root/.ssh/authorized_keys

1. Install Debian

		packer build -force debian.pkr.hcl

1. Create a snapshot

		qemu-img snapshot debian.img -l
		qemu-img snapshot debian.img -c debian
		qemu-img snapshot debian.img -l

1. Start Debian

		./start.sh &

1. Connect to the VM

		until ssh -l root localhost:60422; do sleep 1; done
		ssh -l root localhost:60422

1. Update and snapshot

		apt update

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot debian.img -l
		qemu-img snapshot debian.img -c update
		qemu-img snapshot debian.img -l
