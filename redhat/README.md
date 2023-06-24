# macOS QEMU Red Hat Server (aarch64)

1. Install QEMU

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu

1. Download Red Hat

		https://developers.redhat.com/content-gateway/file/rhel/9.2/rhel-9.2-aarch64-dvd.iso

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install Red Hat

		packer build -force redhat.pkr.hcl

1. Create a snapshot

		qemu-img snapshot redhat.img -l
		qemu-img snapshot redhat.img -c redhat
		qemu-img snapshot redhat.img -l

1. Start Red Hat

		./start.sh &

1. Connect to the VM

		ssh -l root localhost:61822

1. Update and snapshot

		dnf update
		poweroff
		while pgrep qemu; do sleep 1; done

		qemu-img snapshot redhat.img -l
		qemu-img snapshot redhat.img -c update
		qemu-img snapshot redhat.img -l
