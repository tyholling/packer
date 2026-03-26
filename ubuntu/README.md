# macOS QEMU Ubuntu Server (arm64)

1. Install dependencies
   ```
   brew install ansible axel hashicorp/tap/packer qemu watch
   packer plugins install github.com/hashicorp/qemu
   ```
1. Set SSH key in `user-data`
   ```
   authorized-keys: [ "..." ]
   ```
1. Build Ubuntu image
   ```
   ./build.sh
   ```
1. Provision the system
   - Use a unique hostname (`ubuntu`), it will be added to `/etc/hosts`
   ```
   sudo ./provision.sh ubuntu 192.168.64.5
   ```
1. Connect to the machine
   ```
   ssh -l root ubuntu
   ```
