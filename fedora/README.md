# macOS QEMU Fedora Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible hashicorp/tap/packer qemu
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Install Fedora
   ```
   packer build -force fedora.pkr.hcl
   ```
1. Provision the system
   - Use a unique hostname (`fedora`), it will be added to `/etc/hosts`
   ```
   sudo ./provision.sh fedora
   ```
1. Connect to the machine
   ```
   ssh -l root fedora
   ```
1. Example: install kubernetes
   ```
   ssh -l root fedora bash -s < kubelet.sh
   ```
