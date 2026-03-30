# macOS QEMU CentOS Stream Server (arm64)

1. Install dependencies
   ```
   brew install ansible axel hashicorp/tap/packer qemu watch
   packer plugins install github.com/hashicorp/qemu
   ```
1. Set SSH key in `kickstart.cfg`
   ```
   sshkey --username=root "..."
   ```
1. Build CentOS Stream image
   ```
   ./build.sh
   ```
1. Install updates
   ```
   ./update.sh
   ```
1. Provision the system
   ```
   sudo ./provision.sh
   ```
1. Connect to the machine
   ```
   ssh -l root centos
   ```
