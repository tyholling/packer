# macOS QEMU Debian Server (arm64)

1. Install dependencies
   ```
   brew tap hashicorp/tap
   brew install ansible go hashicorp/tap/packer qemu
   go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
   ```
1. Set SSH key in `preseed.cfg`
   ```
   echo "..." > /root/.ssh/authorized_keys
   ```
1. Install Debian
   - Use a unique hostname (`debian`), it will be added to `/etc/hosts`
   ```
   ./build.sh debian
   ```
1. Provision the system
   ```
   sudo ./provision.sh debian
   ```
1. Connect to the machine
   ```
   ssh -l root debian
   ```
