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
   - Use a unique hostname (`ubuntu`), it will be added to `/etc/hosts`
   ```
   sudo echo
   ./provision.sh ubuntu
   ```
1. Connect to the machine
   ```
   ssh -l root ubuntu
   ```
