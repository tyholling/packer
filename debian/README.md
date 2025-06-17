# macOS QEMU Debian Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible hashicorp/tap/packer qemu
   ```
1. Set SSH key in `preseed.cfg`
   ```
   echo "..." > /root/.ssh/authorized_keys
   ```
1. Install Debian
   ```
   packer build -force debian.pkr.hcl
   ```
1. Provision the system
   - Use a unique hostname (`debian`), it will be added to `/etc/hosts`
   ```
   sudo ./provision.sh debian
   ```
1. Connect to the machine
   ```
   ssh -l root debian
   ```
1. Example: install kubernetes
   ```
   ssh -l root debian bash -s < kubelet.sh
   ```
