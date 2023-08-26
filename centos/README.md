# macOS QEMU CentOS Server (arm64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install CentOS

		packer build -force centos.pkr.hcl

1. Create a snapshot

		qemu-img snapshot centos.img -l
		qemu-img snapshot centos.img -c centos
		qemu-img snapshot centos.img -l

1. Start CentOS

		./start.sh &

1. Connect to the VM

		ssh -l root -p 60322 localhost

1. Update and snapshot

		dnf update
		poweroff
		while pgrep -f centos.img; do sleep 1; done

		qemu-img snapshot centos.img -l
		qemu-img snapshot centos.img -c update
		qemu-img snapshot centos.img -l
