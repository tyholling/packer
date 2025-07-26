# macOS QEMU Ubuntu Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible axel go hashicorp/tap/packer qemu
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   ```
1. Set SSH key in `user-data`
   ```
   authorized-keys: [ "..." ]
   ```
1. Install Ubuntu
   - Use a unique hostname (`ubuntu`), it will be added to `/etc/hosts`
   ```
   ./build.sh ubuntu
   ```
1. Provision the system
   ```
   sudo ./provision.sh ubuntu
   ```
1. Connect to the machine
   ```
   ssh -l root ubuntu
   ```
