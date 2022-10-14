# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer podman qemu wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso

1. Build firmware

		podman machine init
		podman machine start
		podman build -t uefi .
		podman create --name extract uefi
		podman cp extract:/root/uefi.img .
		podman rm extract
		podman machine stop
		podman machine rm

1. Set SSH key in `http/kickstart.cfg`

		sshkey --username=root "..."

1. Install Fedora

		packer build -force fedora.pkr.hcl

1. Start Fedora

		./startup.sh &
		ssh root@localhost
