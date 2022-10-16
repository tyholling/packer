# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu watch wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install Fedora

		packer build -force fedora.pkr.hcl

1. Optional: Create a snapshot

		qemu-img snapshot fedora.img -c install
		qemu-img snapshot fedora.img -l

1. Start Fedora

		sudo echo
		sudo ./startup.sh &

1. Find the IP address for the VM

		watch -n1 arp -a -i en1

1. SSH into the VM

		ssh root@<IP address>
