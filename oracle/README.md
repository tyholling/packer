# macOS QEMU Oracle Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Oracle Server

		wget https://yum.oracle.com/ISOS/OracleLinux/OL9/u1/aarch64/OracleLinux-R9-U1-aarch64-dvd.iso

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install Oracle

		packer build -force oracle.pkr.hcl

1. Create a snapshot

		qemu-img snapshot oracle.img -l
		qemu-img snapshot oracle.img -c oracle
		qemu-img snapshot oracle.img -l

1. Start Oracle

		./start.sh &

1. Connect to the VM

		until ssh -l root localhost:61522; do sleep 1; done
		ssh -l root localhost:61522

1. Update and snapshot

		dnf update

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot oracle.img -l
		qemu-img snapshot oracle.img -c update
		qemu-img snapshot oracle.img -l
