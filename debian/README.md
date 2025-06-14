# macOS QEMU Debian Server (arm64)

1. Install QEMU
   ```
   brew tap hashicorp/tap
   brew install hashicorp/tap/packer qemu
   ```
1. Set SSH key in `preseed.cfg`
   ```
   echo "..." > /root/.ssh/authorized_keys
   ```
1. Install Debian
   - Use a unique hostname (`debian`), it will be added to `/etc/hosts`
   ```
   sudo echo
   ./provision.sh debian
   ```
1. Connect to the machine
   ```
   ssh -l root debian
   ```
