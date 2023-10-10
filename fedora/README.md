# macOS QEMU Fedora Server (arm64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

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

		ssh -l root -p 60622 localhost

1. Update and snapshot

		dnf update
		poweroff
		while pgrep -f fedora.img; do sleep 1; done

		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c update
		qemu-img snapshot fedora.img -l
