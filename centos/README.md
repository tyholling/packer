# macOS QEMU CentOS Stream Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible axel go hashicorp/tap/packer qemu
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Install CentOS Stream
   - Use a unique hostname (`centos`), it will be added to `/etc/hosts`
   ```
   ./build.sh centos
   ```
1. Provision the system
   ```
   sudo ./provision.sh centos
   ```
1. Connect to the machine
   ```
   ssh -l root centos
   ```
