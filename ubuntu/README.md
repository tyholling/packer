# macOS QEMU Ubuntu Server (arm64)

1. Install QEMU
   ```
   brew tap hashicorp/tap
   brew install hashicorp/tap/packer qemu
   ```
1. Set SSH key in `user-data`
   ```
   authorized-keys: [ "..." ]
   ```
1. Install Ubuntu
   ```
   packer build -force ubuntu.pkr.hcl
   ```
1. Provision the system
   - Use a unique hostname (`ubuntu`), it will be added to `/etc/hosts`
   ```
   sudo ./provision.sh ubuntu
   ```
1. Connect to the machine
   ```
   ssh -l root ubuntu
   ```
1. Example: install kubernetes
   ```
   ssh -l root ubuntu bash -s < kubelet.sh
   ```
