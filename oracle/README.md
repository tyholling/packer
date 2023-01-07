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

		sudo ./start.sh &

1. Wait for the VM to start

		until ssh-keyscan oracle; do sleep 1; done
		ssh-keygen -R oracle
		ssh -l root oracle

1. Update and snapshot

		dnf update

		# snapshot with label: update
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot oracle.img -l
		qemu-img snapshot oracle.img -c update
		qemu-img snapshot oracle.img -l

1. Config and snapshot

		sudo ./start.sh &
		ssh -l root oracle

		# optional: remove config
		rm -f anaconda-ks.cfg original-ks.cfg .bash_history .bash_logout .bash_profile .bashrc .cshrc .tcshrc .viminfo
		ssh-keygen -t ed25519
		# add ssh key to github
		cat .ssh/id_ed25519.pub
		dnf install ack git git-delta tmux
		# replace with your config repo
		git clone git@github.com:tyholling/config.git
		cd config
		./install.sh

		# snapshot with label: config
		poweroff
		while pgrep qemu; do sleep 1; done
		qemu-img snapshot oracle.img -l
		qemu-img snapshot oracle.img -c config
		qemu-img snapshot oracle.img -l
