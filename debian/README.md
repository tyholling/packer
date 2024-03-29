# macOS QEMU Debian Server (arm64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

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

		ssh -l root -p 60422 localhost

1. Update and snapshot

		apt update
		apt upgrade
		poweroff
		while pgrep -f debian.img; do sleep 1; done

		qemu-img snapshot debian.img -l
		qemu-img snapshot debian.img -c update
		qemu-img snapshot debian.img -l
