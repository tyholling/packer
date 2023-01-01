# macOS QEMU Ubuntu Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu wget

1. Download Ubuntu Server

		wget https://cdimage.ubuntu.com/releases/22.10/release/ubuntu-22.10-live-server-arm64.iso

1. Set SSH key in `user-data`

		authorized-keys: [ "..." ]

1. Install Ubuntu

		packer build -force ubuntu.pkr.hcl

1. Create a snapshot

		qemu-img snapshot ubuntu.img -l
		qemu-img snapshot ubuntu.img -c ubuntu
		qemu-img snapshot ubuntu.img -l

1. Start Ubuntu

		sudo ./start.sh &

1. Wait for the VM to start

		until ssh-keyscan ubuntu; do sleep 1; done
		ssh-keygen -R ubuntu
		ssh -l root ubuntu

1. Update and snapshot

		apt update
		apt upgrade

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot ubuntu.img -l
		qemu-img snapshot ubuntu.img -c update
		qemu-img snapshot ubuntu.img -l

1. Config and snapshot

		sudo ./start.sh &
		ssh -l root ubuntu

		# optional: remove config
		rm -f .bash_history .bashrc .profile
		ssh-keygen -t ed25519
		# add ssh key to github
		cat .ssh/id_ed25519.pub
		apt install ack delta
		# replace with your config repo
		git clone git@github.com:tyholling/config.git
		cd config
		./install.sh

		# snapshot with label: config
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot ubuntu.img -l
		qemu-img snapshot ubuntu.img -c config
		qemu-img snapshot ubuntu.img -l
