# macOS QEMU Fedora Server (aarch64)

1. Install tools

		brew tap hashicorp/tap
		brew install hashicorp/tap/packer qemu watch wget

1. Download Fedora Server

		wget https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/aarch64/iso/Fedora-Server-dvd-aarch64-37-1.7.iso

1. Set SSH key in `kickstart.cfg`

		sshkey --username=root "..."

1. Install Fedora

		packer build -force fedora.pkr.hcl

1. Create a snapshot

		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c fedora
		qemu-img snapshot fedora.img -l

1. Start Fedora

		sudo ./start.sh &

1. Wait for the VM to start

		until ssh-keyscan fedora; do sleep 5; done
		ssh -l root fedora

1. Update and snapshot

		dnf update
		reboot
		ssh -l root fedora

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 10; done
		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c update
		qemu-img snapshot fedora.img -l
		sudo ./start.sh &

1. Config and snapshot

		# optional: remove config
		rm -f anaconda-ks.cfg original-ks.cfg .bash_history .bash_logout .bash_profile .bashrc .cshrc .tcshrc .viminfo
		ssh-keygen -t ed25519
		# add ssh key to github
		cat .ssh/id_ed25519.pub
		dnf install ack bat git git-delta jq tmux
		# replace with your config repo
		git clone git@github.com:tyholling/config.git
		cd config
		./install.sh

		# snapshot with label: config
		poweroff
		while pgrep qemu; do sleep 10; done
		qemu-img snapshot fedora.img -l
		qemu-img snapshot fedora.img -c config
		qemu-img snapshot fedora.img -l
		sudo ./start.sh &

1. Optional: [Install k3s](k3s.md)
