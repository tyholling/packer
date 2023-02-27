# macOS QEMU Photon Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Photon Server

		wget https://packages.vmware.com/photon/5.0/Beta/iso/photon-5.0-9e778f409-aarch64.iso

1. Set SSH key in `kickstart.json`

		"public_key": "..."

1. Install Photon

		packer build -force photon.pkr.hcl

1. Create a snapshot

		qemu-img snapshot photon.img -l
		qemu-img snapshot photon.img -c photon
		qemu-img snapshot photon.img -l

1. Start Photon

		sudo ./start.sh &

1. Wait for the VM to start

		sleep 30
		dig +short photon
		ssh -l root <ip address>

1. Update and snapshot

		tdnf update

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot photon.img -l
		qemu-img snapshot photon.img -c update
		qemu-img snapshot photon.img -l